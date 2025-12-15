import 'dart:io';
import 'package:dio/dio.dart';
import '../config.dart';
import '../services/auth_service.dart';

class SpeakBetterApi {
  SpeakBetterApi({AuthService? authService})
      : _authService = authService ?? AuthService(),
        _dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        )) {
    // Add interceptor to include auth token in requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get ID token and add to Authorization header
          final token = await _authService.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // If 401, try refreshing token once
          if (error.response?.statusCode == 401) {
            final token = await _authService.getIdToken(forceRefresh: true);
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              // Retry the request
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  final AuthService _authService;
  final Dio _dio;

  Future<Map<String, dynamic>> transcribe({
    required File audioFile,
    required String language, // 'ko'|'en'|'auto'
  }) async {
    // Get the actual file extension from the file path
    final filePath = audioFile.path;
    final extension = filePath.split('.').last.toLowerCase();
    final filename = 'audio.$extension';

    final form = FormData.fromMap({
      'language': language,
      'audio': await MultipartFile.fromFile(filePath, filename: filename),
    });

    final res = await _dio.post('/v1/transcribe', data: form);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> improve({
    required String language,
    required String learnerMode,
    required String transcript,
    Map<String, dynamic>? topic,
    Map<String, dynamic>? preferences,
  }) async {
    final res = await _dio.post('/v1/improve', data: {
      'language': language,
      'learnerMode': learnerMode,
      'transcript': transcript,
      if (topic != null) 'topic': topic,
      if (preferences != null) 'preferences': preferences,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }
}
