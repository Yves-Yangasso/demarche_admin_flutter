import 'package:flutter/material.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/btn_navigation/btn_navigation.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/build_step_indicator/step_indicator.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/step/step1.dart';


import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/step/step2.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/step/step3.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/step/step4.dart';


class FormDemandeView extends StatefulWidget {
  const FormDemandeView({super.key});

  @override
  State<FormDemandeView> createState() => _FormDemandeState();
}

class _FormDemandeState extends State<FormDemandeView> {
  final PageController _controller = PageController();
  int currentStep = 0;

final code = TextEditingController();
  final nom = TextEditingController();
  final nomWolof = TextEditingController();
  final description = TextEditingController();
  final telephone = TextEditingController();
  final nomPere = TextEditingController();
  final nomMere = TextEditingController();

  Map<String, String?> fichiers = {};
  bool acceptedTerms = false;
  //String gender = "Femme";
  //bool acceptedTerms = true;

  void goTo(int step) {
    _controller.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => currentStep = step);
  }

  void _submit() {
    // logique de soumission finale
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              buildStepIndicator(currentStep: currentStep),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => currentStep = i),
                  children: [
                    Step1Identification(
                      code: code,
                      nom: nom,
                      nomWolof: nomWolof,
                      description: description,
                      telephone: telephone,
                    ),
                    Step2Profile(
                      nomPere: nomPere,
                      nomMere: nomMere,
                    ),
                    Step3PiecesJointes(
                      onFilesChanged: (f) => setState(() => fichiers = f),
                    ),
                    Step4Confirm(
                      nom: nom.text,
                      telephone: telephone.text,
                      numeroCni: code.text,
                      fichiers: fichiers,
                      accepted: acceptedTerms,
                      onAcceptedChange: (v) => setState(() => acceptedTerms = v),
                    ),
                  ],
                ),
              ),
              buildButtons(
                currentStep: currentStep,
                goTo: goTo,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}