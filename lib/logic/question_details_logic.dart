import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../services/token_service.dart';

class QuestionDetailsLogic {
  Map<String, dynamic>? question;
  List<dynamic> answers = [];
  bool isLoading = true;
  bool? isAdmin;
  bool? isOwner;

  final Set<int> _expandedIndices = {};
  String? currentUserId;

  final Map<String, bool> showComments = {};
  final Map<String, TextEditingController> commentControllers = {};
  final Map<String, TextEditingController> editControllers = {};

  final TokenService _tokenService = TokenService();

  bool isExpanded(int index) => _expandedIndices.contains(index);
  void toggleExpanded(int index) => _expandedIndices.contains(index)
      ? _expandedIndices.remove(index)
      : _expandedIndices.add(index);

  // ===============================================================
  // 🔄 UNIVERSAL TOKEN HANDLER
  // ===============================================================
  Future<http.Response?> _authenticatedRequest(
    Future<http.Response> Function(String token) requestFn,
  ) async {
    String? token = await _tokenService.getAccessToken();
    if (token == null) {
      debugPrint('⚠️ No access token found.');
      return null;
    }

    http.Response response = await requestFn(token);

    // 🔁 If token expired → refresh and retry
    if (response.statusCode == 401) {
      debugPrint('⚠️ Access token expired, trying refresh token...');
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          token = newToken;
          response = await requestFn(token);
        } else {
          debugPrint('🚫 Token refresh failed');
        }
      }
    }
    return response;
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      debugPrint('🔄 Refreshing access token...');
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
        debugPrint('✅ Token refreshed successfully.');
        return data['accessToken'];
      } else {
        debugPrint('🚫 Token refresh failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      return null;
    }
  }

  // ===============================================================
  // 🟢 LOAD QUESTION DETAILS
  // ===============================================================
  Future<void> loadQuestionDetails(String questionId) async {
    isLoading = true;
    _clearData();

    final response = await _authenticatedRequest(
      (token) => http.get(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/question/display/$questionId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response != null && response.statusCode == 200) {
      final data = json.decode(response.body);
      question = data['question'];
      answers = List<dynamic>.from(question?['answers'] ?? []);
      debugPrint('✅ Question details loaded.');
    } else {
      debugPrint('🚫 Failed to load question details.');
    }

    await loadCurrentUser();
    isLoading = false;
  }

  Future<void> loadCurrentUser() async {
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      try {
        final decoded = JwtDecoder.decode(token);
        currentUserId = decoded['id'] ?? decoded['_id'] ?? decoded['userId'];
      } catch (_) {
        currentUserId = null;
      }
    }
  }

  bool isQuestionOwner() {
    return question?['userId']?['_id'] == currentUserId ||
        question?['userId'] == currentUserId;
  }

  bool isAnswerOwner(Map<String, dynamic> answer) {
    final userField = answer['userId'];
    if (userField == null) return false;
    if (userField is Map<String, dynamic>) {
      return userField['_id'] == currentUserId;
    } else if (userField is String) {
      return userField == currentUserId;
    }
    return false;
  }

  Future<bool> isAdminUser() async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) return false;
      final decoded = JwtDecoder.decode(token);
      final role = decoded['role'] ?? decoded['userType'];
      return role == 'admin';
    } catch (_) {
      return false;
    }
  }

  // ===============================================================
  // 💬 COMMENTS
  // ===============================================================
  Future<List<dynamic>> fetchComments(String answerId) async {
    final res = await _authenticatedRequest(
      (token) => http.get(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/comment/list/$answerId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    if (res != null && res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  Future<void> addComment(String answerId, BuildContext context) async {
    final controller = commentControllers.putIfAbsent(
      answerId,
      () => TextEditingController(),
    );
    final content = controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Comment cannot be empty")));
      return;
    }

    final res = await _authenticatedRequest(
      (token) => http.post(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/comment/create',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'answerId': answerId, 'content': content}),
      ),
    );

    if (res != null && res.statusCode == 200) {
      controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment added successfully")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add comment")));
    }
  }

  Future<void> editComment(String commentId, String newText) async {
    if (newText.trim().isEmpty) return;
    await _authenticatedRequest(
      (token) => http.put(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/comment/edit/$commentId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': newText}),
      ),
    );
  }

  Future<void> deleteComment(String commentId) async {
    await _authenticatedRequest(
      (token) => http.delete(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/comment/delete/$commentId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  // ===============================================================
  // 📩 RESPONSE (helpful / not helpful)
  // ===============================================================
  Future<void> sendResponse(String answerId, String? response) async {
    final res = await _authenticatedRequest(
      (token) => http.post(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/response'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'answerid': answerId, 'response': response}),
      ),
    );

    if (res != null && res.statusCode == 200) {
      final data = json.decode(res.body);
      final index = answers.indexWhere((a) => a['_id'] == answerId);
      if (index != -1) {
        answers[index]['helpfulCount'] = data['helpful'] ?? 0;
        answers[index]['notHelpfulCount'] = data['nothelpful'] ?? 0;
        answers[index]['userResponse'] = response;
      }
    }
  }

  // ===============================================================
  // ❌ DELETE ANSWER / QUESTION
  // ===============================================================
  Future<bool> deleteAnswer(String answerId) async {
    final res = await _authenticatedRequest(
      (token) => http.delete(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/answer/delete/$answerId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return res != null && res.statusCode == 200;
  }

  Future<bool> deleteQuestion(String questionId) async {
    final res = await _authenticatedRequest(
      (token) => http.delete(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/question/delete/$questionId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return res != null && res.statusCode == 200;
  }

  // ===============================================================
  // 🚨 REPORT FEATURE
  // ===============================================================
  Future<void> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    required BuildContext context,
  }) async {
    if (reason.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Reason cannot be empty")));
      return;
    }

    final res = await _authenticatedRequest(
      (token) => http.post(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/report'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'targetType': targetType,
          'targetId': targetId,
          'reason': reason,
        }),
      ),
    );

    if (res != null && res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to submit report")));
    }
  }

  // ===============================================================
  // CLEANUP
  // ===============================================================
  void _clearData() {
    question = null;
    answers = [];
  }

  void dispose() {}
}
