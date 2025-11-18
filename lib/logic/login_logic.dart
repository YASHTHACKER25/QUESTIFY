// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// //
// // import '../services/token_service.dart'; // <-- added for token storage
// //
// // class LoginLogic {
// //   final TextEditingController emailController = TextEditingController();
// //   final TextEditingController passwordController = TextEditingController();
// //
// //   bool isPasswordVisible = false;
// //
// //   // ✅ new: store tokens
// //   final TokenService _tokenService = TokenService();
// //
// //   void togglePasswordVisibility() {
// //     isPasswordVisible = !isPasswordVisible;
// //   }
// //
// //   Future<Map<String, dynamic>> loginUser() async {
// //     final url = Uri.parse('http://10.0.2.2:8000/api/login');
// //
// //     final body = {
// //       'Email': emailController.text.trim(),
// //       'Password': passwordController.text,
// //     };
// //
// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(body),
// //       );
// //
// //       final data = jsonDecode(response.body);
// //
// //       if (response.statusCode == 200) {
// //         // ✅ Save tokens if backend provides them
// //         if (data["accessToken"] != null && data["refreshToken"] != null) {
// //           await _tokenService.saveTokens(
// //             data["accessToken"],
// //             data["refreshToken"],
// //           );
// //         }
// //
// //         return {
// //           'success': true,
// //           'userid': data['userid'],
// //           'email': data['email'],
// //           'message': data['message'],
// //         };
// //       } else {
// //         return {'success': false, 'message': data['message'] ?? 'Login failed'};
// //       }
// //     } catch (e) {
// //       return {'success': false, 'message': e.toString()};
// //     }
// //   }
// //
// //   void dispose() {
// //     emailController.dispose();
// //     passwordController.dispose();
// //   }
// // }
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../services/token_service.dart'; // <-- added for token storage
//
// class LoginLogic {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   bool isPasswordVisible = false;
//
//   // ✅ new: store tokens
//   final TokenService _tokenService = TokenService();
//
//   void togglePasswordVisibility() {
//     isPasswordVisible = !isPasswordVisible;
//   }
//
//   Future<Map<String, dynamic>> loginUser() async {
//     //final url = Uri.parse('https://questify-backend-8zi5.onrender.com/api/login');
//     final url = Uri.parse('http://127.0.0.1:8000/api/login');
//
//     final body = {
//       'Email': emailController.text.trim(),
//       'Password': passwordController.text,
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200) {
//         // ✅ Save tokens if backend provides them
//         if (data["accessToken"] != null && data["refreshToken"] != null) {
//           await _tokenService.saveTokens(
//             data["accessToken"],
//             data["refreshToken"],
//           );
//         }
//
//         return {
//           'success': true,
//           'userid': data['userid'],
//           'email': data['email'],
//           'admin': data['admin'] ?? false, // <-- Added admin flag here
//           'message': data['message'],
//         };
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Login failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': e.toString()};
//     }
//   }
//
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/token_service.dart';

class LoginLogic {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  final TokenService _tokenService = TokenService();

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
  }

  /// Automatic server URL selection
  String getServerUrl() {
    if (Platform.isAndroid) {
      // Physical Android device via USB ADB forwarding
      return 'https://questify-backend-8zi5.onrender.com/api/login';
    } else if (Platform.isIOS) {
      // iOS simulator
      return 'http://localhost:8000/api/login';
    } else {
      // Desktop or fallback
      return 'https://questify-backend-8zi5.onrender.com/api/login';
    }
  }

  Future<Map<String, dynamic>> loginUser() async {
    final url = Uri.parse(getServerUrl());

    final body = {
      'Email': emailController.text.trim(),
      'Password': passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["accessToken"] != null && data["refreshToken"] != null) {
          await _tokenService.saveTokens(
            data["accessToken"],
            data["refreshToken"],
          );
        }

        return {
          'success': true,
          'userid': data['userid'],
          'email': data['email'],
          'admin': data['admin'] ?? false,
          'message': data['message'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
