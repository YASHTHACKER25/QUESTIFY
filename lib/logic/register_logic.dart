import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterLogic {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  List<String> selectedSubjects = [];
  List<String> predefinedSubjects = []; // fetched dynamically
  String? selectedState;

  List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  String? errorMessage;
  String? registeredId;

  void togglePasswordVisibility() => isPasswordVisible = !isPasswordVisible;

  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Fetch subjects from backend
  Future<void> fetchSubjects() async {
    try {
      final response = await http.get(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/subjects'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        predefinedSubjects = List<String>.from(
          data['subjects'].map((s) => s['name']),
        );
      } else {
        print("Failed to fetch subjects. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch subjects: $e");
    }
  }

  // Register API
  Future<bool> registerUser() async {
    final body = {
      "Username": usernameController.text.trim(),
      "Email": emailController.text.trim(),
      "Password": passwordController.text,
      "Faviouratesubjects": selectedSubjects,
      "State": selectedState,
    };

    try {
      final response = await http.post(
        Uri.parse('https://questify-backend-8zi5.onrender.com/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        registeredId = data['userid'].toString(); // ensure string
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage = data['message'] ?? "Registration failed";
        return false;
      }
    } catch (e) {
      errorMessage = "Network or server error: $e";
      return false;
    }
  }
}
