import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/demande_model.dart';
import '../theme/app_theme.dart';
import '../widgets/form_widgets.dart';

class Step2Info extends StatefulWidget {
  final DemandeModel data;
  const Step2Info({super.key, required this.data});

  @override
  State<Step2Info> createState() => _Step2InfoState();
}

class _Step2InfoState extends State<Step2Info> {
  late final TextEditingController nomCtrl =
      TextEditingController(text: widget.data.nomComplet);
  late final TextEditingController lieuCtrl =
      TextEditingController(text: widget.data.lieuNaissance);
  late final TextEditingController idCtrl =
      TextEditingController(text: widget.data.numeroIdentification);
  late final TextEditingController emailCtrl =
      TextEditingController(text: widget.data.email);
  late final TextEditingController telCtrl =
      TextEditingController(text: widget.data.telephone);
  late final TextEditingController adresseCtrl =
      TextEditingController(text: widget.data.adressePostale);

  @override
  void dispose() {
    nomCtrl.dispose();
    lieuCtrl.dispose();
    idCtrl.dispose();
    emailCtrl.dispose();
    telCtrl.dispose();
    adresseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.data.dateNaissance ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Sélectionner la date de naissance',
    );
    if (picked != null) {
      setState(() => widget.data.dateNaissance = picked);
    }
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ requis' : null;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final dateLabel = data.dateNaissance == null
        ? 'jj / mm / aaaa'
        : DateFormat('dd/MM/yyyy').format(data.dateNaissance!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Informations personnelles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Veuillez renseigner vos informations personnelles.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        SectionCard(
          title: "Informations d'identité",
          children: [
            FieldGroup(
              label: 'Nom complet',
              required: true,
              child: TextFormField(
                controller: nomCtrl,
                decoration:
                    const InputDecoration(hintText: 'Entrez votre nom complet'),
                validator: _requiredValidator,
                onChanged: (v) => data.nomComplet = v,
              ),
            ),
            FieldGroup(
              label: 'Date de naissance',
              required: true,
              child: InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    dateLabel,
                    style: TextStyle(
                      color: data.dateNaissance == null
                          ? AppColors.hintColor
                          : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            FieldGroup(
              label: 'Lieu de naissance',
              required: true,
              child: TextFormField(
                controller: lieuCtrl,
                decoration: const InputDecoration(
                    hintText: 'Entrez votre lieu de naissance'),
                validator: _requiredValidator,
                onChanged: (v) => data.lieuNaissance = v,
              ),
            ),
            FieldGroup(
              label: 'Sexe',
              required: true,
              child: DropdownButtonFormField<String>(
                value: data.sexe,
                isExpanded: true,
                hint: const Text('Sélectionnez'),
                items: const ['Homme', 'Femme', 'Autre']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => data.sexe = v),
                validator: (v) => v == null ? 'Champ requis' : null,
              ),
            ),
            FieldGroup(
              label: "Numéro d'identification",
              child: TextFormField(
                controller: idCtrl,
                decoration:
                    const InputDecoration(hintText: 'Entrez votre numéro'),
                onChanged: (v) => data.numeroIdentification = v,
              ),
            ),
          ],
        ),
        SectionCard(
          title: 'Coordonnées',
          children: [
            FieldGroup(
              label: 'Email',
              required: true,
              child: TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'exemple@email.com'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Email invalide';
                  }
                  return null;
                },
                onChanged: (v) => data.email = v,
              ),
            ),
            FieldGroup(
              label: 'Téléphone',
              required: true,
              child: TextFormField(
                controller: telCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(hintText: '06 12 34 56 78'),
                validator: _requiredValidator,
                onChanged: (v) => data.telephone = v,
              ),
            ),
            FieldGroup(
              label: 'Adresse postale',
              required: true,
              child: TextFormField(
                controller: adresseCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Entrez votre adresse complète'),
                validator: _requiredValidator,
                onChanged: (v) => data.adressePostale = v,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
