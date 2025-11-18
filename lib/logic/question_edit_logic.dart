import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class QuestionEditLogic {
  final Map<String, dynamic> questionData;
  final TokenService _tokenService = TokenService();

  QuestionEditLogic(this.questionData);

  Future<bool> updateQuestion(String newContent) async {
    String? token = await _tokenService.getAccessToken();
    final questionId = questionData['_id'];
    if (questionId == null || token == null || token.isEmpty) {
      print("Missing questionId or token");
      return false;
    }

    bool success = await _updateWithToken(token, questionId, newContent);
    if (success) return true;

    String? refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken != null) {
      String? newToken = await _refreshAccessToken(refreshToken);
      if (newToken != null) {
        return await _updateWithToken(newToken, questionId, newContent);
      }
    }

    return false;
  }

  Future<bool> _updateWithToken(
    String token,
    String questionId,
    String newContent,
  ) async {
    final url = Uri.parse(
      'https://questify-backend-8zi5.onrender.com/api/question/edit/$questionId',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': newContent}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        questionData['content'] = data['question']['content'];
        return true;
      } else if (response.statusCode == 401) {
        // Token expired
        return false;
      } else {
        print('Failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating question: $e');
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
}
