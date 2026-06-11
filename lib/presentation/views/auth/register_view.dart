import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.register(
        nom: _nomController.text,
        prenom: _prenomController.text,
        telephone: _phoneController.text,
        email: _emailController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inscription réussie, connectez-vous.")));
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'inscription")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
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
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildRegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          "Créer un compte",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
        ),
        SizedBox(height: 8),
        Text(
          "Rejoignez-nous en quelques secondes",
          style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: "Nom",
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _prenomController,
            decoration: const InputDecoration(
              labelText: "Prénom",
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Téléphone",
              prefixIcon: Icon(Icons.phone_iphone_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isLoading ? null : _register,
            child: isLoading 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text("S'inscrire"),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Déjà inscrit ?", style: TextStyle(color: Color(0xFF64748B))),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Se connecter", style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
