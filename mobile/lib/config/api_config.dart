class ApiConfig {
  // Cloud server (Render)
  static const String baseUrl = 'https://tailor-p2y2.onrender.com/api';

  static const String auth = '$baseUrl/auth';
  static const String customers = '$baseUrl/customers';
  static const String measurements = '$baseUrl/measurements';
  static const String health = '$baseUrl/health';

  static const Duration timeout = Duration(seconds: 15);

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final rootUrl = baseUrl.replaceAll('/api', '');
    return '$rootUrl$path';
  }
}
