import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class AdminLogic {
  final TokenService _tokenService = TokenService();
  final String baseUrl = 'https://questify-backend-8zi5.onrender.com/api/admin';

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> reports = [];

  Future<List<Map<String, dynamic>>> fetchUsers({
    required void Function() onUpdate,
    required void Function(String) onErrorRedirect,
  }) async {
    return await _fetchList('/users', 'users', onUpdate, onErrorRedirect);
  }

  Future<List<Map<String, dynamic>>> fetchReports({
    required void Function() onUpdate,
    required void Function(String) onErrorRedirect,
  }) async {
    return await _fetchList('/reports', 'reports', onUpdate, onErrorRedirect);
  }

  Future<bool> deleteItem(String endpoint) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) return false;

      final res = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('🗑️ DELETE $endpoint → ${res.statusCode}');
      return res.statusCode == 200;
    } catch (e) {
      print('❌ Delete failed: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchList(
    String endpoint,
    String type,
    void Function() onUpdate,
    void Function(String) onErrorRedirect,
  ) async {
    onUpdate();
    String? token = await _tokenService.getAccessToken();
    if (token == null) {
      onErrorRedirect('Login required');
      onUpdate();
      return [];
    }

    try {
      print('🌍 [REQUEST] GET $baseUrl$endpoint');
      final res = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('📦 [RESPONSE] $endpoint → ${res.statusCode}');

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (type == 'users') users = List<Map<String, dynamic>>.from(data);
        if (type == 'reports') reports = List<Map<String, dynamic>>.from(data);
        onUpdate();
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else if (res.statusCode == 401) {
        onErrorRedirect('Session expired');
      }
      onUpdate();
      return [];
    } catch (e) {
      print('❌ Fetch failed: $e');
      onUpdate();
      return [];
    }
  }

  // New method: fetch detailed report by ID
  Future<Map<String, dynamic>> fetchReportDetails(String reportId) async {
    final token = await _tokenService.getAccessToken();
    if (token == null) {
      throw Exception('Login required');
    }

    final res = await http.get(
      Uri.parse('$baseUrl/report/$reportId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to fetch report details');
    }
  }

  Future<void> logout() async {
    await _tokenService.clearTokens();
  }
}
