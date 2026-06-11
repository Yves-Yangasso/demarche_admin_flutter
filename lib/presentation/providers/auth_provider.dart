import 'package:flutter/material.dart';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _token = await _repository.getToken();
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
      final success = await _repository.verifyPhoneOtp(telephone, code);
      if (success) await checkAuth();
      return success;
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
      final success = await _repository.verifyEmailOtp(email, code);
      if (success) await checkAuth();
      return success;
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

  Future<void> logout() async {
    await _repository.logout();
    _token = null;
    notifyListeners();
  }
}
