import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class ProfileLogic {
  final TokenService tokenService = TokenService();
  Map<String, dynamic>? userData;
  bool loading = true;
  String error = '';

  Future<void> fetchUserDetails({
    required void Function() onUpdate,
    required void Function(String) onErrorRedirect,
  }) async {
    loading = true;
    onUpdate();

    String? token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      onErrorRedirect('User not logged in');
      loading = false;
      onUpdate();
      return;
    }

    bool success = await _fetchWithToken(token, onUpdate, onErrorRedirect);

    if (!success) {
      // Try refreshing token
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          token = newToken;
          await _fetchWithToken(token, onUpdate, onErrorRedirect);
        } else {
          onErrorRedirect('Session expired. Please login again.');
        }
      } else {
        onErrorRedirect('Session expired. Please login again.');
      }
    }

    loading = false;
    onUpdate();
  }

  Future<bool> _fetchWithToken(
    String token,
    void Function() onUpdate,
    void Function(String) onErrorRedirect,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/user/details',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        userData = json.decode(response.body);
        onUpdate();
        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        onErrorRedirect(
          'Error loading profile details: ${response.statusCode}',
        );
        return true; // Stop further attempts
      }
    } catch (e) {
      onErrorRedirect('Network error: $e');
      return true; // Stop further attempts
    }
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 &&
          data['accessToken'] != null &&
          data['refreshToken'] != null) {
        await tokenService.saveTokens(
          data['accessToken'],
          data['refreshToken'],
        );
        return data['accessToken'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? formatSubjects(dynamic subjects) {
    if (subjects == null) return null;
    if (subjects is List) {
      return subjects.join(', ');
    }
    return subjects.toString();
  }
}
