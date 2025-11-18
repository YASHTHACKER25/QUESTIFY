import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class UpdateDetailsLogic {
  final TokenService tokenService = TokenService();
  bool loading = true;
  String? errorMessage;

  List<String> predefinedSubjects = [];
  List<String> selectedSubjects = [];
  String? selectedState;

  final usernameController = TextEditingController();

  List<String> states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Delhi",
    "Puducherry",
    "Jammu and Kashmir",
    "Ladakh",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Lakshadweep",
  ];

  void dispose() {
    usernameController.dispose();
  }

  Future<void> loadInitialData({required VoidCallback onUpdate}) async {
    // Fetch predefined subjects without auth; no refresh needed here
    try {
      final subsResponse = await http.get(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/subjects'),
      );
      if (subsResponse.statusCode == 200) {
        final data = jsonDecode(subsResponse.body);
        predefinedSubjects = List<String>.from(
          data['subjects'].map((s) => s['name']),
        );
      }
    } catch (_) {}

    String? token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      errorMessage = "User not logged in";
      loading = false;
      onUpdate();
      return;
    }

    bool success = await _fetchUserDetails(token);
    if (!success) {
      // Try refresh token logic
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          await _fetchUserDetails(newToken);
          token = newToken;
        } else {
          errorMessage = "Session expired. Please login again.";
        }
      } else {
        errorMessage = "Session expired. Please login again.";
      }
    }

    loading = false;
    onUpdate();
  }

  Future<bool> _fetchUserDetails(String token) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/user/details',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        usernameController.text = userData['Username'] ?? '';
        selectedSubjects = (userData['Faviouratesubjects'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        selectedState = userData['State'];
        errorMessage = null;
        return true;
      } else if (response.statusCode == 401) {
        return false; // token expired
      } else {
        errorMessage = "Failed to load user details";
        return true; // don't retry
      }
    } catch (e) {
      errorMessage = "Network error: $e";
      return true; // don't retry
    }
  }

  Future<bool> updateDetails() async {
    errorMessage = null;
    final body = {
      "Username": usernameController.text.trim(),
      "Faviouratesubjects": selectedSubjects,
      "State": selectedState,
    };

    String? token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      errorMessage = "User not logged in";
      return false;
    }

    bool success = await _updateUserDetails(token, body);
    if (!success) {
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          return await _updateUserDetails(newToken, body);
        } else {
          errorMessage = "Session expired. Please login again.";
          return false;
        }
      } else {
        errorMessage = "Session expired. Please login again.";
        return false;
      }
    }
    return true;
  }

  Future<bool> _updateUserDetails(
    String token,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          'https://questify-backend-8zi5.onrender.com/api/user/editdetails',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        errorMessage = null;
        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        final data = jsonDecode(response.body);
        errorMessage = data['message'] ?? "Update failed";
        return true;
      }
    } catch (e) {
      errorMessage = "Network error: $e";
      return true;
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
