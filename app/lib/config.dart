class AppConfig {
  // Point to your backend:
  // For local dev: use --dart-define=API_BASE_URL=http://localhost:8080
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://speakbetter-api.onrender.com',
  );
}

