import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class QuestionCreateLogic {
  final formKey = GlobalKey<FormState>();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController topicController = TextEditingController();

  /// Subjects fetched dynamically from the backend
  List<String> subjects = [];
  List<String> selectedSubjects = [];
  bool isSubmitting = false;

  /// Call this once (e.g. in initState of the page) to load subjects
  Future<void> fetchSubjects() async {
    try {
      final response = await http.get(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/subjects'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Expecting response like: { "subjects": [ { "name": "Math" }, ... ] }
        subjects = List<String>.from(data['subjects'].map((s) => s['name']));
      } else {
        debugPrint(
          "Failed to fetch subjects. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Failed to fetch subjects: $e");
    }
  }

  String? validateContent(String? val) {
    if (val == null || val.trim().isEmpty) return 'Content required';
    return null;
  }

  String? validateTopic(String? val) {
    if (val == null || val.trim().isEmpty) return 'Topic required';
    return null;
  }

  /// Submit question with token auto-refresh
  Future<String> submit(BuildContext context) async {
    if (!formKey.currentState!.validate() || selectedSubjects.isEmpty) {
      return 'Complete all fields and select subjects';
    }
    isSubmitting = true;

    final tokenService = TokenService();
    String? token = await tokenService.getAccessToken();
    if (token == null) {
      isSubmitting = false;
      return 'User not logged in';
    }

    final result = await _submitWithToken(token);

    if (!result['success']) {
      // Try refreshing token if first attempt failed
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          token = newToken;
          final retryResult = await _submitWithToken(token);
          isSubmitting = false;
          return retryResult['message'];
        } else {
          isSubmitting = false;
          return 'Session expired. Please login again.';
        }
      } else {
        isSubmitting = false;
        return 'Session expired. Please login again.';
      }
    }

    isSubmitting = false;
    return result['message'];
  }

  Future<Map<String, dynamic>> _submitWithToken(String token) async {
    final url = Uri.parse(
      "https://questify-backend-8zi5.onrender.com/api/question/create",
    );

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "content": contentController.text.trim(),
          "topic": topicController.text.trim(),
          "subject": selectedSubjects.isNotEmpty ? selectedSubjects.first : "",
        }),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Submitted successfully',
        };
      } else if (res.statusCode == 400) {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit',
        };
      }

      return {'success': false, 'message': 'Server error'};
    } catch (_) {
      return {'success': false, 'message': 'Network error'};
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
        await TokenService().saveTokens(
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

  Future<String?> showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void dispose() {
    contentController.dispose();
    topicController.dispose();
  }
}
