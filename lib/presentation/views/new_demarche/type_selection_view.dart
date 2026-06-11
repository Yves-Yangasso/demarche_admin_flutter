import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dossier_provider.dart';

class TypeSelectionView extends StatefulWidget {
  const TypeSelectionView({super.key});

  @override
  State<TypeSelectionView> createState() => _TypeSelectionViewState();
}

class _TypeSelectionViewState extends State<TypeSelectionView> {
  List<dynamic>? _types;
  bool _isLoading = true;
  String? _categoryName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _categoryName = args['nom'];
    _fetchTypes(args['id']);
  }

  Future<void> _fetchTypes(int categoryId) async {
    final provider = context.read<DossierProvider>();
    final types = await provider.getDemarches(categoryId);
    if (mounted) {
      setState(() {
        _types = types;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_categoryName ?? "Démarches", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : _types == null || _types!.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _types!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final type = _types![index];
                    return _buildTypeCard(type);
                  },
                ),
    );
  }

  Widget _buildTypeCard(dynamic type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          type['nom'],
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            "Service administratif • Disponibilité immédiate",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF0F172A)),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Formulaire pour : ${type['nom']} bientôt disponible"),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Aucun service disponible", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
