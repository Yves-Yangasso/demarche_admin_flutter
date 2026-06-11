import 'dart:convert';
import '../core/api_service.dart';

class ChatService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await _api.post("/ia/chatbot", {"message": message});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {"reponse": "Désolé, une erreur est survenue."};
  }
}
