import 'package:flutter/material.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/widget/form1.dart';
import 'package:terreadmin_mobile/workflow/exemple.dart';
import 'package:terreadmin_mobile/workflow/workflow.dart';

class Step2Profile extends StatelessWidget {
  final TextEditingController nomPere, nomMere;

  const Step2Profile({
    super.key,
    required this.nomPere,
    required this.nomMere,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filiation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text("Informations sur vos parents",
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child:  CustomTextField(
                  validator: (value) => (value == null || value.isEmpty)
                      ? " requise"
                      : null,
                  controller: nomMere,
                  labelText: "Nom de pere",
                  prefixIcon: Icons.person),
              ),
              const SizedBox(width: 10),
              Expanded(
                child:   CustomTextField(
                  validator: (value) => (value == null || value.isEmpty)
                      ? " requise"
                      : null,
                  controller: nomMere,
                  labelText: "Nom de la mere",
                  prefixIcon: Icons.person_2),
              ),
              FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SuiviDossierScreen(dossier: exampleDossier)),
    );
  },
  child: const Icon(Icons.arrow_forward),
),
            ],
          ),
        ],
      ),
    )
    );
  }


}