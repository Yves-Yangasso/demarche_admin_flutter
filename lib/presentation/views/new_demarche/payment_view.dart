// lib/presentation/views/new_demarche/payment_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/paiement_repository_impl.dart';
import '../../providers/dossier_provider.dart';

enum PaymentMethod { wave, orangeMoney }

class PaymentView extends StatefulWidget {
  final Map<String, dynamic> dossierData;
  final String typeNom;
  final double prix;
  final Map<String, File?> uploadedFiles;

  const PaymentView({
    super.key,
    required this.dossierData,
    required this.typeNom,
    required this.prix,
    required this.uploadedFiles,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView>
    with TickerProviderStateMixin {
  PaymentMethod _selected = PaymentMethod.wave;
  bool _isProcessing = false;
  bool _paymentDone = false;
  late AnimationController _successCtrl;
  late Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successAnim =
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Création du dossier
      final dossierProvider = context.read<DossierProvider>();
      final canal = _selected == PaymentMethod.wave ? 'wave' : 'orange_money';
      final dossier = await dossierProvider.createDossier({
        ...widget.dossierData,
        'methode_paiement': canal,
        'montant_paye': widget.prix,
      });

      if (dossier == null) {
        throw Exception('Création du dossier impossible.');
      }
      if (!mounted) return;

      // 2. Upload documents attachés au dossier
      for (var entry in widget.uploadedFiles.entries) {
        final file = entry.value;
        if (file != null) {
          await dossierProvider.uploadDocument(
            dossier.id,
            file.path,
            nom: entry.key,
          );
        }
      }

      // 3. B7 - Initialisation du paiement via /api/paiements/initier.
      // C'est cet appel qui crée l'enregistrement Paiement côté back (statut INITIE),
      // déclenche l'éventuel webhook Wave/Orange et trace l'opération dans l'audit.
      final paiementRepo = PaiementRepository(ApiClient());
      await paiementRepo.initier(
        dossierId: dossier.id,
        canal: canal,
        montantFcfa: widget.prix,
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _paymentDone = true;
      });
      _successCtrl.forward();
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur paiement: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_paymentDone) return _buildSuccessScreen(l10n);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(l10n.payment,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Color(0xFF0F172A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF176848).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.typeNom,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.prix.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: Colors.white.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      Text(l10n.priceSetByAdmin,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Payment method
            Text(l10n.paymentMethod,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 12),

            // Wave
            _buildMethodCard(
              method: PaymentMethod.wave,
              name: l10n.waveMoney,
              description: 'Payer via votre compte Wave',
              color: const Color(0xFF00B4D8),
              icon: Icons.waves_rounded,
              subtitle: 'Rapide & sécurisé · Frais inclus',
            ),
            const SizedBox(height: 12),

            // Orange Money
            _buildMethodCard(
              method: PaymentMethod.orangeMoney,
              name: l10n.orangeMoney,
              description: 'Payer via Orange Money',
              color: const Color(0xFFFF6B00),
              icon: Icons.phone_android_rounded,
              subtitle: 'Disponible 24h/24 · Sans internet',
            ),
            const SizedBox(height: 28),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_rounded,
                          color: Color(0xFFF59E0B), size: 18),
                      SizedBox(width: 8),
                      Text('Instructions',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selected == PaymentMethod.wave
                        ? '1. Ouvrez votre app Wave\n2. Scannez le QR code qui apparaîtra\n3. Confirmez le paiement de ${widget.prix.toStringAsFixed(0)} FCFA'
                        : '1. Composez *144# sur votre téléphone\n2. Choisissez "Paiement marchand"\n3. Entrez le code: TERREADMIN\n4. Confirmez le paiement de ${widget.prix.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF92400E), height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: const Color(0xFF176848),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Traitement en cours...',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      )
                    : Text(l10n.paymentConfirm,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required PaymentMethod method,
    required String name,
    required String description,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    final isSelected = _selected == method;
    return GestureDetector(
      onTap: () => setState(() => _selected = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isSelected ? color : const Color(0xFF0F172A))),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: color.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? color : const Color(0xFFCBD5E1),
                    width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _successAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        size: 70, color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Demande soumise !',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre demande pour "${widget.typeNom}" a été soumise avec succès. Vous recevrez une notification lorsque votre dossier sera traité.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF64748B), height: 1.6),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (r) => false),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Retour à l\'accueil',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (r) => false);
                    // Navigate to dossiers
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: const Text('Voir mes dossiers',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
