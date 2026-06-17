abstract class IIARepository {
  Future<String> getChatbotResponse(String message);
  Future<List<dynamic>> getAnomalies();
  Future<Map<String, dynamic>> calculatePriority({
    required String description,
    required int typeDemarcheId,
    required DateTime dateSoumission,
  });
}
