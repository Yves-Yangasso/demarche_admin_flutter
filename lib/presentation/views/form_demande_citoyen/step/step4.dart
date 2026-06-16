import 'package:flutter/material.dart';

class Step4Confirm extends StatelessWidget {
  final String nom;
  final String telephone;
  final String numeroCni;
  final Map<String, String?> fichiers;
  final bool accepted;
  final ValueChanged<bool> onAcceptedChange;

  const Step4Confirm({
    super.key,
    required this.nom,
    required this.telephone,
    required this.numeroCni,
    required this.fichiers,
    required this.accepted,
    required this.onAcceptedChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Presque terminé",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text("Vérifiez et confirmez vos informations",
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _summaryRow("Nom", nom, isFirst: true),
                _summaryRow("Téléphone", telephone),
                _summaryRow("Numéro CNI", numeroCni),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text("Pièces jointes",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...fichiers.entries.map((e) => _fileRow(e.key, e.value)),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: accepted,
                onChanged: (v) => onAcceptedChange(v ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    "J'accepte les conditions d'utilisation et la politique de confidentialité",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isFirst = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: isFirst
            ? null
            : Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _fileRow(String key, String? fileName) {
    final hasFile = fileName != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasFile ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: hasFile ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            hasFile ? "$key : $fileName" : "$key : manquant",
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}