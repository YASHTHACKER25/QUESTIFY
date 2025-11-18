import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class GiveAnswerLogic {
  final formKey = GlobalKey<FormState>();
  final TextEditingController answerController = TextEditingController();

  bool isSubmitting = false;
  final TokenService _tokenService = TokenService();

  Future<String> submitAnswer(String questionId, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return "Please enter an answer.";
    }
    isSubmitting = true;

    String? token = await _tokenService.getAccessToken();

    // First attempt
    String? message = await _submitWithToken(token, questionId);
    if (message == null) {
      // Token may be expired, try refreshing
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          token = newToken;
          message = await _submitWithToken(token, questionId);
        } else {
          isSubmitting = false;
          return "Session expired. Please login again.";
        }
      } else {
        isSubmitting = false;
        return "Session expired. Please login again.";
      }
    }

    isSubmitting = false;
    // If backend didn’t return a message, fall back to generic text
    return message ?? "Something went wrong.";
  }

  Future<String?> _submitWithToken(String? token, String questionId) async {
    if (token == null) return null;

    final url = Uri.parse(
      "https://questify-backend-8zi5.onrender.com/api/answer/create",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "content": answerController.text.trim(),
          "questionid": questionId,
        }),
      );

      // Return the exact backend message for both success and validation errors
      if (response.statusCode == 200 ||
          response.statusCode == 400 ||
          response.statusCode == 403) {
        final data = json.decode(response.body);
        if (data is Map && data["message"] is String) {
          return data["message"] as String;
        }
        return "Something went wrong.";
      } else if (response.statusCode == 401) {
        // Token expired, signal retry
        return null;
      } else {
        return "Something went wrong.";
      }
    } catch (_) {
      return "Network error. Please try again.";
    }
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
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
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? validateAnswer(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Answer cannot be empty.";
    }
    return null;
  }

  void dispose() {
    answerController.dispose();
  }
}
