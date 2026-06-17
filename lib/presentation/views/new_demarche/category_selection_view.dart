import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dossier_provider.dart';
import '../../../core/app_localizations.dart';

class CategorySelectionView extends StatefulWidget {
  const CategorySelectionView({super.key});

  @override
  State<CategorySelectionView> createState() => _CategorySelectionViewState();
}

class _CategorySelectionViewState extends State<CategorySelectionView> {
  List<dynamic>? _categories;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    final provider = context.read<DossierProvider>();
    final categories = await provider.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.newRequest, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : _categories == null || _categories!.isEmpty
              ? _buildEmptyState(l10n)
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _categories!.length,
                  itemBuilder: (context, index) {
                    final cat = _categories![index];
                    return _buildCategoryCard(cat);
                  },
                ),
    );
  }

  Widget _buildCategoryCard(dynamic cat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context, 
              '/demarche_types', 
              arguments: {'id': cat['id'], 'nom': cat['nom']}
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF176848).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(cat['nom']),
                    color: const Color(0xFF176848),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cat['nom'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A), height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('urbanisme') || name.contains('construction')) return Icons.architecture_rounded;
    if (name.contains('état civil') || name.contains('identite')) return Icons.badge_rounded;
    if (name.contains('transport')) return Icons.directions_car_rounded;
    if (name.contains('social')) return Icons.volunteer_activism_rounded;
    if (name.contains('education')) return Icons.school_rounded;
    return Icons.category_rounded;
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(l10n.chooseCategory, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
