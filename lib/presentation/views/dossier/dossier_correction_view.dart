// lib/presentation/views/dossier/dossier_correction_view.dart
// Allows the user to correct a rejected dossier and resubmit with payment
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_localizations.dart';
import '../../../models/models.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/dossier_provider.dart';
import '../new_demarche/payment_view.dart';

class DossierCorrectionView extends StatefulWidget {
  final Dossier dossier;
  const DossierCorrectionView({super.key, required this.dossier});

  @override
  State<DossierCorrectionView> createState() => _DossierCorrectionViewState();
}

class _DossierCorrectionViewState extends State<DossierCorrectionView> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _dateNaissCtrl = TextEditingController();
  final _lieuNaissCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _numeroCniCtrl = TextEditingController();
  final _nomPereCtrl = TextEditingController();
  final _nomMereCtrl = TextEditingController();
  final _commentaireCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nomCtrl.text = user.nom;
      _prenomCtrl.text = user.prenom;
      _emailCtrl.text = user.email;
      _telephoneCtrl.text = user.telephone;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telephoneCtrl.dispose();
    _dateNaissCtrl.dispose();
    _lieuNaissCtrl.dispose();
    _adresseCtrl.dispose();
    _numeroCniCtrl.dispose();
    _nomPereCtrl.dispose();
    _nomMereCtrl.dispose();
    _commentaireCtrl.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;

    final dossierData = {
      'dossier_original_id': widget.dossier.id,
      'type_demarche_id': widget.dossier.typeDemarche.id,
      'nom': _nomCtrl.text,
      'prenom': _prenomCtrl.text,
      'email': _emailCtrl.text,
      'telephone': _telephoneCtrl.text,
      'date_naissance': _dateNaissCtrl.text,
      'lieu_naissance': _lieuNaissCtrl.text,
      'adresse': _adresseCtrl.text,
      'numero_cni': _numeroCniCtrl.text,
      'nom_pere': _nomPereCtrl.text,
      'nom_mere': _nomMereCtrl.text,
      'commentaire': _commentaireCtrl.text,
      'is_correction': true,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentView(
          dossierData: dossierData,
          typeNom: widget.dossier.typeDemarche.nom,
          prix: 1500, // Frais de re-soumission
          uploadedFiles: {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.correctAndResubmit,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
            Text(widget.dossier.reference,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Rejection notice
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.correctionInstructions,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('Informations personnelles', Icons.person_rounded),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _field(l10n.lastName, _nomCtrl, required: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(l10n.firstName, _prenomCtrl, required: true)),
                    ]),
                    const SizedBox(height: 12),
                    _field(l10n.email, _emailCtrl, keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _field(l10n.phone, _telephoneCtrl, keyboard: TextInputType.phone, required: true),
                    const SizedBox(height: 12),
                    _field(l10n.birthDate, _dateNaissCtrl, hint: 'JJ/MM/AAAA'),
                    const SizedBox(height: 12),
                    _field(l10n.birthPlace, _lieuNaissCtrl),
                    const SizedBox(height: 12),
                    _field(l10n.idNumber, _numeroCniCtrl),
                    const SizedBox(height: 12),
                    _field(l10n.address, _adresseCtrl, maxLines: 2),
                    const SizedBox(height: 20),
                    _section('Filiation', Icons.family_restroom_rounded),
                    const SizedBox(height: 12),
                    _field(l10n.fatherName, _nomPereCtrl),
                    const SizedBox(height: 12),
                    _field(l10n.motherName, _nomMereCtrl),
                    const SizedBox(height: 20),
                    _section(l10n.comment, Icons.comment_rounded),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _commentaireCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: l10n.commentHint),
                    ),
                    // Frais notice
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFF176848), size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Des frais de re-soumission de 1 500 FCFA seront appliqués.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: ElevatedButton(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Corriger & Payer les frais',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF176848).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF176848)),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      TextInputType keyboard = TextInputType.text,
      bool required = false,
      int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: required ? '$label *' : label, hintText: hint),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Requis' : null : null,
    );
  }
}
