import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ProductImageService {
  ProductImageService({required Dio dio, required String token})
    : _dio = dio,
      _token = token;

  final Dio _dio;
  final String _token;
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromGalleryAndUpload(int productId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return null;

    return uploadImage(productId: productId, file: File(picked.path));
  }

  Future<String?> takePhotoAndUpload(int productId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked == null) return null;

    return uploadImage(productId: productId, file: File(picked.path));
  }

  Future<String> uploadImage({
    required int productId,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();

    final response = await _dio.post<Map<String, dynamic>>(
      '/products/$productId/upload_image',
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Authorization': 'Bearer $_token',
          Headers.contentTypeHeader: _detectContentType(file.path),
        },
      ),
    );

    final data = response.data;

    if (data == null || data['image_url'] == null) {
      throw Exception('Server did not return image_url');
    }

    return data['image_url'] as String;
  }

  String _detectContentType(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
