import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController  = TextEditingController();

  bool _codeSent = false;
  int  _selectedTab = 0; // 0 = Téléphone, 1 = Email

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // ─── Actions ────────────────────────────────────────────────────────────

  Future<void> _sendCode() async {
    final auth = context.read<AuthProvider>();
    try {
      if (_selectedTab == 0) {
        await auth.sendPhoneOtp(_phoneController.text.trim());
      } else {
        await auth.sendEmailOtp(_emailController.text.trim());
      }
      if (mounted) setState(() => _codeSent = true);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _verifyCode() async {
    final auth = context.read<AuthProvider>();
    try {
      final success = _selectedTab == 0
          ? await auth.verifyPhoneOtp(
              _phoneController.text.trim(), _codeController.text.trim())
          : await auth.verifyEmailOtp(
              _emailController.text.trim(), _codeController.text.trim());

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

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

  // ─── Logo ────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 115,
      height: 115,
      fit: BoxFit.contain,
    );
  }

  // ─── Carte principale ────────────────────────────────────────────────────

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
          if (!_codeSent) ...[
            // ── Tabs Téléphone / Email ─────────────────────────────
            _buildTabs(),
            const SizedBox(height: 20),
            // ── Champ de saisie ────────────────────────────────────
            _buildInputField(),
          ] else ...[
            // ── Étape vérification OTP ─────────────────────────────
            _buildOtpStep(),
          ],
          const SizedBox(height: 24),
          // ── Bouton principal ───────────────────────────────────────
          _buildPrimaryButton(isLoading),
          const SizedBox(height: 16),
          // ── Lien inscription ───────────────────────────────────────
          _buildRegisterLink(),
        ],
      ),
    );
  }

  // ─── Tabs Téléphone / Email (design maquette) ────────────────────────────

  Widget _buildTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        children: [
          _buildTab(
            index: 0,
            icon: Icons.phone_iphone_rounded,
            label: 'Téléphone',
          ),
          _buildTab(
            index: 1,
            icon: Icons.mail_outline_rounded,
            label: 'Email',
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            boxShadow: isSelected ? AppTheme.tabShadow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Champ de saisie pill ────────────────────────────────────────────────

  Widget _buildInputField() {
    if (_selectedTab == 0) {
      return TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: '06 00 00 00 00',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.phone_iphone_rounded, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      );
    } else {
      return TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'exemple@mail.com',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.mail_outline_rounded, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      );
    }
  }

  // ─── Étape OTP ───────────────────────────────────────────────────────────

  Widget _buildOtpStep() {
    return Column(
      children: [
        const Text(
          'Code de vérification',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Code reçu par ${_selectedTab == 0 ? "SMS" : "Email"}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(
            fontSize: 24, letterSpacing: 10,
            fontWeight: FontWeight.w900, color: AppTheme.primary,
          ),
          decoration: const InputDecoration(
            hintText: '• • • • • •',
            counterText: '',
            hintStyle: TextStyle(letterSpacing: 8, color: AppTheme.textLight),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => _codeSent = false),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Changer de méthode'),
        ),
      ],
    );
  }

  // ─── Bouton principal ─────────────────────────────────────────────────────

  Widget _buildPrimaryButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : (_codeSent ? _verifyCode : _sendCode),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5,
              ),
            )
          : Text(
              _codeSent ? 'Vérifier le code' : 'Se connecter',
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }

  // ─── Lien Créer un compte ─────────────────────────────────────────────────

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Nouveau ici ? ',
          style: TextStyle(
            fontSize: 14, color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/register'),
          child: const Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
