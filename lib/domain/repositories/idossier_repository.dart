import '../../models/models.dart';

abstract class IDossierRepository {
  Future<List<Dossier>> getMesDossiers({bool forceRefresh = false});
  Future<List<Dossier>> getMesDossiersPagines(int page, int size);
  Future<List<dynamic>> getCategories({int? organisationId});
  Future<List<dynamic>> getDemarches(int? categorieId, {int? organisationId});
  Future<Dossier> createDossier(Map<String, dynamic> data);
  Future<List<dynamic>> getOrganisations();
  Future<List<dynamic>> getDocumentsCriteres(int typeId);

  /// Récupère les messages d'un dossier
  Future<List<Map<String, dynamic>>> getMessages(int dossierId);

  /// Envoie un message sur le fil d'un dossier
  Future<Map<String, dynamic>> sendMessage(int dossierId, String contenu);

  /// Upload un document sur un dossier (multipart)
  Future<Map<String, dynamic>> uploadDocument(
    int dossierId,
    String filePath, {
    required String nom,
    String typeDocument = 'justificatif',
    bool estRequis = false,
  });
}
