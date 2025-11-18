import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class AdminUserDetailsLogic {
  final TokenService _tokenService = TokenService();
  final String baseUrl = 'https://questify-backend-8zi5.onrender.com/api/admin';

  /// Fetch user's questions / answers / comments
  Future<List<Map<String, dynamic>>> fetchUserContent(
    String type,
    String userId,
  ) async {
    final endpoint = '/user/$userId/$type';
    String? token = await _tokenService.getAccessToken();
    if (token == null) {
      print('⚠️ No access token found');
      return [];
    }

    final successData = await _fetchWithToken(type, userId, token);
    if (successData != null) return successData;

    // Token expired → try refresh
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken != null) {
      final refreshed = await _refreshAccessToken(refreshToken);
      if (refreshed != null) {
        return await _fetchWithToken(type, userId, refreshed) ?? [];
      }
    }

    print('❌ Unable to refresh token, returning empty list.');
    return [];
  }

  Future<List<Map<String, dynamic>>?> _fetchWithToken(
    String type,
    String userId,
    String token,
  ) async {
    final endpoint = '$baseUrl/user/$userId/$type';
    print('🌍 [REQUEST] GET $endpoint');

    try {
      final res = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📦 [RESPONSE] /user/$userId/$type → ${res.statusCode}');

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else if (res.statusCode == 401) {
        print('⚠️ Token expired while fetching $type');
        return null;
      } else {
        print('❌ Unexpected error: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Network error fetching $type: $e');
      return [];
    }
  }

  /// Delete user's question, answer, or comment
  Future<bool> deleteUserContent(String type, String id) async {
    final endpoint = '/$type/$id';
    String? token = await _tokenService.getAccessToken();
    if (token == null) {
      print('⚠️ No access token for delete');
      return false;
    }

    final success = await _deleteWithToken(endpoint, token);
    if (success != null) return success;

    // Token expired → refresh
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken != null) {
      final refreshed = await _refreshAccessToken(refreshToken);
      if (refreshed != null) {
        return await _deleteWithToken(endpoint, refreshed) ?? false;
      }
    }

    print('❌ Token refresh failed, delete aborted.');
    return false;
  }

  Future<bool?> _deleteWithToken(String endpoint, String token) async {
    print('🗑️ [REQUEST] DELETE $baseUrl$endpoint');
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('📦 [RESPONSE] DELETE $endpoint → ${res.statusCode}');

      if (res.statusCode == 200) return true;
      if (res.statusCode == 401) return null; // expired token
      return false;
    } catch (e) {
      print('❌ Delete failed: $e');
      return false;
    }
  }

  /// 🔄 Refresh Access Token (same logic as Homepage)
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
        await _tokenService.saveTokens(
          data['accessToken'],
          data['refreshToken'],
        );
        print('✅ Token refreshed successfully');
        return data['accessToken'];
      } else {
        print('❌ Token refresh failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Network error while refreshing token: $e');
      return null;
    }
  }
}
