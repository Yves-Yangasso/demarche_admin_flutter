import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/demande_model.dart';
import '../theme/app_theme.dart';
import '../widgets/form_widgets.dart';

class Step4Review extends StatefulWidget {
  final DemandeModel data;
  final void Function(int step) onEdit;

  const Step4Review({super.key, required this.data, required this.onEdit});

  @override
  State<Step4Review> createState() => _Step4ReviewState();
}

class _Step4ReviewState extends State<Step4Review> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final dateStr = data.dateNaissance == null
        ? '—'
        : DateFormat('dd/MM/yyyy').format(data.dateNaissance!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Vérification et envoi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Vérifiez les informations avant d'envoyer votre demande.",
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        SectionCard(
          children: [
            const Text(
              'Récapitulatif de votre demande',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _section('Type de document', [
              _row('Type de document', data.document ?? '—',
                  onEdit: () => widget.onEdit(0)),
              _row('Catégorie', data.categorie ?? '—'),
              _row('Objectif', data.objectif ?? '—'),
            ]),
            _section('Informations personnelles', [
              _row('Nom complet',
                  data.nomComplet.isEmpty ? '—' : data.nomComplet,
                  onEdit: () => widget.onEdit(1)),
              _row('Date de naissance', dateStr),
              _row('Lieu de naissance',
                  data.lieuNaissance.isEmpty ? '—' : data.lieuNaissance),
              _row('Email', data.email.isEmpty ? '—' : data.email),
              _row('Téléphone',
                  data.telephone.isEmpty ? '—' : data.telephone),
            ]),
            _section('Détails de la demande', [
              _row('Motif', data.motif ?? '—', onEdit: () => widget.onEdit(2)),
              _row('Urgence', data.urgence ?? 'Normale'),
              _row('Nombre de pièces jointes',
                  '${data.pieces.length} fichier(s)'),
            ], isLast: true),
          ],
        ),
        const SizedBox(height: 0),
        const NoticeBox(
          icon: Icons.error_outline,
          title: 'Important',
          message:
              'En soumettant votre demande, vous confirmez que toutes les informations fournies sont exactes et que vous avez joint les pièces justificatives requises.',
          background: AppColors.warningLight,
          border: AppColors.warningBorder,
          foreground: AppColors.warningText,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => setState(() => data.certifie = !data.certifie),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: data.certifie,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => data.certifie = v ?? false),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "Je certifie l'exactitude des informations fournies *",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NoticeBox(
          icon: Icons.watch_later_outlined,
          title: "Après l'envoi",
          message:
              "Vous recevrez un email de confirmation avec le numéro de suivi de votre demande. Vous pourrez suivre l'avancement de votre demande en ligne.",
          background: AppColors.successLight,
          border: AppColors.successBorder,
          foreground: AppColors.successText,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _section(String title, List<Widget> rows, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
          if (!isLast)
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 2),
              child: Divider(height: 1, color: AppColors.border),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: const Text(
                'Modifier',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
