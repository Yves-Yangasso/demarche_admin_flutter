import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../domain/repositories/iauth_repository.dart';

class AuthProvider with ChangeNotifier {
  final IAuthRepository _repository;

  AuthProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _token;
  bool get isAuthenticated => _token != null;

  Utilisateur? _currentUser;
  Utilisateur? get currentUser => _currentUser;

  /// True après la dernière vérification OTP si l'utilisateur n'avait jamais
  /// été connecté auparavant (à router vers `/onboarding`). Reset après lecture.
  bool _isNewUser = false;
  bool consumeIsNewUserFlag() {
    final v = _isNewUser;
    _isNewUser = false;
    return v;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _token = await _repository.getToken();
    if (_token != null) {
      await fetchUser();
      if (_currentUser == null) {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<void> fetchUser() async {
    _currentUser = await _repository.getCurrentUser();
    notifyListeners();
  }

  Future<void> sendPhoneOtp(String telephone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.sendPhoneOtp(telephone);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendEmailOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.sendEmailOtp(email);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPhoneOtp(String telephone, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.verifyPhoneOtp(telephone, code);
      if (result.success) {
        _isNewUser = result.isNewUser;
        await checkAuth();
      }
      return result.success;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyEmailOtp(String email, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.verifyEmailOtp(email, code);
      if (result.success) {
        _isNewUser = result.isNewUser;
        await checkAuth();
      }
      return result.success;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    bool consentementDonnees = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _repository.register(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        email: email,
        consentementDonnees: consentementDonnees,
      );
      return response.statusCode == 201;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour le profil de l'utilisateur connecté
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _repository.updateProfile(data);
      _currentUser = updated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload une photo de profil et met à jour l'utilisateur courant
  Future<bool> uploadPhoto(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final photoUrl = await _repository.uploadPhoto(filePath);
      // Rafraîchir l'utilisateur pour refléter la nouvelle photo
      await fetchUser();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}
