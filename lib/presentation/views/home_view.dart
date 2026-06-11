import 'package:flutter/material.dart';
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildTrackingCard(),
                const SizedBox(height: 32),
                const Text(
                  'Actions rapides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                _buildQuickActionsGrid(context),
                const SizedBox(height: 32),
                const Text(
                  'Dernière activité',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                _buildRecentActivity(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'TerreAdmin',
        style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A), size: 22),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, Jean ! 👋',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        SizedBox(height: 4),
        Text(
          "Prêt pour vos démarches aujourd'hui ?",
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dossier #TA-8821',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'EN COURS',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Permis de construire',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.65,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 10)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Étape 3 sur 5 : Validation technique',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double crossAxisSpacing = 16;
        double mainAxisSpacing = 16;
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        double width = (constraints.maxWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
        double height = 130; // Fixed height for items
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: width / height,
          children: [
            _buildActionItem(
              'Nouvelle demande',
              Icons.add_rounded,
              const Color(0xFF2563EB),
              () => Navigator.pushNamed(context, '/nouvelle_demande'),
            ),
            _buildActionItem(
              'Mes documents',
              Icons.folder_copy_rounded,
              const Color(0xFF10B981),
              () => Navigator.pushNamed(context, '/documents'),
            ),
            _buildActionItem(
              'Scan QR',
              Icons.qr_code_scanner_rounded,
              const Color(0xFFF59E0B),
              () => Navigator.pushNamed(context, '/scan_qr'),
            ),
            _buildActionItem(
              'Assistance',
              Icons.support_agent_rounded,
              const Color(0xFF6366F1),
              () => Navigator.pushNamed(context, '/assistance'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document validé',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 2),
                Text(
                  "Votre pièce d'identité a été approuvée.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Text(
            'Hier',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
