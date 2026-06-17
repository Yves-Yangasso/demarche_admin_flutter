import 'package:http/http.dart' as http;
import '../../models/models.dart';

abstract class IAuthRepository {
  Future<void> sendPhoneOtp(String telephone);
  Future<void> sendEmailOtp(String email);
  Future<bool> verifyPhoneOtp(String telephone, String code);
  Future<bool> verifyEmailOtp(String email, String code);
  Future<http.Response> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
  });
  Future<Utilisateur?> getCurrentUser();
  Future<String?> getToken();
  Future<void> logout();

  /// Met à jour le profil de l'utilisateur courant (PATCH /auth/me)
  Future<Utilisateur> updateProfile(Map<String, dynamic> data);

  /// Upload une photo de profil (POST /auth/me/photo)
  Future<String> uploadPhoto(String filePath);
}
