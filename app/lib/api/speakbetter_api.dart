import 'dart:io';
import 'dart:convert';
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

    // Set longer timeout for transcription (audio processing can take time)
    final res = await _dio.post(
      '/v1/transcribe',
      data: form,
      options: Options(
        receiveTimeout:
            const Duration(minutes: 5), // 5 minutes for transcription
        sendTimeout: const Duration(minutes: 2), // 2 minutes for upload
      ),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> improve({
    required String language,
    required String learnerMode,
    required String transcript,
    File? imageFile,
    Map<String, dynamic>? topic,
    Map<String, dynamic>? preferences,
  }) async {
    if (imageFile != null) {
      // If image is provided, send as multipart form
      final filePath = imageFile.path;
      final extension = filePath.split('.').last.toLowerCase();
      final filename = 'image.$extension';

      final form = FormData.fromMap({
        'language': language,
        'learnerMode': learnerMode,
        'transcript': transcript,
        'image': await MultipartFile.fromFile(filePath, filename: filename),
        if (topic != null) 'topic': jsonEncode(topic),
        if (preferences != null) 'preferences': jsonEncode(preferences),
      });

      // Debug: Log form data fields
      print('=== SENDING FORMDATA ===');
      print('FormData fields: language=$language, learnerMode=$learnerMode, transcriptLength=${transcript.length}');
      print('Has image: true');
      print('FormData fields count: ${form.fields.length}');
      print('FormData files count: ${form.files.length}');

      final res = await _dio.post(
        '/v1/improve',
        data: form,
        options: Options(
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 1),
          // Don't set Content-Type header - Dio will set it automatically with boundary
        ),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } else {
      // No image, send as JSON
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

  Future<Map<String, dynamic>> analyzeImage({
    required File imageFile,
    required String language, // 'ko'|'en'
    required String learnerMode, // 'korean_learner'|'english_learner'
  }) async {
    final filePath = imageFile.path;
    final extension = filePath.split('.').last.toLowerCase();
    final filename = 'image.$extension';

    final form = FormData.fromMap({
      'language': language,
      'learnerMode': learnerMode,
      'image': await MultipartFile.fromFile(filePath, filename: filename),
    });

    final res = await _dio.post(
      '/v1/analyze-image',
      data: form,
      options: Options(
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 1),
      ),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
