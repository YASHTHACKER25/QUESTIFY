import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileImageLogic {
  final _storage = const FlutterSecureStorage();

  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    String? accessToken = await _storage.read(key: 'accessToken');
    if (accessToken == null) return null;

    var success = await _uploadWithToken(imageFile, accessToken);
    if (success != null) return success;

    // Try to refresh token and upload again if failed due to 401
    String? refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken != null) {
      final newAccessToken = await _refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        return await _uploadWithToken(imageFile, newAccessToken);
      }
    }
    return null;
  }

  Future<String?> _uploadWithToken(File imageFile, String accessToken) async {
    var uri = Uri.parse(
      'https://questify-backend-8zi5.onrender.com/api/user/profile/avatar',
    );
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken';

    request.files.add(
      await http.MultipartFile.fromPath('avatar', imageFile.path),
    );
    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = jsonDecode(respStr);
      if (jsonResp['success'] == true) {
        return jsonResp['avatarUrl'] as String?;
      }
    } else if (response.statusCode == 401) {
      // Unauthorized - token expired
      return null;
    }
    return null;
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
        // Save new tokens to storage
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        return data['accessToken'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
