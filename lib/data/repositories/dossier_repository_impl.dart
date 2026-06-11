import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/local_database.dart';
import '../../core/network/failure.dart';
import '../../domain/repositories/idossier_repository.dart';
import '../../models/models.dart';

class DossierRepositoryImpl implements IDossierRepository {
  final ApiClient _apiClient;
  final LocalDatabase _localDb = LocalDatabase.instance;

  DossierRepositoryImpl(this._apiClient);

  @override
  Future<List<Dossier>> getMesDossiers({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _localDb.getCachedDossiers();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final response = await _apiClient.get("/dossiers");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List dossiersJson = data['dossiers'];
        final dossiers = dossiersJson.map((json) => Dossier.fromJson(json)).toList();
        
        await _localDb.saveDossiers(dossiers);
        return dossiers;
      } else {
        throw ServerFailure("Impossible de récupérer vos dossiers.");
      }
    } catch (e) {
      final cached = await _localDb.getCachedDossiers();
      if (cached.isNotEmpty) return cached;
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<List<Dossier>> getMesDossiersPagines(int page, int size) async {
    try {
      final response = await _apiClient.get("/dossiers?page=$page&size=$size");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List dossiersJson = data['dossiers'];
        return dossiersJson.map((json) => Dossier.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _apiClient.get("/dossiers/categories");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ServerFailure("Impossible de charger les catégories.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<List<dynamic>> getDemarches(int? categorieId) async {
    try {
      final endpoint = categorieId != null ? "/dossiers/demarches?categorie_id=$categorieId" : "/dossiers/demarches";
      final response = await _apiClient.get(endpoint);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ServerFailure("Impossible de charger les types de démarches.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }
}
