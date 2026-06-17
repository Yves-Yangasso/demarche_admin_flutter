import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/network/failure.dart';
import '../../domain/repositories/iia_repository.dart';

class IARepositoryImpl implements IIARepository {
  final ApiClient _apiClient;

  IARepositoryImpl(this._apiClient);

  @override
  Future<String> getChatbotResponse(String message) async {
    try {
      final response = await _apiClient.post("/ia/chatbot", {"message": message});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reponse'] ?? data['message'] ?? "Désolé, je n'ai pas pu comprendre votre demande.";
      }
      throw ServerFailure("Erreur lors de la communication avec le chatbot.");
    } catch (e) {
      final lowerMsg = message.toLowerCase();
      if (lowerMsg.contains("bonjour") || lowerMsg.contains("salut")) {
        return "Bonjour ! Je suis l'Assistant Citoyen SunuDekk. Comment puis-je vous aider aujourd'hui ?";
      } else if (lowerMsg.contains("passeport") || lowerMsg.contains("cni") || lowerMsg.contains("identité")) {
        return "Pour toute demande de pièce d'identité, veuillez vous rendre dans la rubrique 'Nouvelle Démarche' > 'Police Nationale'.";
      } else if (lowerMsg.contains("naissance") || lowerMsg.contains("mariage") || lowerMsg.contains("deces")) {
        return "Les actes d'état civil peuvent être demandés via votre mairie. Sélectionnez 'Nouvelle Démarche' > 'Mairie' de votre région.";
      } else if (lowerMsg.contains("suivi") || lowerMsg.contains("état") || lowerMsg.contains("avancement")) {
        return "Vous pouvez suivre l'état de vos dossiers dans l'onglet 'Mes Démarches'.";
      } else {
        return "Mode hors-ligne : Je ne suis pas connecté au serveur d'Intelligence Artificielle pour analyser cette demande, mais n'hésitez pas à explorer les démarches disponibles depuis l'écran d'accueil.";
      }
    }
  }

  @override
  Future<List<dynamic>> getAnomalies() async {
    try {
      final response = await _apiClient.get("/ia/anomalies");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ServerFailure("Impossible de récupérer les anomalies.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<Map<String, dynamic>> calculatePriority({
    required String description,
    required int typeDemarcheId,
    required DateTime dateSoumission,
  }) async {
    try {
      final response = await _apiClient.post("/ia/priorite", {
        "description": description,
        "type_demarche_id": typeDemarcheId,
        "date_soumission": dateSoumission.toIso8601String(),
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ServerFailure("Impossible de calculer la priorité.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }
}
