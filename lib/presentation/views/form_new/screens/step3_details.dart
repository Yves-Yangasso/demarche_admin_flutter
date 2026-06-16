import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/demande_model.dart';
import '../theme/app_theme.dart';
import '../widgets/form_widgets.dart';

class Step3Details extends StatefulWidget {
  final DemandeModel data;
  const Step3Details({super.key, required this.data});

  @override
  State<Step3Details> createState() => _Step3DetailsState();
}

class _Step3DetailsState extends State<Step3Details> {
  late final TextEditingController descCtrl =
      TextEditingController(text: widget.data.description);
  late final TextEditingController autoriteCtrl =
      TextEditingController(text: widget.data.autorite);

  @override
  void dispose() {
    descCtrl.dispose();
    autoriteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        setState(() {
          for (final f in result.files) {
            widget.data.pieces.add(
              PieceJustificative(
                nom: f.name,
                tailleMo: f.size / (1024 * 1024),
              ),
            );
          }
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Impossible d'ouvrir le sélecteur de fichiers sur cette plateforme."),
          ),
        );
      }
    }
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ requis' : null;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Détails de la demande',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Veuillez fournir les informations complémentaires nécessaires.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        SectionCard(
          title: 'Informations complémentaires',
          children: [
            FieldGroup(
              label: 'Motif de la demande',
              required: true,
              child: DropdownButtonFormField<String>(
                value: data.motif,
                isExpanded: true,
                hint: const Text('Sélectionnez le motif'),
                items: motifs
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => data.motif = v),
                validator: (v) => v == null ? 'Champ requis' : null,
              ),
            ),
            FieldGroup(
              label: 'Description détaillée',
              required: true,
              child: TextFormField(
                controller: descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'Décrivez votre demande en détail...'),
                validator: _requiredValidator,
                onChanged: (v) => data.description = v,
              ),
            ),
            FieldGroup(
              label: 'Autorité / organisme destinataire',
              required: true,
              child: TextFormField(
                controller: autoriteCtrl,
                decoration: const InputDecoration(
                    hintText: "Entrez le nom de l'autorité"),
                validator: _requiredValidator,
                onChanged: (v) => data.autorite = v,
              ),
            ),
            FieldGroup(
              label: 'Urgence de la demande',
              child: DropdownButtonFormField<String>(
                value: data.urgence,
                isExpanded: true,
                hint: const Text("Sélectionnez le niveau d'urgence"),
                items: niveauxUrgence
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => data.urgence = v),
              ),
            ),
          ],
        ),
        SectionCard(
          title: 'Pièces justificatives',
          children: [
            InkWell(
              onTap: _pickFiles,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined,
                        size: 30, color: AppColors.primary),
                    const SizedBox(height: 10),
                    const Text(
                      'Glissez-déposez vos fichiers ici',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'ou',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _pickFiles,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Parcourir les fichiers'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Formats acceptés : PDF, JPG, PNG',
                      style: TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const Text(
                      '(Max. 5 Mo par fichier)',
                      style: TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            if (data.pieces.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Documents ajoutés',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...data.pieces.map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_outlined,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nom,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${p.tailleMo.toStringAsFixed(1)} Mo',
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => data.pieces.remove(p)),
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
