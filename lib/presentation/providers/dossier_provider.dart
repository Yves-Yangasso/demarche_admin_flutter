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

  Future<List<dynamic>> getCategories() async {
    try {
      return await _repository.getCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<dynamic>> getDemarches(int? categorieId) async {
    try {
      return await _repository.getDemarches(categorieId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
