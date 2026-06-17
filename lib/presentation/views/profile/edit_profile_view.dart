// lib/presentation/views/profile/edit_profile_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_localizations.dart';
import '../../providers/auth_provider.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _dateNaissCtrl = TextEditingController();
  final _lieuNaissCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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
    _adresseCtrl.dispose();
    _dateNaissCtrl.dispose();
    _lieuNaissCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    
    final data = {
      'nom': _nomCtrl.text.trim(),
      'prenom': _prenomCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'telephone': _telephoneCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim(),
      'date_naissance': _dateNaissCtrl.text.trim(),
      'lieu_naissance': _lieuNaissCtrl.text.trim(),
    };

    final success = await authProvider.updateProfile(data);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil mis à jour ✅'), backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(authProvider.error ?? 'Erreur lors de la mise à jour'), 
              backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
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
        title: Text(l10n.editProfile,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(l10n.save,
                style: const TextStyle(
                    color: Color(0xFF176848), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Informations de base', Icons.person_rounded),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(l10n.lastName, _nomCtrl, required: true)),
                const SizedBox(width: 12),
                Expanded(child: _field(l10n.firstName, _prenomCtrl, required: true)),
              ]),
              const SizedBox(height: 12),
              _field(l10n.email, _emailCtrl,
                  keyboard: TextInputType.emailAddress, required: true),
              const SizedBox(height: 12),
              _field(l10n.phone, _telephoneCtrl,
                  keyboard: TextInputType.phone, required: true),
              const SizedBox(height: 20),
              _section('Naissance & Adresse', Icons.location_on_rounded),
              const SizedBox(height: 12),
              _field(l10n.birthDate, _dateNaissCtrl, hint: 'JJ/MM/AAAA'),
              const SizedBox(height: 12),
              _field(l10n.birthPlace, _lieuNaissCtrl),
              const SizedBox(height: 12),
              _field(l10n.address, _adresseCtrl, maxLines: 2),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(l10n.save,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
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
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
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
      decoration:
          InputDecoration(labelText: required ? '$label *' : label, hintText: hint),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Requis' : null : null,
    );
  }
}
