import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../core/network/failure.dart';

/// Suivi PUBLIC d'un dossier par son numéro, sans authentification.
/// Endpoint backend : GET /api/suivi/<numero>  (cf. app/routes/suivi.py)
///
/// RGPD by design : la réponse ne contient JAMAIS le nom complet du citoyen,
/// uniquement les initiales et l'avancement du dossier.
class SuiviPublicResult {
  final String numero;
  final bool trouve;
  final String? typeDemarcheLibelle;
  final String? commune;
  final String? statutLibelle;
  final String? etapeCouranteCode;
  final DateTime? dateDerniereAction;
  final String? messageLisible;

  const SuiviPublicResult({
    required this.numero,
    required this.trouve,
    this.typeDemarcheLibelle,
    this.commune,
    this.statutLibelle,
    this.etapeCouranteCode,
    this.dateDerniereAction,
    this.messageLisible,
  });

  factory SuiviPublicResult.fromJson(Map<String, dynamic> json) =>
      SuiviPublicResult(
        numero: (json['numero'] ?? '').toString(),
        trouve: json['trouve'] == true,
        typeDemarcheLibelle: json['type_demarche_libelle']?.toString(),
        commune: json['commune']?.toString(),
        statutLibelle: json['statut_libelle']?.toString(),
        etapeCouranteCode: json['etape_courante_code']?.toString(),
        dateDerniereAction:
            DateTime.tryParse(json['date_derniere_action']?.toString() ?? ''),
        messageLisible: json['message_lisible']?.toString(),
      );
}

class SuiviRepository {
  final ApiClient _api;
  SuiviRepository(this._api);

  Future<SuiviPublicResult> rechercher(String numero) async {
    // Pas de header Authorization : endpoint public.
    final response = await _api.getPublic('/suivi/$numero');
    if (response.statusCode == 200) {
      return SuiviPublicResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 404) {
      return SuiviPublicResult(numero: numero, trouve: false);
    }
    throw ServerFailure(
      'Erreur recherche dossier (HTTP ${response.statusCode}).',
    );
  }
}
