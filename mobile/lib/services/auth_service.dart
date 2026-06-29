import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static Future<User> register({
    required String name,
    required String phone,
    required String password,
    required String shopName,
  }) async {
    final data = await ApiClient.post(
      '${ApiConfig.auth}/register',
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        'shopName': shopName,
      },
    );
    final user = User.fromJson(data);
    if (user.token != null) {
      await ApiClient.setToken(user.token);
    }
    return user;
  }

  static Future<User> login({
    required String phone,
    required String password,
  }) async {
    final data = await ApiClient.post(
      '${ApiConfig.auth}/login',
      body: {
        'phone': phone,
        'password': password,
      },
    );
    final user = User.fromJson(data);
    if (user.token != null) {
      await ApiClient.setToken(user.token);
    }
    return user;
  }

  static Future<User?> loadUser() async {
    try {
      final data = await ApiClient.get('${ApiConfig.auth}/me');
      return User.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    await ApiClient.setToken(null);
  }
}
