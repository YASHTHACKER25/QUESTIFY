import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class UpdateEmailLogic {
  final TokenService tokenService = TokenService();

  final emailController = TextEditingController();

  String? errorMessage;
  String? userId;
  String? newEmail;

  void dispose() {
    emailController.dispose();
  }

  Future<bool> sendUpdateEmailRequest() async {
    errorMessage = null;
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errorMessage = 'Please enter the new email';
      return false;
    }

    String? token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      errorMessage = 'User not logged in';
      return false;
    }

    bool success = await _sendRequestWithToken(token, email);

    if (!success) {
      // Try refresh token if first attempt failed
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          success = await _sendRequestWithToken(newToken, email);
        } else {
          errorMessage = 'Session expired. Please login again.';
        }
      } else {
        errorMessage = 'Session expired. Please login again.';
      }
    }

    return success;
  }

  Future<bool> _sendRequestWithToken(String token, String email) async {
    try {
      final response = await http.put(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/user/updateemail',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'Email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        userId = data['userid'].toString();
        newEmail = data['newEmail'];
        return true;
      } else if (response.statusCode == 401) {
        // Unauthorized -> token invalid, signal failure for retry
        return false;
      } else {
        errorMessage = data['message'] ?? 'Failed to send OTP';
        return true; // Stop retrying for other errors
      }
    } catch (e) {
      errorMessage = 'Network error: $e';
      return true; // Stop retries on network error
    }
  }

  Future<bool> verifyOtp(String otp) async {
    errorMessage = null;

    if (otp.isEmpty) {
      errorMessage = 'Please enter the OTP';
      return false;
    }

    String? token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      errorMessage = 'User not logged in';
      return false;
    }

    bool success = await _verifyOtpWithToken(token, otp);

    if (!success) {
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          success = await _verifyOtpWithToken(newToken, otp);
        } else {
          errorMessage = 'Session expired. Please login again.';
        }
      } else {
        errorMessage = 'Session expired. Please login again.';
      }
    }

    return success;
  }

  Future<bool> _verifyOtpWithToken(String token, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/user/updateemail/verifyotp',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userid': userId, 'otp': otp, 'newEmail': newEmail}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        errorMessage = data['message'] ?? 'OTP verification failed';
        return true; // Stop retrying on other errors
      }
    } catch (e) {
      errorMessage = 'Network error: $e';
      return true; // Stop retries on network error
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
}
