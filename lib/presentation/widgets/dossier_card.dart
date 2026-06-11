import 'package:flutter/material.dart';
import '../../models/models.dart';

class DossierCard extends StatelessWidget {
  final Dossier dossier;
  final VoidCallback? onTap;

  const DossierCard({super.key, required this.dossier, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dossier.typeDemarche.nom,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(dossier.statut),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Réf : ${dossier.reference}",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                _buildProgressSection(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Soumis le ${_formatDate(dossier.dateSoumission)}",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statut) {
    Color color;
    switch (statut.toLowerCase()) {
      case 'cloture':
      case 'validé':
        color = const Color(0xFF10B981);
        break;
      case 'en_cours':
        color = const Color(0xFF2563EB);
        break;
      case 'rejete':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        statut.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progression",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            Text(
              "65%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.65,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
