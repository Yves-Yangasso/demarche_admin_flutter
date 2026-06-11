import 'dart:convert';
import '../core/network/api_client.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await _apiClient.post("/ia/chatbot", {"message": message});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {"reponse": "Désolé, une erreur est survenue."};
  }
}
