import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Utility class for user-friendly error messages
class ErrorMessages {
  /// Get user-friendly error message for Firebase Auth exceptions
  static String getAuthErrorMessage(FirebaseAuthException e, {bool isKorean = false}) {
    switch (e.code) {
      case 'weak-password':
        return isKorean 
            ? '비밀번호가 너무 약합니다. 더 강한 비밀번호를 사용해주세요.'
            : 'The password provided is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return isKorean
            ? '이 이메일로 이미 계정이 존재합니다.'
            : 'An account already exists for that email.';
      case 'user-not-found':
        return isKorean
            ? '이 이메일로 등록된 계정을 찾을 수 없습니다.'
            : 'No user found for that email.';
      case 'wrong-password':
        return isKorean
            ? '비밀번호가 올바르지 않습니다.'
            : 'Wrong password provided.';
      case 'invalid-email':
        return isKorean
            ? '이메일 주소 형식이 올바르지 않습니다.'
            : 'The email address is invalid.';
      case 'user-disabled':
        return isKorean
            ? '이 계정이 비활성화되었습니다.'
            : 'This user account has been disabled.';
      case 'too-many-requests':
        return isKorean
            ? '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.'
            : 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return isKorean
            ? '이 로그인 방법이 활성화되지 않았습니다.'
            : 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return isKorean
            ? '네트워크 연결을 확인해주세요.'
            : 'Please check your network connection.';
      default:
        return isKorean
            ? '인증 중 오류가 발생했습니다: ${e.message ?? '알 수 없는 오류'}'
            : 'An error occurred during authentication: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Get user-friendly error message for API/Dio exceptions
  static String getApiErrorMessage(dynamic error, {bool isKorean = false}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return isKorean
              ? '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.'
              : 'Request timed out. Please check your network connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final errorData = error.response?.data;
          
          if (statusCode == 401) {
            return isKorean
                ? '인증에 실패했습니다. 다시 로그인해주세요.'
                : 'Authentication failed. Please sign in again.';
          } else if (statusCode == 403) {
            return isKorean
                ? '권한이 없습니다.'
                : 'Permission denied.';
          } else if (statusCode == 404) {
            return isKorean
                ? '요청한 리소스를 찾을 수 없습니다.'
                : 'Resource not found.';
          } else if (statusCode == 500) {
            return isKorean
                ? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
                : 'Server error occurred. Please try again later.';
          } else if (statusCode == 503) {
            return isKorean
                ? '서비스를 사용할 수 없습니다. 잠시 후 다시 시도해주세요.'
                : 'Service unavailable. Please try again later.';
          } else {
            // Try to extract error message from response
            String? errorMessage;
            String? details;
            if (errorData is Map) {
              errorMessage = errorData['error']?.toString() ?? 
                           errorData['message']?.toString();
              details = errorData['details']?.toString();
            } else if (errorData is String) {
              errorMessage = errorData;
            }
            
            final fullMessage = details != null && details != errorMessage
                ? '$errorMessage: $details'
                : errorMessage ?? '알 수 없는 오류';
            
            return isKorean
                ? '오류가 발생했습니다: $fullMessage'
                : 'An error occurred: $fullMessage';
          }
        case DioExceptionType.cancel:
          return isKorean
              ? '요청이 취소되었습니다.'
              : 'Request was cancelled.';
        case DioExceptionType.unknown:
        default:
          if (error.error?.toString().contains('SocketException') == true ||
              error.error?.toString().contains('network') == true) {
            return isKorean
                ? '네트워크 연결을 확인해주세요.'
                : 'Please check your network connection.';
          }
          return isKorean
              ? '네트워크 오류가 발생했습니다. 연결을 확인해주세요.'
              : 'Network error occurred. Please check your connection.';
      }
    }
    
    // Generic error
    final errorString = error.toString();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return isKorean
          ? '네트워크 연결을 확인해주세요.'
          : 'Please check your network connection.';
    }
    
    return isKorean
        ? '오류가 발생했습니다. 다시 시도해주세요.'
        : 'An error occurred. Please try again.';
  }
}
