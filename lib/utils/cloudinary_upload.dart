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

  final response = await request.send();
  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final jsonData = jsonDecode(responseData);
    return jsonData['secure_url'];
  } else {
    _logger.warning('Erreur upload Cloudinary: ${response.statusCode}');
    return null;
  }
}

Future<String?> uploadVideoToCloudinary(File videoFile) async {
  final cloudName = 'dy0raj5bh';
  final uploadPreset = 'unsigned_preset';
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
  );
  
  _logger.info('[DEBUG] Upload vidéo vers Cloudinary: ${videoFile.path}');
  
  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..fields['format'] = 'mp4'
    ..fields['video_codec'] = 'h264'
    ..fields['quality'] = 'auto:low'
    ..fields['bit_rate'] = '1000k'
    ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));
    
  final response = await request.send();
  _logger.info('[DEBUG] Réponse Cloudinary vidéo: ${response.statusCode}');
  
  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr);
    final videoUrl = data['secure_url'] as String?;
    _logger.info('[DEBUG] URL vidéo Cloudinary: $videoUrl');
    return videoUrl;
  } else {
    _logger.warning('Erreur upload vidéo Cloudinary: ${response.statusCode}');
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
  
  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..fields['format'] = 'mp4'
    ..fields['video_codec'] = 'h264'
    ..fields['quality'] = 'auto:low'
    ..fields['bit_rate'] = '1000k'
    ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'upload.mp4'));
    
  final response = await request.send();
  _logger.info('[DEBUG] Réponse Cloudinary vidéo Web: ${response.statusCode}');
  
  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr);
    final videoUrl = data['secure_url'] as String?;
    _logger.info('[DEBUG] URL vidéo Web Cloudinary: $videoUrl');
    return videoUrl;
  } else {
    _logger.warning('Erreur upload vidéo Web Cloudinary: ${response.statusCode}');
    return null;
  }
}
