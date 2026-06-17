// lib/presentation/views/dossier/dossier_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_localizations.dart';
import '../../../models/models.dart';
import '../../../workflow/status.dart';
import '../../providers/dossier_provider.dart';
import '../../../workflow/status.dart';

class DossierDetailView extends StatelessWidget {
  final Dossier dossier;
  const DossierDetailView({super.key, required this.dossier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRejected = dossier.statut.toLowerCase().contains('rejet');
    final isApproved = dossier.statut.toLowerCase().contains('approuv') ||
        dossier.statut.toLowerCase().contains('valid');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(l10n.dossierDetail,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            _buildStatusBanner(isRejected, isApproved),
            const SizedBox(height: 20),

            // Dossier card
            _buildDossierCard(l10n),
            const SizedBox(height: 20),

            // Timeline / History
            const Text('Historique du dossier',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            _buildTimeline(),

            if (isRejected) ...[
              const SizedBox(height: 20),
              // Rejection reason
              _buildRejectionCard(),
              const SizedBox(height: 20),
              // Correct button
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/dossier_correction',
                  arguments: dossier,
                ),
                icon: const Icon(Icons.edit_rounded),
                label: Text(l10n.correctAndResubmit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],

            if (isApproved) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded),
                label: const Text('Télécharger le document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showMessages(context),
              icon: const Icon(Icons.forum_rounded),
              label: const Text('Messages / Fil de discussion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(bool isRejected, bool isApproved) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    if (isRejected) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFEF4444);
      icon = Icons.cancel_rounded;
      label = 'Dossier rejeté';
    } else if (isApproved) {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      label = 'Dossier approuvé';
    } else {
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF176848);
      icon = Icons.autorenew_rounded;
      label = 'En cours d\'instruction';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildDossierCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _infoRow(l10n.dossierRef, dossier.reference),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _infoRow(l10n.dossierType, dossier.typeDemarche.nom),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _infoRow(l10n.dossierStatus, dossier.statut.toUpperCase()),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _infoRow(l10n.dossierDate,
              '${dossier.dateSoumission.day}/${dossier.dateSoumission.month}/${dossier.dateSoumission.year}'),
          if (dossier.priorite != null) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _infoRow('Priorité', dossier.priorite!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final tracking = DossierTracking.fromDossier(dossier);
    return Column(
      children: tracking.steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isLast = i == tracking.steps.length - 1;
        return _buildTimelineItem(step, isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineItem(TrackingStep step, bool isLast) {
    Color circleColor;
    Widget icon;

    switch (step.status) {
      case StepStatus.done:
        circleColor = const Color(0xFF10B981);
        icon = const Icon(Icons.check_rounded, color: Colors.white, size: 13);
        break;
      case StepStatus.active:
        circleColor = const Color(0xFF176848);
        icon = Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle));
        break;
      case StepStatus.pending:
        circleColor = const Color(0xFFE2E8F0);
        icon = const SizedBox.shrink();
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: icon,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.status == StepStatus.done
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 4),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step.status == StepStatus.active
                      ? const Color(0xFFEFF6FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: step.status == StepStatus.active
                        ? const Color(0xFF176848).withValues(alpha: 0.3)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: step.status == StepStatus.pending
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(step.subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: step.status == StepStatus.active
                                ? const Color(0xFF176848)
                                : const Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 8),
              Text('Motif du rejet',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7F1D1D), fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dossier.description ?? 'Votre dossier a été rejeté. Veuillez corriger les informations manquantes ou incorrectes et soumettre à nouveau.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showMessages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _MessagesSheet(dossierId: dossier.id),
    );
  }
}

class _MessagesSheet extends StatefulWidget {
  final int dossierId;
  const _MessagesSheet({required this.dossierId});

  @override
  State<_MessagesSheet> createState() => _MessagesSheetState();
}

class _MessagesSheetState extends State<_MessagesSheet> {
  final _msgCtrl = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await context.read<DossierProvider>().getMessages(widget.dossierId);
    setState(() {
      _messages = msgs;
      _loading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    
    _msgCtrl.clear();
    final res = await context.read<DossierProvider>().sendMessage(widget.dossierId, text);
    if (res != null) {
      _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Fil de discussion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const Divider(),
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                  ? const Center(child: Text('Aucun message', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (ctx, i) {
                        final msg = _messages[i];
                        final isMe = msg['sender_type'] == 'citoyen';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF176848) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg['contenu'] ?? '',
                              style: TextStyle(color: isMe ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Votre message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF176848),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
