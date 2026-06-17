import 'package:flutter/material.dart';
import '../../core/app_localizations.dart';

class AssistanceView extends StatelessWidget {
  const AssistanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.assistance, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.howCanWeHelp,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 24),
          _buildSupportCard(
            l10n.contactAgent,
            l10n.agentHours,
            Icons.chat_bubble_rounded,
            const Color(0xFF176848),
          ),
          _buildSupportCard(
            l10n.callSupport,
            l10n.tollFree,
            Icons.phone_rounded,
            const Color(0xFF10B981),
          ),
          _buildSupportCard(
            l10n.faq,
            l10n.instantAnswers,
            Icons.help_center_rounded,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.activeRequests,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: Color(0xFF64748B)),
                  const SizedBox(width: 12),
                  Text(l10n.noSupportTicket, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
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
      ),
    );
  }
}
