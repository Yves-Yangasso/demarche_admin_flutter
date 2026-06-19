import 'package:flutter/material.dart';

class OnboardingView extends StatelessWidget {
 const  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF176848);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              

              Container(
                width: MediaQuery.of(context).size.height*0.4,
                height: MediaQuery.of(context).size.height*0.4,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                 
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child:  Image.asset("assets/images/logo.png", 
                width: MediaQuery.of(context).size.height*0.4,
                height: MediaQuery.of(context).size.height*0.4,            
                 )
              ),

             

              const Text(
                "Simplifiez vos démarches administratives",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),

              

              const Text(
                "Effectuez vos demandes administratives, suivez l'état de vos dossiers en temps réel et bénéficiez de l'assistance de notre IA pour vous accompagner à chaque étape.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.6,
                ),
              ),

            
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.speed_rounded, color: primaryColor),
                  SizedBox(width: 4),
                  Text("Rapide"),
                  SizedBox(width: 4),
                  Icon(Icons.track_changes_rounded, color: primaryColor),
                  SizedBox(width: 4),
                  Text("Suivi"),
                  SizedBox(width: 5),
                  Icon(Icons.smart_toy_rounded, color: primaryColor),
                  SizedBox(width: 5),
                  Text("IA"),
                ],
              ),

             // const Spacer(),
             const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 30,
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

              //const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}