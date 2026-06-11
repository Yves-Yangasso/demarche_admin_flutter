import 'package:http/http.dart' as http;

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
  Future<String?> getToken();
  Future<void> logout();
}
