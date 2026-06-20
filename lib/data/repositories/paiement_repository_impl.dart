import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../core/network/failure.dart';

/// Wrapper minimal sur l'API paiements du backend.
///
/// Endpoints :
///   POST /api/paiements/initier   { dossier_id, canal, montant_fcfa }
///   GET  /api/paiements/<id>       (suivi du statut)
class PaiementRepository {
  final ApiClient _api;
  PaiementRepository(this._api);

  /// Initie un paiement et retourne l'enregistrement créé (statut INITIE).
  /// Le canal accepté : 'wave' | 'orange_money' | 'free_money' | 'autre'.
  Future<Map<String, dynamic>> initier({
    required int dossierId,
    required String canal,
    required num montantFcfa,
  }) async {
    final response = await _api.post('/paiements/initier', {
      'dossier_id': dossierId,
      'canal': canal,
      'montant_fcfa': montantFcfa,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final body = (() {
      try { return jsonDecode(response.body) as Map<String, dynamic>; }
      catch (_) { return <String, dynamic>{}; }
    })();
    throw ServerFailure(
      body['message']?.toString() ??
          'Échec initialisation paiement (HTTP ${response.statusCode}).',
    );
  }
}
