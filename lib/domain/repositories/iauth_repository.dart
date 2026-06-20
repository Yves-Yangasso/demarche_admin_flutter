import 'package:http/http.dart' as http;
import '../../models/models.dart';

/// Résultat d'une vérification OTP : success + flag indiquant si c'est un
/// nouvel utilisateur (à router vers onboarding).
class OtpVerificationResult {
  final bool success;
  final bool isNewUser;
  const OtpVerificationResult({required this.success, this.isNewUser = false});
}

abstract class IAuthRepository {
  Future<void> sendPhoneOtp(String telephone);
  Future<void> sendEmailOtp(String email);
  Future<OtpVerificationResult> verifyPhoneOtp(String telephone, String code);
  Future<OtpVerificationResult> verifyEmailOtp(String email, String code);
  Future<http.Response> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    bool consentementDonnees = false,
  });
  Future<Utilisateur?> getCurrentUser();
  Future<String?> getToken();
  Future<void> logout();

  /// Met à jour le profil de l'utilisateur courant (PATCH /auth/me)
  Future<Utilisateur> updateProfile(Map<String, dynamic> data);

  /// Upload une photo de profil (POST /auth/me/photo)
  Future<String> uploadPhoto(String filePath);
}
