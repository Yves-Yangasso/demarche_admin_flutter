import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barre d'en-tête : flèche retour, titre "Nouvelle demande" et
/// l'indicateur visuel des 4 étapes (Type / Infos / Détails / Envoi).
class StepHeader extends StatelessWidget {
  final int currentStep; // index 0 à 3
  final VoidCallback onBack;

  const StepHeader({
    super.key,
    required this.currentStep,
    required this.onBack,
  });

  static const List<String> labels = ['Type', 'Infos', 'Détails', 'Envoi'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.cardBg,
      padding: const EdgeInsets.fromLTRB(4, 6, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textPrimary),
              ),
              const Text(
                'Nouvelle demande',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 4; i++) ...[
                _buildStep(i),
                if (i != 3)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 17, left: 4, right: 4),
                      child: Container(
                        height: 1.5,
                        color: i < currentStep
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int i) {
    final isDone = i < currentStep;
    final isActive = i == currentStep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isActive) ? AppColors.primary : Colors.white,
            border: Border.all(
              color:
                  (isDone || isActive) ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          labels[i],
          style: TextStyle(
            fontSize: 11.5,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
