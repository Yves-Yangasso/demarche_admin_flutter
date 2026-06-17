import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dossier_provider.dart';
import '../../../core/app_localizations.dart';

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
    final orgId = args['organisation_id'] as int?;
    final catId = args['id'] as int?;
    _orgArgs = args;
    _fetchTypes(catId, orgId);
  }

  Map<String, dynamic>? _orgArgs;

  Future<void> _fetchTypes(int? categoryId, int? organisationId) async {
    final provider = context.read<DossierProvider>();
    final types = await provider.getDemarches(categoryId, organisationId: organisationId);
    if (mounted) {
      setState(() {
        _types = types;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_categoryName ?? l10n.chooseDemarcheType, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : _types == null || _types!.isEmpty
              ? _buildEmptyState(l10n)
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          title: Text(
            type['nom'],
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              AppLocalizations.of(context).dossierType,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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
            Navigator.pushNamed(
              context, 
              '/request_stepper', 
              arguments: {
                'type_id': type['id'],
                'type_nom': type['nom'],
                'prix': type['prix'] ?? 0,
                'organisation_nom': type['organisation_nom'] ?? _orgArgs?['organisation_nom'] ?? '',
                'categorie_nom': _categoryName,
              }
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(l10n.chooseDemarcheType, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
