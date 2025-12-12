import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tranoo/config/backend_config.dart';

final _logger = Logger('CloudinaryUpload');

class CloudinaryFolders {
  static const String root = 'tranoo';
  static const String profiles = '$root/profiles';
  static const String vehicleImages = '$root/vehicules/images';
  static const String vehicleVideos = '$root/vehicules/videos';
  static const String pieceImages = '$root/pieces/images';
  static const String pieceVideos = '$root/pieces/videos';
  static const String verificationDocs = '$root/verification/documents';
  static const String misc = '$root/misc';
}

Future<String?> uploadImageToCloudinary(
  dynamic image, {
  String folder = CloudinaryFolders.misc,
}) async {
  final cloudName = 'dy0raj5bh';
  final uploadPreset = 'unsigned_preset';
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );
  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..fields['folder'] = folder;

  if (kIsWeb && image is Uint8List) {
    request.files.add(
      http.MultipartFile.fromBytes('file', image, filename: 'upload.jpg'),
    );
  } else if (image is File) {
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
  } else {
    return null;
  }

  try {
    final response = await request.send().timeout(const Duration(seconds: 60));
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);
      return jsonData['secure_url'];
    } else {
      _logger.warning('Erreur upload Cloudinary: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    _logger.severe('Timeout/Erreur upload Cloudinary image: $e');
    return null;
  }
}

Future<String?> uploadVideoToCloudinary(
  File videoFile, {
  String folder = CloudinaryFolders.misc,
  Function(double progress)? onProgress,
}) async {
  final backendUrl = Uri.parse('${getApiBaseUrl()}/upload/video');
  if (!await videoFile.exists()) {
    print('[UploadBackend] ERREUR: Le fichier n\'existe pas!');
    return null;
  }
  
  final fileSize = await videoFile.length();
  final request = http.MultipartRequest('POST', backendUrl);
  request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
  request.fields['folder'] = folder;
  
  try {
    // Simuler la progression pendant l'upload (approximation)
    if (onProgress != null) {
      // Simuler 0-80% pendant l'upload
      onProgress(0.1);
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress(0.3);
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress(0.5);
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress(0.7);
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress(0.8);
    }
    
    final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
    
    if (onProgress != null) {
      onProgress(0.85); // Upload terminé, traitement serveur
    }
    
    final respStr = await streamedResponse.stream.bytesToString();
    
    if (onProgress != null) {
      onProgress(0.95); // Compression/traitement presque terminé
    }
    
    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(respStr);
      final videoUrl = data['optimizedUrl'] ?? data['url'] as String?;
      print('[UploadBackend] URL vidéo optimisée: $videoUrl');
      if (onProgress != null) onProgress(1.0); // 100%
      return videoUrl;
    }
    print('[UploadBackend] ERREUR HTTP: ${streamedResponse.statusCode} -> $respStr');
    return null;
  } catch (e) {
    print('[UploadBackend] EXCEPTION lors de l\'envoi: $e');
    return null;
  }
}

Future<String?> uploadVideoToCloudinaryWeb(
  Uint8List bytes, {
  String folder = CloudinaryFolders.misc,
}) async {
  final cloudName = 'dy0raj5bh';
  final uploadPreset = 'unsigned_preset';
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
  );

  _logger.info('[DEBUG] Upload vidéo Web vers Cloudinary');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..fields['folder'] = folder
    ..files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: 'upload.mp4'),
    );

  try {
    final response = await request.send().timeout(const Duration(seconds: 120));
    _logger.info(
      '[DEBUG] Réponse Cloudinary vidéo Web: ${response.statusCode}',
    );
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      final videoUrl = data['secure_url'] as String?;
      _logger.info('[DEBUG] URL vidéo Web Cloudinary: $videoUrl');
      return videoUrl;
    } else {
      _logger.warning(
        'Erreur upload vidéo Web Cloudinary: ${response.statusCode}',
      );
      return null;
    }
  } catch (e) {
    _logger.severe('Timeout/Erreur upload Cloudinary vidéo Web: $e');
    return null;
  }
}
