import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl = Platform.isAndroid 
      ? "https://sunudekk-api.djazael.com/api" 
      //? "http://192.168.1.14:5001/api"
      : "http://192.168.1.14:5001/api";

  
     

  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> saveToken(String token, String refreshToken) async {
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
  }
}
