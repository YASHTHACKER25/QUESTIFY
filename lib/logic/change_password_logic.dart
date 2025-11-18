import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Assumes you have a way to get auth token (e.g. from secure storage)
import '../services/token_service.dart';

class ChangePasswordLogic {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TokenService _tokenService = TokenService();

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');
    if (!regex.hasMatch(value)) {
      return 'Password must be 8+ chars, include uppercase, lowercase, number, special char';
    }
    return null;
  }

  String? confirmPasswordValidator(String? confirm, String password) {
    if (confirm == null || confirm.isEmpty) return 'Confirm your password';
    if (confirm != password) return 'Passwords do not match';
    return null;
  }

  /// Main function to change password with token refresh handling
  Future<Map<String, dynamic>> changePassword(BuildContext context) async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    String? token = await _tokenService.getAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    bool success = await _tryChangePassword(token, oldPassword, newPassword);
    if (success) {
      return {'success': true, 'message': 'Password changed successfully'};
    }

    // Try refreshing token if first attempt failed (e.g., token expired)
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken != null) {
      final newAccessToken = await _refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        final retrySuccess = await _tryChangePassword(
          newAccessToken,
          oldPassword,
          newPassword,
        );
        if (retrySuccess) {
          return {'success': true, 'message': 'Password changed successfully'};
        } else {
          return {'success': false, 'message': 'Failed to change password'};
        }
      } else {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Session expired. Please login again.',
      };
    }
  }

  /// Helper: Attempt password change with provided token
  Future<bool> _tryChangePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/password/reset',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'Password': oldPassword, 'newpassword': newPassword}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Token invalid or expired
        return false;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Change password failed');
      }
    } catch (e) {
      throw Exception(e.toString());
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

      final data = jsonDecode(response.body);

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

  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}
