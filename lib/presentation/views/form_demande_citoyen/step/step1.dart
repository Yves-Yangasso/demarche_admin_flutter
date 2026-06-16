import 'package:flutter/material.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/widget/form1.dart';

class Step1Identification extends StatelessWidget {
  final TextEditingController code, nom, nomWolof, description, telephone;

  const Step1Identification({
    super.key,
    required this.code,
    required this.nom,
    required this.nomWolof,
    required this.description,
    required this.telephone,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:Center(child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _badge("Demande", Colors.blue),
          const SizedBox(height: 10),
          const Text("Faire une demande",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text("Identification",
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 24),

           CustomTextField(
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Description requise"
                      : null,
                  controller: code,
                  labelText: "CNI NO",
                  prefixIcon: Icons.perm_identity),
          const SizedBox(height: 14),

           CustomTextField(
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Description requise"
                      : null,
                  controller: nom,
                  labelText: "Nom",
                  prefixIcon: Icons.title),
          const SizedBox(height: 8),

          TextField(
            decoration: _inputDecoration("Date de naissance", "JJ/MM/AAAA")
                .copyWith(prefixIcon: const Icon(Icons.calendar_today_outlined)),
          ),
          const SizedBox(height: 8),

            CustomTextField(
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Description requise"
                      : null,
                  controller: nomWolof,
                  labelText: "Nom Wolof",
                  prefixIcon: Icons.transcribe),
          const SizedBox(height: 8),

           CustomTextField(
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Description requise"
                      : null,
                  controller: description,
                  labelText: "Description",
                  prefixIcon: Icons.description),
          const SizedBox(height: 8),

            CustomTextField(
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Description requise"
                      : null,
                  controller: telephone,
                  labelText: "Telephone",
                  prefixIcon: Icons.phone),
          const SizedBox(height: 14),
        ],
      ),
    )
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }

  InputDecoration _inputDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}