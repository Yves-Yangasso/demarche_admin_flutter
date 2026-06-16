import 'package:flutter/material.dart';
import '../models/demande_model.dart';
import '../theme/app_theme.dart';
import '../widgets/form_widgets.dart';

class Step1Type extends StatefulWidget {
  final DemandeModel data;
  const Step1Type({super.key, required this.data});

  @override
  State<Step1Type> createState() => _Step1TypeState();
}

class _Step1TypeState extends State<Step1Type> {
  static const List<Map<String, dynamic>> quickItems = [
    {'label': 'État civil', 'icon': Icons.groups_2_outlined},
    {'label': 'Identité', 'icon': Icons.badge_outlined},
    {'label': 'Famille', 'icon': Icons.family_restroom_outlined},
    {'label': 'Éducation', 'icon': Icons.school_outlined},
    {'label': 'Social / Santé', 'icon': Icons.health_and_safety_outlined},
    {'label': 'Logement', 'icon': Icons.home_outlined},
    {'label': 'Fiscalité', 'icon': Icons.receipt_long_outlined},
    {'label': 'Justice', 'icon': Icons.gavel_outlined},
    {'label': 'Autre', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    // Responsive : plus de colonnes pour la grille sur les écrans larges
    // (tablette / desktop) que sur un téléphone.
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Type de demande',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sélectionnez le type de document que vous souhaitez demander.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        SectionCard(
          children: [
            FieldGroup(
              label: 'Catégorie du document',
              child: DropdownButtonFormField<String>(
                value: data.categorie,
                isExpanded: true,
                hint: const Text('Choisir une catégorie'),
                items: categories.keys
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() {
                  data.categorie = v;
                  data.document = null;
                }),
              ),
            ),
            FieldGroup(
              label: 'Document demandé',
              child: DropdownButtonFormField<String>(
                value: data.document,
                isExpanded: true,
                hint: const Text('Choisir le document'),
                items: (data.categorie == null
                        ? <String>[]
                        : categories[data.categorie]!)
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: data.categorie == null
                    ? null
                    : (v) => setState(() => data.document = v),
              ),
            ),
            FieldGroup(
              label: 'Objectif de la demande',
              child: DropdownButtonFormField<String>(
                value: data.objectif,
                isExpanded: true,
                hint: const Text("Choisir l'objectif"),
                items: objectifs
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => data.objectif = v),
              ),
            ),
          ],
        ),
        const Text(
          'Sélection rapide',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, i) {
            final item = quickItems[i];
            final label = item['label'] as String;
            final isSelected = data.categorie == label;
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() {
                data.categorie = label;
                data.document = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.infoLight : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        const NoticeBox(
          icon: Icons.info_outline,
          title: 'À propos',
          message:
              'Ces informations nous aident à traiter votre demande plus rapidement.',
          background: AppColors.infoLight,
          border: AppColors.infoBorder,
          foreground: AppColors.primaryDark,
        ),
      ],
    );
  }
}
