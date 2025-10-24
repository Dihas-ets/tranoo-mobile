import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

final _logger = Logger('CloudinaryUpload');

Future<String?> uploadImageToCloudinary(dynamic image) async {
  final cloudName = 'dy0raj5bh';
  final uploadPreset = 'unsigned_preset';
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );
  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset;

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

Future<String?> uploadVideoToCloudinary(File videoFile) async {
  final cloudName = 'dy0raj5bh';
  final uploadPreset = 'unsigned_preset';
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
  );

  print('[Cloudinary] === DÉBUT UPLOAD VIDÉO ===');
  print('[Cloudinary] Fichier: ${videoFile.path}');
  print('[Cloudinary] URL: $url');
  print('[Cloudinary] Cloud name: $cloudName');
  print('[Cloudinary] Upload preset: $uploadPreset');

  // Vérifier que le fichier existe
  if (!await videoFile.exists()) {
    print('[Cloudinary] ERREUR: Le fichier n\'existe pas!');
    return null;
  }

  final fileSize = await videoFile.length();
  print('[Cloudinary] Taille du fichier: ${fileSize / (1024 * 1024)} Mo');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset;

  print('[Cloudinary] Création du MultipartFile...');
  try {
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      videoFile.path,
    );
    request.files.add(multipartFile);
    print('[Cloudinary] MultipartFile créé avec succès');
  } catch (e) {
    print('[Cloudinary] ERREUR création MultipartFile: $e');
    return null;
  }

  print('[Cloudinary] Envoi de la requête...');
  try {
    final response = await request.send().timeout(const Duration(seconds: 120));
    print('[Cloudinary] Réponse reçue: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('[Cloudinary] Upload réussi! Lecture de la réponse...');
      final respStr = await response.stream.bytesToString();
      print('[Cloudinary] Réponse brute: $respStr');

      try {
        final data = jsonDecode(respStr);
        final videoUrl = data['secure_url'] as String?;
        print('[Cloudinary] URL vidéo extraite: $videoUrl');
        return videoUrl;
      } catch (e) {
        print('[Cloudinary] ERREUR parsing JSON: $e');
        return null;
      }
    } else {
      print('[Cloudinary] ERREUR HTTP: ${response.statusCode}');
      final errorBody = await response.stream.bytesToString();
      print('[Cloudinary] Corps de l\'erreur: $errorBody');
      return null;
    }
  } catch (e) {
    print('[Cloudinary] EXCEPTION lors de l\'envoi: $e');
    return null;
  }
}

Future<String?> uploadVideoToCloudinaryWeb(Uint8List bytes) async {
  final cloudName = 'dy0raj5bh';
  final uploadPreset = 'unsigned_preset';
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
  );

  _logger.info('[DEBUG] Upload vidéo Web vers Cloudinary');

  final request =
      http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
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
