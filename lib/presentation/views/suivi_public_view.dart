import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../data/repositories/suivi_repository_impl.dart';
import 'qr_scanner_view.dart';

/// Suivi public d'un dossier par numéro, sans authentification.
///
/// Consomme `GET /api/suivi/<numero>` qui répond sans révéler le nom du
/// citoyen (initiales uniquement, conformité loi 2008-12).
class SuiviPublicView extends StatefulWidget {
  const SuiviPublicView({super.key});

  @override
  State<SuiviPublicView> createState() => _SuiviPublicViewState();
}

class _SuiviPublicViewState extends State<SuiviPublicView> {
  final _numeroCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final SuiviRepository _repo = SuiviRepository(ApiClient());

  bool _loading = false;
  SuiviPublicResult? _result;
  String? _erreur;

  Future<void> _rechercher() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _erreur = null;
      _result = null;
    });
    try {
      final r = await _repo.rechercher(_numeroCtrl.text.trim());
      setState(() => _result = r);
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Ouvre le scanner QR, extrait un numéro de dossier depuis la valeur
  /// scannée (URL ou numéro brut), pré-remplit le champ et lance la recherche.
  Future<void> _scannerQr() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerView()),
    );
    if (raw == null || raw.isEmpty) return;
    final numero = _extraireNumeroDossier(raw);
    if (numero.isEmpty) {
      setState(() {
        _erreur = 'QR code non reconnu : « $raw »';
        _result = null;
      });
      return;
    }
    _numeroCtrl.text = numero;
    await _rechercher();
  }

  /// Normalise une valeur scannée vers un numéro de dossier exploitable.
  ///
  /// Accepte plusieurs formes :
  ///   - URL `https://sunudekk.sn/suivi/EC-2026-DEMO04` → extrait `EC-2026-DEMO04`
  ///   - URL `…/api/suivi/EC-2026-DEMO04`               → idem
  ///   - URL `…?numero=EC-2026-DEMO04`                  → idem
  ///   - Numéro brut `EC-2026-DEMO04`                   → tel quel
  String _extraireNumeroDossier(String raw) {
    final value = raw.trim();
    // Pattern simple : 2-4 lettres, tiret, 4 chiffres, tiret, suffixe alphanum.
    final pattern = RegExp(r'\b([A-Z]{2,4}-\d{4}-[A-Z0-9]+)\b',
        caseSensitive: false);
    final m = pattern.firstMatch(value.toUpperCase());
    return m?.group(1) ?? '';
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Suivi de dossier'),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suivi public · sans compte',
              style: TextStyle(
                color: Color(0xFF176848),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entrez le numéro de votre dossier pour connaître son avancement.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _numeroCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Numéro du dossier',
                  hintText: 'ex. EC-2026-DEMO04',
                  border: const OutlineInputBorder(),
                  // Bouton scanner QR : remplit auto le champ + lance recherche.
                  suffixIcon: IconButton(
                    tooltip: 'Scanner le QR code du récépissé',
                    icon: const Icon(Icons.qr_code_scanner_rounded,
                        color: Color(0xFF176848)),
                    onPressed: _loading ? null : _scannerQr,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 4) ? 'Numéro invalide' : null,
                onFieldSubmitted: (_) => _rechercher(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _rechercher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176848),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Rechercher',
                        style:
                            TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 24),
            if (_erreur != null) _ErrorCard(message: _erreur!),
            if (_result != null) _ResultCard(result: _result!),
            const SizedBox(height: 32),
            const _RgpdNotice(),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final SuiviPublicResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    if (!result.trouve) {
      return _ErrorCard(
        message: 'Aucun dossier trouvé pour le numéro ${result.numero}.',
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: Color(0xFF176848), size: 22),
              const SizedBox(width: 8),
              Text(result.numero,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          if (result.typeDemarcheLibelle != null)
            _row('Démarche', result.typeDemarcheLibelle!),
          if (result.commune != null) _row('Commune', result.commune!),
          if (result.statutLibelle != null)
            _row('Statut', result.statutLibelle!),
          if (result.dateDerniereAction != null)
            _row(
              'Dernière action',
              '${result.dateDerniereAction!.day.toString().padLeft(2, '0')}/'
              '${result.dateDerniereAction!.month.toString().padLeft(2, '0')}/'
              '${result.dateDerniereAction!.year}',
            ),
          if (result.messageLisible != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(result.messageLisible!,
                  style:
                      const TextStyle(color: Color(0xFF065F46), fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontSize: 13)),
            ),
          ],
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFB91C1C), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _RgpdNotice extends StatelessWidget {
  const _RgpdNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_outlined,
              size: 16, color: Color(0xFF64748B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Conformément à la loi 2008-12 et aux directives CDP, '
              'le nom complet du demandeur n\'est jamais affiché ici. '
              'Seules les informations strictement nécessaires au suivi sont visibles.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
