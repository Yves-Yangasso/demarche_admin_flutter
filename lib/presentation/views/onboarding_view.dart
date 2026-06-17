import 'package:flutter/material.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF176848);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              

              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                 
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:  Image.asset("assets/images/logo.png")
              ),

              const SizedBox(height: 32),

              const Text(
                "Simplifiez vos démarches administratives",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Effectuez vos demandes administratives, suivez l'état de vos dossiers en temps réel et bénéficiez de l'assistance de notre IA pour vous accompagner à chaque étape.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.speed_rounded, color: primaryColor),
                  SizedBox(width: 8),
                  Text("Rapide"),
                  SizedBox(width: 20),
                  Icon(Icons.track_changes_rounded, color: primaryColor),
                  SizedBox(width: 8),
                  Text("Suivi"),
                  SizedBox(width: 20),
                  Icon(Icons.smart_toy_rounded, color: primaryColor),
                  SizedBox(width: 8),
                  Text("IA"),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/login');
                  },
                  child: const Text(
                    "Commencer",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}