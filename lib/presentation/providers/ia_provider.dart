import 'package:flutter/material.dart';
import '../../domain/repositories/iia_repository.dart';

class IAProvider with ChangeNotifier {
  final IIARepository _repository;

  IAProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final List<Map<String, dynamic>> _chatMessages = [];
  List<Map<String, dynamic>> get chatMessages => _chatMessages;

  Future<void> sendMessage(String message) async {
    _chatMessages.add({"role": "user", "content": message});
    notifyListeners();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getChatbotResponse(message);
      _chatMessages.add({"role": "assistant", "content": response});
    } catch (e) {
      _error = e.toString();
      _chatMessages.add({"role": "assistant", "content": "Erreur: $_error"});
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatMessages.clear();
    notifyListeners();
  }
}
