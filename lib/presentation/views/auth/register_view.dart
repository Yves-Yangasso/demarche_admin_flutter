import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nomController    = TextEditingController();
  final _prenomController = TextEditingController();
  final _phoneController  = TextEditingController();
  final _emailController  = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();
    try {
      final success = await auth.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie, connectez-vous.')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'inscription")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  // ─── Logo ─────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 115,
      height: 115,
      fit: BoxFit.contain,
    );
  }

  // ─── Carte principale ──────────────────────────────────────────────────────

  Widget _buildCard() {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Logo en haut de la carte ───────────────────────────────
          Center(child: _buildLogo()),
          const SizedBox(height: 24),

          // ── Champs ────────────────────────────────────────────────
          _buildField(
            controller: _nomController,
            hint: 'Nom de famille',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _prenomController,
            hint: 'Prénom',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _phoneController,
            hint: '06 00 00 00 00',
            icon: Icons.phone_iphone_rounded,
            inputType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _emailController,
            hint: 'exemple@mail.com',
            icon: Icons.mail_outline_rounded,
            inputType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 28),

          // ── Bouton S'inscrire ──────────────────────────────────────
          ElevatedButton(
            onPressed: isLoading ? null : _register,
            child: isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "S'inscrire",
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          // ── Lien connexion ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Déjà inscrit ? ',
                style: TextStyle(
                  fontSize: 14, color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Champ pill réutilisable ──────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(
        fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Icon(icon, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
