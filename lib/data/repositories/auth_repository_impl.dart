import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../../core/network/api_client.dart';
import '../../core/network/failure.dart';
import '../../domain/repositories/iauth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<void> sendPhoneOtp(String telephone) async {
    try {
      final response = await _apiClient.post("/auth/otp/envoyer", {"telephone": telephone});
      if (response.statusCode != 200) {
        throw ServerFailure("Impossible d'envoyer le code SMS. Vérifiez le numéro.");
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    try {
      final response = await _apiClient.post("/auth/email/envoyer", {"email": email});
      if (response.statusCode != 200) {
        throw ServerFailure("Impossible d'envoyer le code par email.");
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<bool> verifyPhoneOtp(String telephone, String code) async {
    try {
      final response = await _apiClient.post("/auth/otp/verifier", {
        "telephone": telephone,
        "code": code
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _apiClient.saveToken(data['access_token'], data['refresh_token']);
        return true;
      } else {
        throw AuthFailure("Code SMS invalide ou expiré.");
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<bool> verifyEmailOtp(String email, String code) async {
    try {
      final response = await _apiClient.post("/auth/email/verifier", {
        "email": email,
        "code": code
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _apiClient.saveToken(data['access_token'], data['refresh_token']);
        return true;
      } else {
        throw AuthFailure("Code email invalide ou expiré.");
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<http.Response> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    bool consentementDonnees = false,
  }) async {
    try {
      final response = await _apiClient.post("/auth/inscription", {
        "nom": nom,
        "prenom": prenom,
        if (telephone.isNotEmpty) "telephone": telephone,
        if (email.isNotEmpty) "email": email,
        "consentement_donnees": consentementDonnees,
      });
      if (response.statusCode == 409) {
        throw Failure("Un compte avec ce numéro ou cet email existe déjà.");
      }
      return response;
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<Utilisateur?> getCurrentUser() async {
    try {
      final response = await _apiClient.get("/auth/me");
      if (response.statusCode == 200) {
        return Utilisateur.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    return await _apiClient.getToken();
  }

  @override
  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  @override
  Future<Utilisateur> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch("/auth/me", data);
      if (response.statusCode == 200) {
        return Utilisateur.fromJson(jsonDecode(response.body));
      }
      final body = jsonDecode(response.body);
      throw ServerFailure(body['message'] ?? "Erreur lors de la mise à jour du profil.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }

  @override
  Future<String> uploadPhoto(String filePath) async {
    try {
      final response = await _apiClient.uploadFile("/auth/me/photo", filePath);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['photo_url'] as String;
      }
      throw ServerFailure("Impossible d'uploader la photo.");
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure();
    }
  }
}
