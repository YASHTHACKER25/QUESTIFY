import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordEmailLogic {
  final TextEditingController emailController = TextEditingController();

  Future<Map<String, dynamic>> submitEmail(BuildContext context) async {
    final email = emailController.text.trim();
    final url = Uri.parse(
      'https://questify-backend-8zi5.onrender.com/api/password/forgot',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // On success, navigate to OTP page with userid and email
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {
            'userid': data['userid'],
            'email': data['email'],
            'isRegistering': false,
            'isForPasswordReset': true,
          },
        );
        return {'success': true};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  void dispose() {
    emailController.dispose();
  }
}
