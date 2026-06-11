import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _codeSent = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final authProvider = context.read<AuthProvider>();
    try {
      if (_tabController.index == 0) {
        await authProvider.sendPhoneOtp(_phoneController.text);
      } else {
        await authProvider.sendEmailOtp(_emailController.text);
      }
      setState(() => _codeSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    final authProvider = context.read<AuthProvider>();
    try {
      bool success = _tabController.index == 0 
        ? await authProvider.verifyPhoneOtp(_phoneController.text, _codeController.text)
        : await authProvider.verifyEmailOtp(_emailController.text, _codeController.text);

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
                  _buildLogo(),
                  const SizedBox(height: 40),
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          "TerreAdmin",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
        ),
        const Text(
          "L'administration simplifiée",
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
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
          if (!_codeSent) ...[
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                labelColor: const Color(0xFF2563EB),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [Tab(text: "Téléphone"), Tab(text: "Email")],
                dividerColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 70,
              child: TabBarView(
                controller: _tabController,
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "06 00 00 00 00",
                      prefixIcon: Icon(Icons.phone_iphone_rounded),
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "exemple@mail.com",
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              "Code de vérification",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              "Saisissez le code reçu par ${_tabController.index == 0 ? 'SMS' : 'Email'}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w900),
              decoration: const InputDecoration(hintText: "000000"),
            ),
            TextButton(
              onPressed: () => setState(() => _codeSent = false),
              child: const Text("Changer de méthode", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isLoading ? null : (_codeSent ? _verifyCode : _sendCode),
            child: isLoading 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(_codeSent ? "Vérifier" : "Se connecter"),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Nouveau ici ?", style: TextStyle(color: Color(0xFF64748B))),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                child: const Text("Créer un compte", style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
