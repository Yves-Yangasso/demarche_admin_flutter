import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          ? await authProvider.verifyPhoneOtp(
              _phoneController.text, _codeController.text)
          : await authProvider.verifyEmailOtp(
              _emailController.text, _codeController.text);

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
                  //  _buildLogo(),
                  // const SizedBox(height: 40),
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
        Image.asset(
          "assets/images/logo.png",
            width: MediaQuery.of(context).size.height*0.4,
            height: MediaQuery.of(context).size.height*0.4,   
        ),
         SizedBox(height: MediaQuery.of(context).size.height*0.01),
      ],
    );
  }

  Widget _buildLoginForm() {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           _buildLogo(),
         const Center(
          child:  Text(
          "L'administration simplifiée",
          style: TextStyle(fontSize: 14, color: Color(0xFF176848), fontWeight: FontWeight.w500),
          ),
         ),
           SizedBox(height: MediaQuery.of(context).size.height*0.05),
          if (!_codeSent) ...[
            Container(
              height: 55,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,

                // IMPORTANT
                tabAlignment: TabAlignment.fill,

                indicatorSize: TabBarIndicatorSize.tab,

                indicator: BoxDecoration(
                  color: const Color(0xFF176848),
                  borderRadius: BorderRadius.circular(8),
                ),

                labelColor: Colors.white,

                unselectedLabelColor: const Color(0xFF64748B),

                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),

                labelPadding: EdgeInsets.zero,

                tabs: const [
                  Tab(
                    icon: Icon(Icons.phone),
                    text: "Téléphone",
                  ),
                  Tab(
                    icon: Icon(Icons.email),
                    text: "Email",
                  ),
                ],

                dividerColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 60,
              child: TabBarView(
                controller: _tabController,
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "778616109",
                      prefixIcon: Icon(Icons.phone_iphone_rounded, size: 20),
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "exemple@mail.com",
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              "Code de vérification",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              "Saisissez le code reçu par ${_tabController.index == 0 ? 'SMS' : 'Email'}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, letterSpacing: 6, fontWeight: FontWeight.w900),
              decoration: const InputDecoration(hintText: "000000"),
            ),
            TextButton(
              onPressed: () => setState(() => _codeSent = false),
              child: const Text("Changer de méthode",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : (_codeSent ? _verifyCode : _sendCode),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(_codeSent ? "Vérifier" : "Se connecter"),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Nouveau ici ?",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                child: const Text("Créer un compte",
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
