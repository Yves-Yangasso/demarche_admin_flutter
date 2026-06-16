import 'package:flutter/material.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/widget/pcker_files_ex.dart';

class FileUploadTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final List<String> allowedExtensions;
  final bool isOptional;

  const FileUploadTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.allowedExtensions,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            if (!isOptional)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isOptional)
              const Text(
                ' (optionnel)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue,
              width: 1.5,
            ),
          ),
          child: FilePreviewExample(
            allowedExtension: allowedExtensions,
            messageFile: subtitle,
            indicateSelect: "Choisir",
          ),
        ),
      ],
    );
  }
}