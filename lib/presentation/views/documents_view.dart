import 'package:flutter/material.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Mes documents", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildDocumentItem("Carte d'Identité", "Validé", Icons.badge_rounded, Colors.green),
          _buildDocumentItem("Justificatif de domicile", "En attente", Icons.description_rounded, Colors.orange),
          _buildDocumentItem("Permis de conduire", "Validé", Icons.directions_car_rounded, Colors.green),
          _buildDocumentItem("Avis d'imposition", "À fournir", Icons.article_rounded, Colors.red),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildDocumentItem(String title, String status, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(status, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
