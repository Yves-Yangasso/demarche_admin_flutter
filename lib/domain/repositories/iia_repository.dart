abstract class IIARepository {
  /// [lang] : code langue (fr | en | wo) transmis au backend pour le prompt système.
  Future<String> getChatbotResponse(String message, {String lang = 'fr'});
  Future<List<dynamic>> getAnomalies();
  Future<Map<String, dynamic>> calculatePriority({
    required String description,
    required int typeDemarcheId,
    required DateTime dateSoumission,
  });
}
