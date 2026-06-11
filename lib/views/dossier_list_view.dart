import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/dossier_service.dart';
import 'widgets/dossier_card.dart';

class DossierListView extends StatefulWidget {
  const DossierListView({super.key});

  @override
  State<DossierListView> createState() => _DossierListViewState();
}

class _DossierListViewState extends State<DossierListView> {
  final DossierService _dossierService = DossierService();
  List<Dossier>? _dossiers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDossiers();
  }

  Future<void> _fetchDossiers() async {
    setState(() => _isLoading = true);
    final dossiers = await _dossierService.getMesDossiers();
    setState(() {
      _dossiers = dossiers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mes Dossiers',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 22),
            onPressed: _fetchDossiers,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : _dossiers == null || _dossiers!.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: _dossiers!.length,
                  itemBuilder: (context, index) {
                    return DossierCard(dossier: _dossiers![index]);
                  },
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          elevation: 4,
          onPressed: () => Navigator.pushNamed(context, '/nouvelle_demande'),
          label: const Text("Nouvelle demande", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_rounded, size: 64, color: const Color(0xFF2563EB).withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun dossier trouvé',
            style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Commencez par créer votre première demande.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
