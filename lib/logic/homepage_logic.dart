import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class HomepageLogic {
  final TokenService _tokenService = TokenService();
  List<dynamic> questions = [];
  bool loading = false;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 20;

  List<String> subjects = [];

  Future<void> fetchData({
    required void Function() onUpdate,
    required void Function(String) onErrorRedirect,
    bool loadMore = false,
  }) async {
    if (loading) return;
    loading = true;
    onUpdate();

    String? token = await _tokenService.getAccessToken();
    if (token == null) {
      onErrorRedirect('User not logged in');
      loading = false;
      onUpdate();
      return;
    }

    final success = await _fetchWithToken(
      token,
      onUpdate,
      onErrorRedirect,
      loadMore,
    );

    if (!success) {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        final refreshed = await _refreshAccessToken(refreshToken);
        if (refreshed != null) {
          token = refreshed;
          await _fetchWithToken(token, onUpdate, onErrorRedirect, loadMore);
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

  Future<bool> _fetchWithToken(
    String token,
    void Function() onUpdate,
    void Function(String) onErrorRedirect,
    bool loadMore,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/homepage?page=$currentPage&limit=$limit',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newQuestions = data['questions'] ?? [];

        if (loadMore) {
          questions.addAll(newQuestions);
        } else {
          questions = newQuestions;
        }

        hasMore = currentPage < (data['totalPages'] ?? 1);
        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        onErrorRedirect('Error loading homepage: ${response.statusCode}');
        return true;
      }
    } catch (e) {
      onErrorRedirect('Network error: $e');
      return true;
    }
  }

  void loadNextPage({
    required void Function() onUpdate,
    required void Function(String) onErrorRedirect,
  }) {
    if (hasMore && !loading) {
      currentPage++;
      fetchData(
        onUpdate: onUpdate,
        onErrorRedirect: onErrorRedirect,
        loadMore: true,
      );
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

  Future<void> fetchSubjects({
    required void Function() onUpdate,
    required void Function(String) onErrorRedirect,
  }) async {
    const url = 'https://questify-backend-8zi5.onrender.com/api/subjects';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        subjects = List<String>.from(data['subjects'].map((s) => s['name']));
        onUpdate();
      } else {
        onErrorRedirect("Failed to fetch subjects: ${response.statusCode}");
      }
    } catch (e) {
      onErrorRedirect("Network error: $e");
    }
  }

  void resetPagination() {
    currentPage = 1;
    hasMore = true;
    questions.clear();
  }
}
