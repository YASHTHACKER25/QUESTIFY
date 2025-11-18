import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class NotificationLogic {
  final TokenService _tokenService = TokenService();
  List<Map<String, dynamic>> notifications = [];
  bool loading = true;

  /// Fetch notifications with automatic token refresh
  Future<void> fetchNotifications({
    required void Function() onUpdate,
    required void Function(String) onErrorRedirect,
  }) async {
    loading = true;
    onUpdate();

    String? token = await _tokenService.getAccessToken();
    if (token == null) {
      onErrorRedirect('User not logged in');
      loading = false;
      onUpdate();
      return;
    }

    final success = await _fetchWithToken(token, onUpdate, onErrorRedirect);

    if (!success) {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        final refreshed = await _refreshAccessToken(refreshToken);
        if (refreshed != null) {
          token = refreshed;
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

  /// Helper: fetch with token
  Future<bool> _fetchWithToken(
    String token,
    void Function() onUpdate,
    void Function(String) onErrorRedirect,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/notifications',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔥 Always convert to List<Map<String, dynamic>>
        notifications = List<Map<String, dynamic>>.from(
          data['notifications'] ?? [],
        );

        if (kDebugMode) {
          print("Notifications fetched: ${notifications.length}");
          print(notifications);
        }

        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        onErrorRedirect('Error loading notifications: ${response.statusCode}');
        return true;
      }
    } catch (e) {
      onErrorRedirect('Network error: $e');
      return true;
    }
  }

  /// Refresh access token
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
        return data['accessToken'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(String id) async {
    String? token = await _tokenService.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/notifications/$id/read',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
