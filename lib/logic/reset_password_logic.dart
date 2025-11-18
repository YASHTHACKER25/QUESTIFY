import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class ResetPasswordLogic {
  final TokenService _tokenService = TokenService();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Password validation - at least 8 chars, uppercase, lowercase, number, special char
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';

    final password = value.trim();
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

    if (!regex.hasMatch(password)) {
      return 'Password must be at least 8 characters,\ninclude uppercase, lowercase, number, and special character';
    }

    return null;
  }

  // Confirm password validation matches password
  String? confirmPasswordValidator(String? confirm, String password) {
    if (confirm == null || confirm.isEmpty) return 'Confirm your password';
    if (confirm != password) return 'Passwords do not match';
    return null;
  }

  Future<Map<String, dynamic>> resetPassword(
    BuildContext context,
    String email,
    String token,
  ) async {
    final newPassword = passwordController.text.trim();

    bool success = await _tryResetPassword(context, email, token, newPassword);

    if (success) {
      // Success flow handled inside _tryResetPassword
      return {'success': true};
    }

    // Refresh token and retry if failed due to 401
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken != null) {
      final newToken = await _refreshAccessToken(refreshToken);
      if (newToken != null) {
        success = await _tryResetPassword(
          context,
          email,
          newToken,
          newPassword,
        );
        if (success) return {'success': true};
      }
    }
    return {'success': false, 'message': 'Reset failed or session expired'};
  }

  Future<bool> _tryResetPassword(
    BuildContext context,
    String email,
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse(
      'https://questify-backend-8zi5.onrender.com/api/password/set',
    );
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'Email': email, 'newpassword': newPassword}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/login');
        return true;
      } else if (response.statusCode == 401) {
        // token expired
        return false;
      } else {
        return false; // other error
      }
    } catch (e) {
      return false;
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
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
