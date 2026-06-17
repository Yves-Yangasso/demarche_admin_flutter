import 'package:flutter/material.dart';
import '../../domain/repositories/idossier_repository.dart';
import '../../models/models.dart';

class DossierProvider with ChangeNotifier {
  final IDossierRepository _repository;

  DossierProvider(this._repository);

  List<Dossier> _dossiers = [];
  List<Dossier> get dossiers => _dossiers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchDossiers({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dossiers = await _repository.getMesDossiers(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Dossier>> fetchPaginated(int page, int size) async {
    try {
      return await _repository.getMesDossiersPagines(page, size);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<dynamic>> getCategories({int? organisationId}) async {
    try {
      return await _repository.getCategories(organisationId: organisationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<dynamic>> getDemarches(int? categorieId, {int? organisationId}) async {
    try {
      return await _repository.getDemarches(categorieId, organisationId: organisationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Dossier?> createDossier(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final dossier = await _repository.createDossier(data);
      _dossiers.insert(0, dossier);
      return dossier;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> getOrganisations() async {
    try {
      return await _repository.getOrganisations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // Return mock data for demo
      return [
        {'id': 1, 'nom': 'Mairie de Dakar', 'description': 'Services municipaux de Dakar', 'nb_types': 5},
        {'id': 2, 'nom': 'Police Nationale', 'description': 'Documents et sécurité', 'nb_types': 3},
        {'id': 3, 'nom': 'Ministère de la Justice', 'description': 'Actes judiciaires et légalisation', 'nb_types': 4},
        {'id': 4, 'nom': 'Centre de Santé', 'description': 'Documents médicaux et administratifs', 'nb_types': 2},
        {'id': 5, 'nom': 'Direction des Transports', 'description': 'Permis et immatriculations', 'nb_types': 6},
      ];
    }
  }



  Future<List<dynamic>> getDocumentsCriteres(int typeId) async {
    try {
      return await _repository.getDocumentsCriteres(typeId);
    } catch (e) {
      // Mock required docs
      return [
        {'id': 1, 'nom': 'Copie de la CNI', 'obligatoire': true, 'description': 'Recto/Verso', 'criteres': 'Document en cours de validité'},
        {'id': 2, 'nom': 'Acte de naissance', 'obligatoire': true, 'description': 'Copie certifiée conforme', 'criteres': 'Original ou copie légalisée'},
        {'id': 3, 'nom': 'Photo d\'identité', 'obligatoire': true, 'description': '2 photos récentes', 'criteres': 'Fond blanc, moins de 3 mois'},
        {'id': 4, 'nom': 'Justificatif de domicile', 'obligatoire': false, 'description': 'Facture de moins de 3 mois', 'criteres': ''},
      ];
    }
  }

  Future<Dossier?> correctDossier(int dossierId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final dossier = await _repository.createDossier({
        ...data,
        'dossier_original_id': dossierId,
        'is_correction': true,
      });
      final idx = _dossiers.indexWhere((d) => d.id == dossierId);
      if (idx != -1) _dossiers[idx] = dossier;
      return dossier;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(int dossierId) async {
    try {
      return await _repository.getMessages(dossierId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<Map<String, dynamic>?> sendMessage(int dossierId, String contenu) async {
    try {
      return await _repository.sendMessage(dossierId, contenu);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadDocument(
    int dossierId,
    String filePath, {
    required String nom,
    String typeDocument = 'justificatif',
    bool estRequis = false,
  }) async {
    try {
      return await _repository.uploadDocument(
        dossierId,
        filePath,
        nom: nom,
        typeDocument: typeDocument,
        estRequis: estRequis,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
