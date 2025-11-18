import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AnswersGivenLogic {
  final storage = const FlutterSecureStorage();
  List<dynamic> answers = [];
  bool loading = false;

  Future<void> fetchData({
    required Function onUpdate,
    required Function(String) onErrorRedirect,
  }) async {
    loading = true;
    onUpdate();

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      onErrorRedirect('No access token found. Please login again.');
      loading = false;
      onUpdate();
      return;
    }

    bool success = await _fetchWithToken(accessToken);

    if (!success) {
      String? refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken != null) {
        String? newAccessToken = await _refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await _fetchWithToken(newAccessToken);
        } else {
          onErrorRedirect('Session expired. Please login again.');
          answers = [];
        }
      } else {
        onErrorRedirect('Session expired. Please login again.');
        answers = [];
      }
    }

    loading = false;
    onUpdate();
  }

  Future<bool> _fetchWithToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/user/answers',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        answers = data['answers'] ?? [];
        return true;
      } else if (response.statusCode == 401) {
        return false;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          data['accessToken'] != null &&
          data['refreshToken'] != null) {
        await storage.write(key: 'accessToken', value: data['accessToken']);
        await storage.write(key: 'refreshToken', value: data['refreshToken']);
        return data['accessToken'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
