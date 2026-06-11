import 'dart:convert';
import '../core/api_service.dart';
import '../core/local_database.dart';
import '../models/models.dart';

class DossierService {
  final ApiService _api = ApiService();
  final LocalDatabase _localDb = LocalDatabase.instance;

  Future<List<Dossier>> getMesDossiers() async {
    try {
      final response = await _api.get("/dossiers");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List dossiersJson = data['dossiers'];
        final dossiers = dossiersJson.map((json) => Dossier.fromJson(json)).toList();
        
        // Sauvegarde en cache
        await _localDb.saveDossiers(dossiers);
        return dossiers;
      }
    } catch (e) {
      // En cas d'erreur réseau, on retourne le cache
      return await _localDb.getCachedDossiers();
    }
    return await _localDb.getCachedDossiers();
  }

  Future<List<Dossier>> getMesDossiersPagines(int page, int size) async {
    try {
      final response = await _api.get("/dossiers?page=$page&size=$size");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List dossiersJson = data['dossiers'];
        return dossiersJson.map((json) => Dossier.fromJson(json)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<List<dynamic>> getCategories() async {
    final response = await _api.get("/dossiers/categories");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<List<dynamic>> getDemarches(int? categorieId) async {
    final endpoint = categorieId != null ? "/dossiers/demarches?categorie_id=$categorieId" : "/dossiers/demarches";
    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}
