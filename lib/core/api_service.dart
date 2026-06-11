import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:5001/api"; // Android Emulator address
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
    return response;
  }

  Future<void> loginOtp(String telephone) async {
    await post("/auth/otp/envoyer", {"telephone": telephone});
  }

  Future<void> loginEmail(String email) async {
    await post("/auth/email/envoyer", {"email": email});
  }

  Future<bool> verifyOtp(String telephone, String code) async {
    final response = await post("/auth/otp/verifier", {
      "telephone": telephone,
      "code": code
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      await _storage.write(key: 'refresh_token', value: data['refresh_token']);
      return true;
    }
    return false;
  }

  Future<bool> verifyEmailOtp(String email, String code) async {
    final response = await post("/auth/email/verifier", {
      "email": email,
      "code": code
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      await _storage.write(key: 'refresh_token', value: data['refresh_token']);
      return true;
    }
    return false;
  }
}
