import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../models/chat_message.dart';

class ApiService {
  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 90),
            sendTimeout: const Duration(seconds: 30),
            headers: {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;

  Future<ChatResponse> chat({
    required String prompt,
    String? model,
    String? imageBase64,
  }) async {
    final payload = <String, dynamic>{
      'prompt': prompt,
      if (model != null) 'model': model,
      if (imageBase64 != null) 'image_base64': imageBase64,
    };

    final response = await _dio.post<Map<String, dynamic>>(
      AppConstants.chatPath,
      data: payload,
      options: Options(
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final data = response.data;
    if (data == null) {
      throw ApiException('The server returned an empty response.');
    }
    return ChatResponse.fromJson(data);
  }

  Future<Uint8List> synthesize(String text, {String gender = AppConstants.defaultGender}) async {
    final response = await _dio.post<List<int>>(
      AppConstants.ttsPath,
      data: {'text': text, 'gender': gender},
      options: Options(responseType: ResponseType.bytes),
    );

    final contentType = response.headers.value('content-type') ?? '';
    final bytes = Uint8List.fromList(response.data ?? const <int>[]);

    // Supports both raw audio responses and JSON responses containing media_url.
    if (!contentType.contains('application/json')) {
      if (bytes.isEmpty) throw ApiException('TTS returned no audio data.');
      return bytes;
    }

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map<String, dynamic> && decoded['media_url'] is String) {
      final mediaUrl = _resolveUrl(decoded['media_url'] as String);
      final audio = await _dio.get<List<int>>(
        mediaUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(audio.data ?? const <int>[]);
    }

    throw ApiException('TTS response did not contain audio data.');
  }

  Future<void> clearRemoteHistory() async {
    await _dio.get<void>(AppConstants.clearPath);
  }

  String resolveMediaUrl(String url) => _resolveUrl(url);

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${AppConstants.apiBaseUrl}$url';
    return '${AppConstants.apiBaseUrl}/$url';
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
