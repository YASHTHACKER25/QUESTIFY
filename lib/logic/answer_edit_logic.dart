import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class AnswerEditLogic {
  final String answerId;
  final String token;

  final formKey = GlobalKey<FormState>();
  final TextEditingController answerController;
  bool isSubmitting = false;
  final TokenService _tokenService = TokenService();

  AnswerEditLogic({
    required this.answerId,
    required this.token,
    required String initialContent,
  }) : answerController = TextEditingController(text: initialContent);

  Future<String> submitEditAnswer() async {
    if (!formKey.currentState!.validate()) {
      return "Please enter an answer.";
    }
    isSubmitting = true;

    String? message = await _submitEditWithToken(token);

    if (message == null) {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          message = await _submitEditWithToken(newToken);
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
    return message ?? "Something went wrong.";
  }

  Future<String?> _submitEditWithToken(String token) async {
    final url = Uri.parse(
      "https://questify-backend-8zi5.onrender.com/api/answer/edit/$answerId",
    );

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"content": answerController.text.trim()}),
      );

      if ([200, 400, 403].contains(response.statusCode)) {
        final data = json.decode(response.body);
        if (data is Map && data["message"] is String) {
          return data["message"] as String;
        }
        return "Something went wrong.";
      } else if (response.statusCode == 401) {
        return null;
      } else {
        print('Answer edit failed: ${response.statusCode} ${response.body}');
        return "Something went wrong.";
      }
    } catch (e) {
      print('Network error in answer edit: $e');
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
