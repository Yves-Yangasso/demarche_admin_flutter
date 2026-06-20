import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl = Platform.isAndroid
      ? "https:/sunudek-api-stag.djazael.com/api" // For Android emulator to reach localhost
      : "http://localhost:5001/api";

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

  Future<Map<String, String>> _getAuthHeader() async {
    String? token = await getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
  }

  /// GET sans header Authorization - pour les endpoints publics (suivi, verify).
  Future<http.Response> getPublic(String endpoint) async {
    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: const {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> patch(
      String endpoint, Map<String, dynamic> data) async {
    return await http.patch(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    return await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
  }

  /// Upload un fichier via multipart/form-data.
  /// [fieldName] : nom du champ fichier (défaut: 'file')
  /// [extraFields] : champs texte supplémentaires à joindre
  Future<http.Response> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? extraFields,
  }) async {
    final uri = Uri.parse("$baseUrl$endpoint");
    final request = http.MultipartRequest('POST', uri);

    // Headers d'authentification (sans Content-Type - géré par multipart)
    final authHeaders = await _getAuthHeader();
    request.headers.addAll(authHeaders);

    // Fichier
    final file = await http.MultipartFile.fromPath(fieldName, filePath);
    request.files.add(file);

    // Champs supplémentaires
    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }
}
