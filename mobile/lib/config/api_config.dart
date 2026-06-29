class ApiConfig {
  // --- UPDATE THIS IP ---
  // Your computer's local IP on this network: 172.20.10.9
  // Android emulator: 10.0.2.2
  // iOS simulator: localhost
  static const String baseUrl = 'http://172.20.10.9:5000/api';

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
