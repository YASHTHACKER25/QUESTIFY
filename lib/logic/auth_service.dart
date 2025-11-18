import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class AuthService {
  final TokenService _storage = TokenService();
  final String baseUrl; // e.g. 'https://questify-backend-8zi5.onrender.com'

  AuthService({required this.baseUrl});

  Future<String?> getValidAccessToken() async {
    final token = await _storage.getAccessToken();
    if (token == null || _isExpired(token)) {
      return await _refreshToken();
    }
    return token;
  }

  bool _isExpired(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'] as int;
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  Future<String?> _refreshToken() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) return null;

    final res = await http.post(
      Uri.parse('$baseUrl/api/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refresh}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.saveTokens(data['accessToken'], data['refreshToken']);
      return data['accessToken'];
    } else {
      await _storage.clearTokens();
      return null;
    }
  }

  /// ✅ Calls backend API to check if user is admin
  Future<bool> isAdmin(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/admin/isAdmin'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['isAdmin'] == true;
      } else {
        print("⚠️ Admin check failed with status ${res.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error checking admin status: $e");
      return false;
    }
  }
}
