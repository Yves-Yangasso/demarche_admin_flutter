import '../../models/models.dart';

abstract class IDossierRepository {
  Future<List<Dossier>> getMesDossiers({bool forceRefresh = false});
  Future<List<Dossier>> getMesDossiersPagines(int page, int size);
  Future<List<dynamic>> getCategories();
  Future<List<dynamic>> getDemarches(int? categorieId);
}
