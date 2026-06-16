import 'package:flutter/material.dart';
import '../models/demande_model.dart';
import '../theme/app_theme.dart';
import '../widgets/step_header.dart';
import 'step1_type.dart';
import 'step2_info.dart';
import 'step3_details.dart';
import 'step4_review.dart';

/// Écran principal : gère l'état global de la demande et la navigation
/// entre les 4 étapes (Type, Infos, Détails, Envoi). Le contenu est
/// centré et limité en largeur (maxWidth) afin de rester lisible et
/// responsive sur tablette / desktop, tout en restant fluide sur mobile.
class NewRequestFlow extends StatefulWidget {
  const NewRequestFlow({super.key});

  @override
  State<NewRequestFlow> createState() => _NewRequestFlowState();
}

class _NewRequestFlowState extends State<NewRequestFlow> {
  int currentStep = 0;
  final DemandeModel data = DemandeModel();
  final ScrollController scrollController = ScrollController();

  final GlobalKey<FormState> step1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> step2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> step3Key = GlobalKey<FormState>();

  static const double maxContentWidth = 480;

  void _goNext() {
    final keys = [step1Key, step2Key, step3Key];
    if (currentStep < 3) {
      final key = keys[currentStep];
      if (key.currentState != null && !key.currentState!.validate()) {
        return;
      }
      setState(() => currentStep++);
      _scrollToTop();
    } else {
      _submit();
    }
  }

  void _goBack() {
    if (currentStep == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => currentStep--);
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void _submit() {
    if (!data.certifie) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Veuillez certifier l'exactitude des informations."),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 10),
            Text('Demande envoyée'),
          ],
        ),
        content: const Text(
          'Votre demande a bien été soumise. Vous recevrez un email de confirmation avec votre numéro de suivi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Form(key: step1Key, child: Step1Type(data: data)),
      Form(key: step2Key, child: Step2Info(data: data)),
      Form(key: step3Key, child: Step3Details(data: data)),
      Step4Review(
        data: data,
        onEdit: (i) {
          setState(() => currentStep = i);
          _scrollToTop();
        },
      ),
    ];

    final horizontalPadding = MediaQuery.of(context).size.width >= 600
        ? 32.0
        : 20.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            StepHeader(currentStep: currentStep, onBack: _goBack),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                    horizontalPadding, 20, horizontalPadding, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Visibility(maintainState: true) garde l'état de
                      // chaque étape déjà visitée (texte saisi, fichiers
                      // ajoutés...) tout en n'occupant aucune place dans
                      // la mise en page lorsqu'elle n'est pas active.
                      children: List.generate(4, (i) {
                        return Visibility(
                          visible: i == currentStep,
                          maintainState: true,
                          child: pages[i],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomBar(horizontalPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(double horizontalPadding) {
    final isLastStep = currentStep == 3;
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 16),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Row(
            children: [
              if (currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              if (currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLastStep ? AppColors.success : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLastStep)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.send, size: 17, color: Colors.white),
                        ),
                      Text(
                        isLastStep ? 'Soumettre' : 'Suivant',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
