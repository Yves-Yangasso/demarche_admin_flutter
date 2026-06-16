import 'package:flutter/material.dart';
import 'package:terreadmin_mobile/presentation/views/form_demande_citoyen/widget/pcker_files.dart';

class Step3PiecesJointes extends StatefulWidget {
  final ValueChanged<Map<String, String?>> onFilesChanged;

  const Step3PiecesJointes({super.key, required this.onFilesChanged});

  @override
  State<Step3PiecesJointes> createState() => _Step3PiecesJointesState();
}

class _Step3PiecesJointesState extends State<Step3PiecesJointes> {
  String? pieceIdentite;
  String? photoIdentite;
  String? justificatifDomicile;

  void _notifyChange() {
    widget.onFilesChanged({
      "piece_identite": pieceIdentite,
      "photo_identite": photoIdentite,
      "justificatif_domicile": justificatifDomicile,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pièces jointes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text("Téléversez les documents",
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 24),

        const  FileUploadTile(
            label: "Pièce d'identité",
            subtitle: "PDF (max. 10 MB)",
            allowedExtensions: ['pdf'],
           
          ),
          const SizedBox(height: 14),

        const  FileUploadTile(
            label: "Photo d'identité",
            subtitle: " PNG, JPG (max. 5 MB)",
            allowedExtensions:  ['jpg', 'jpeg', 'png'],
         
            
          ),
          const SizedBox(height: 14),

        const  FileUploadTile(
            label: "Justificatif de domicile",
            subtitle: " PDF (max. 10 MB)",
            allowedExtensions:  ['pdf'],
            isOptional: true,
          
          ),
        ],
      ),
    );
  }
}