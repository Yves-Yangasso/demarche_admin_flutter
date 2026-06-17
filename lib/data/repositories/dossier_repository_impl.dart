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
      final response = await _apiClient.get("/citoyens/me/dossiers");
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List dossiersJson = data is List ? data : (data['dossiers'] ?? []);
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
      final response = await _apiClient.get("/citoyens/me/dossiers?page=$page&size=$size");
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List dossiersJson = data is List ? data : (data['dossiers'] ?? []);
        return dossiersJson.map((json) => Dossier.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      final cached = await _localDb.getCachedDossiers();
      if (cached.isNotEmpty) {
        final start = (page - 1) * size;
        if (start >= cached.length) return [];
        final end = (start + size > cached.length) ? cached.length : start + size;
        return cached.sublist(start, end);
      }
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<List<dynamic>> getCategories({int? organisationId}) async {
    try {
      final endpoint = organisationId != null
          ? "/dossiers/categories?organisation_id=$organisationId"
          : "/dossiers/categories";
      final response = await _apiClient.get(endpoint);
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
  Future<List<dynamic>> getDemarches(int? categorieId, {int? organisationId}) async {
    try {
      final params = <String>[];
      if (categorieId != null) params.add('categorie_id=$categorieId');
      if (organisationId != null) params.add('organisation_id=$organisationId');
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await _apiClient.get("/dossiers/demarches$query");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ServerFailure("Impossible de charger les types de démarches.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<Dossier> createDossier(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post("/dossiers", data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Dossier.fromJson(jsonDecode(response.body));
      }
      throw ServerFailure("Erreur lors de la création du dossier.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<List<dynamic>> getOrganisations() async {
    try {
      final response = await _apiClient.get("/collectivites");
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((c) => {
          'id': c['id'],
          'nom': c['nom'],
          'description': c['description'] ?? c['adresse'] ?? '',
          'nb_types': c['nb_procedures'] ?? 0,
          'type': c['type'] ?? 'commune',
          'region': c['region'] ?? '',
        }).toList();
      }
      throw ServerFailure("Impossible de charger les organisations.");
    } catch (e) {
      if (e is Failure) rethrow;
      // Fallback données démo enrichies si aucune connexion
      return [
        {'id': 1, 'nom': 'Mairie de Dakar', 'description': 'Services municipaux de la capitale', 'nb_types': 8, 'type': 'mairie', 'region': 'Dakar'},
        {'id': 2, 'nom': 'Mairie de Thiès', 'description': 'Services municipaux de Thiès', 'nb_types': 6, 'type': 'mairie', 'region': 'Thiès'},
        {'id': 3, 'nom': 'Mairie de Saint-Louis', 'description': 'Services municipaux de Saint-Louis', 'nb_types': 5, 'type': 'mairie', 'region': 'Saint-Louis'},
        {'id': 4, 'nom': 'Mairie de Ziguinchor', 'description': 'Services municipaux de Ziguinchor', 'nb_types': 4, 'type': 'mairie', 'region': 'Ziguinchor'},
        {'id': 5, 'nom': 'Mairie de Kaolack', 'description': 'Services municipaux de Kaolack', 'nb_types': 5, 'type': 'mairie', 'region': 'Kaolack'},
        {'id': 6, 'nom': 'Police Nationale — Dakar', 'description': 'Documents de sécurité et casier judiciaire', 'nb_types': 4, 'type': 'police', 'region': 'Dakar'},
        {'id': 7, 'nom': 'Police Nationale — Thiès', 'description': 'Documents de sécurité et casier judiciaire', 'nb_types': 3, 'type': 'police', 'region': 'Thiès'},
        {'id': 8, 'nom': 'Ministère de la Justice', 'description': 'Actes judiciaires, légalisation et apostille', 'nb_types': 5, 'type': 'justice', 'region': 'Dakar'},
        {'id': 9, 'nom': 'Tribunal de Thiès', 'description': 'Actes judiciaires et légalisation', 'nb_types': 3, 'type': 'justice', 'region': 'Thiès'},
        {'id': 10, 'nom': 'Hôpital Principal de Dakar', 'description': 'Documents médicaux et administratifs', 'nb_types': 3, 'type': 'sante', 'region': 'Dakar'},
        {'id': 11, 'nom': 'Centre de Santé de Touba', 'description': 'Documents médicaux et certificats', 'nb_types': 2, 'type': 'sante', 'region': 'Diourbel'},
        {'id': 12, 'nom': 'Direction des Transports Terrestres', 'description': 'Permis de conduire et immatriculations', 'nb_types': 6, 'type': 'transport', 'region': 'Dakar'},
        {'id': 13, 'nom': 'Inspection Académie de Dakar', 'description': 'Documents scolaires et diplômes', 'nb_types': 4, 'type': 'education', 'region': 'Dakar'},
        {'id': 14, 'nom': 'Inspection Académie de Kaolack', 'description': 'Documents scolaires et diplômes', 'nb_types': 3, 'type': 'education', 'region': 'Kaolack'},
      ];
    }
  }

  @override
  Future<List<dynamic>> getDocumentsCriteres(int typeId) async {
    try {
      final response = await _apiClient.get("/dossiers/types/$typeId/documents");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ServerFailure("Impossible de charger les documents requis.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(int dossierId) async {
    try {
      final response = await _apiClient.get("/messages/dossier/$dossierId");
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((m) => Map<String, dynamic>.from(m)).toList();
      }
      throw ServerFailure("Impossible de charger les messages.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(int dossierId, String contenu) async {
    try {
      final response = await _apiClient.post(
        "/messages/dossier/$dossierId",
        {'contenu': contenu},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      throw ServerFailure("Impossible d'envoyer le message.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<Map<String, dynamic>> uploadDocument(
    int dossierId,
    String filePath, {
    required String nom,
    String typeDocument = 'justificatif',
    bool estRequis = false,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        "/documents/dossier/$dossierId",
        filePath,
        extraFields: {
          'nom': nom,
          'type_document': typeDocument,
          'est_requis': estRequis ? 'true' : 'false',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      throw ServerFailure("Erreur lors de l'upload du document.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }
}
