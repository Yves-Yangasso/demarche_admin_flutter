import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// Numéros sénégalais : 70, 76, 77, 78 - 9 chiffres, +221 optionnel
final _phoneRe = RegExp(r'^(?:\+221|00221)?[7][0678]\d{7}$');

String? _validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalised = value.replaceAll(RegExp(r'[\s\-\.]'), '');
  if (!_phoneRe.hasMatch(normalised)) {
    return 'Numéro invalide (ex: 77 123 45 67 ou +221 77 123 45 67)';
  }
  return null;
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _consentement = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final tel = _phoneController.text.trim();
    final email = _emailController.text.trim();
    if (tel.isEmpty && email.isEmpty) {
      _showError('Renseignez au moins un téléphone ou un email.');
      return;
    }
    if (!_consentement) {
      _showError(
          'Vous devez accepter les conditions de traitement de vos données.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: tel,
        email: email,
        consentementDonnees: true,
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie, connectez-vous.")),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        _showError("Erreur lors de l'inscription.");
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildRegisterForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              "assets/images/logo.png",
              width: MediaQuery.of(context).size.height * 0.2,
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            const _Header(),
            TextFormField(
              controller: _nomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Nom *",
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le nom est requis.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prenomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Prénom *",
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Le prénom est requis.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Téléphone",
                hintText: "77 123 45 67",
                prefixIcon: Icon(Icons.phone_iphone_rounded),
                helperText: "Orange 77, Free 76, Wave/Expresso 70/78",
              ),
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;

                final emailRe = RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                );

                if (!emailRe.hasMatch(v.trim())) {
                  return 'Email invalide.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            _ConsentementCheckbox(
              value: _consentement,
              onChanged: (v) => setState(() => _consentement = v ?? false),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _register,
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text("S'inscrire"),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Déjà inscrit ?",
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "Créer un compte",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Rejoignez-nous en quelques secondes",
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}

class _ConsentementCheckbox extends StatelessWidget {
  const _ConsentementCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF176848),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              "J'accepte que mes données personnelles soient traitées "
              "conformément à la loi sénégalaise 2008-12 sur la protection "
              "des données personnelles.",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
        ),
      ],
    );
  }
}
