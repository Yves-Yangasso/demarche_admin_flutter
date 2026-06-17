import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dossier_provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_localizations.dart';

class DocumentsView extends StatefulWidget {
  const DocumentsView({super.key});

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DossierProvider>().fetchDossiers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dossierProvider = context.watch<DossierProvider>();
    final dossiers = dossierProvider.dossiers;

    // Extract all documents from all dossiers
    final List<Map<String, dynamic>> allDocs = [];
    for (var dossier in dossiers) {
      if (dossier.documents != null) {
        for (var doc in dossier.documents!) {
          allDocs.add({
            'dossier_id': dossier.reference,
            'doc': doc,
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.myDocuments, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
      ),
      body: dossierProvider.isLoading && dossiers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : allDocs.isEmpty
              ? Center(
                  child: Text(
                    l10n.noDossier,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: allDocs.length,
                  itemBuilder: (context, index) {
                    final item = allDocs[index];
                    final doc = item['doc'] as Map<String, dynamic>;
                    final dossierRef = item['dossier_id'] as String;

                    final nom = doc['nom'] ?? 'Document';
                    final valide = doc['valide'];
                    
                    String status;
                    Color color;
                    IconData icon;

                    if (valide == true) {
                      status = l10n.docValidated;
                      color = Colors.green;
                      icon = Icons.check_circle_rounded;
                    } else if (valide == false) {
                      status = l10n.docRejected;
                      color = Colors.red;
                      icon = Icons.cancel_rounded;
                    } else {
                      status = l10n.dossierPending;
                      color = Colors.orange;
                      icon = Icons.pending_rounded;
                    }

                    return _buildDocumentItem(nom, status, dossierRef, icon, color, l10n);
                  },
                ),
    );
  }

  Widget _buildDocumentItem(String title, String status, String dossierRef, IconData icon, Color color, AppLocalizations l10n) {
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
                const SizedBox(height: 2),
                Text('${l10n.dossierRef}: $dossierRef', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
