import 'package:flutter/material.dart';

Widget buildButtons({
  required int currentStep,
  required void Function(int) goTo,
  required VoidCallback onSubmit,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => goTo(currentStep - 1),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text("Retour"),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 10),
        Expanded(
          flex: currentStep > 0 ? 2 : 1,
          child: ElevatedButton.icon(
            onPressed: () {
              if (currentStep < 3) {
                goTo(currentStep + 1);
              } else {
                onSubmit();
              }
            },
            icon: Icon(
              currentStep == 2 ? Icons.check : Icons.arrow_forward,
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              currentStep == 2 ? "Confirmer" : "Continuer",
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStep == 3 ? Colors.green[700] : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    ),
  );
}