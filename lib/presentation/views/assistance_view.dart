import 'package:flutter/material.dart';

class AssistanceView extends StatelessWidget {
  const AssistanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Assistance", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Comment pouvons-nous vous aider ?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 24),
          _buildSupportCard(
            "Contacter un agent",
            "Disponible de 8h à 18h",
            Icons.chat_bubble_rounded,
            const Color(0xFF2563EB),
          ),
          _buildSupportCard(
            "Appeler le service client",
            "Numéro vert gratuit",
            Icons.phone_rounded,
            const Color(0xFF10B981),
          ),
          _buildSupportCard(
            "Foire aux questions",
            "Réponses immédiates",
            Icons.help_center_rounded,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 32),
          const Text(
            "Demandes en cours",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.history_rounded, color: Color(0xFF64748B)),
                SizedBox(width: 12),
                Text("Aucun ticket d'assistance ouvert", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {},
      ),
    );
  }
}
