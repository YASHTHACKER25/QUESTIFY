import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ApiClient {
  final AuthService _auth;

  ApiClient(this._auth);

  Future<http.Response> get(String path) async {
    var token = await _auth.getValidAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('${_auth.baseUrl}$path');
    var res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 401) {
      // Access token might have just expired—try once more
      token = await _auth.getValidAccessToken();
      if (token != null) {
        res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
      }
    }
    return res;
  }

  // Add post/put/delete helpers in the same style if needed.
}
