// lib/presentation/views/new_demarche/organisation_categories_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_localizations.dart';
import '../../providers/dossier_provider.dart';

class OrganisationCategoriesView extends StatefulWidget {
  const OrganisationCategoriesView({super.key});

  @override
  State<OrganisationCategoriesView> createState() =>
      _OrganisationCategoriesViewState();
}

class _OrganisationCategoriesViewState
    extends State<OrganisationCategoriesView> {
  List<dynamic>? _categories;
  bool _isLoading = true;
  Map<String, dynamic>? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      _args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<DossierProvider>();
      final cats = await provider.getCategories(
        organisationId: _args?['id'] as int?,
      );
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color get _orgColor {
    final colorValue = _args?['color'] as int?;
    if (colorValue != null) return Color(colorValue);
    return const Color(0xFF176848);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orgName = _args?['nom'] ?? 'Organisation';
    final orgRegion = _args?['region'] ?? '';
    final orgType = _args?['type'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header avec breadcrumb ──────────────────────────────
            _buildHeader(context, orgName, orgRegion, orgType),

            // ── Titre de section ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chooseCategory,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sélectionnez la catégorie de votre démarche',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            // ── Grille de catégories ────────────────────────────────
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : (_categories == null || _categories!.isEmpty)
                      ? _buildEmpty(l10n)
                      : RefreshIndicator(
                          onRefresh: _loadCategories,
                          color: _orgColor,
                          child: GridView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(20, 4, 20, 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _categories!.length,
                            itemBuilder: (context, i) =>
                                _buildCategoryCard(_categories![i], i),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header avec breadcrumb ──────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String orgName, String region, String type) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne de navigation
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0F172A), size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _orgColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Étape 2 sur 3',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _orgColor),
                ),
              ),
            ],
          ),
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _orgColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconForType(type), color: _orgColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orgName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF0F172A)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (region.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 10, color: Color(0xFF64748B)),
                              const SizedBox(width: 3),
                              Text(
                                region,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Séparateur chevron
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Catégorie',
                    style: TextStyle(
                        fontSize: 12,
                        color: _orgColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Catégorie ──────────────────────────────────────────────────────────

  Widget _buildCategoryCard(dynamic cat, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + index * 50),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 0.85 + 0.15 * value, child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: _orgColor.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.pushNamed(
              context,
              '/demarche_types',
              arguments: {
                'id': cat['id'],
                'nom': cat['nom'],
                'organisation_id': _args?['id'],
                'organisation_nom': _args?['nom'],
                'color': _orgColor.toARGB32(),
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _orgColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconForCategory(cat['nom'] ?? ''),
                      color: _orgColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['nom'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cat['nb_types'] != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _orgColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cat['nb_types']} service${(cat['nb_types'] as int) > 1 ? 's' : ''}',
                        style: TextStyle(
                            fontSize: 10,
                            color: _orgColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shimmer ─────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  // ── État vide ────────────────────────────────────────────────────────────────

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _orgColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.category_outlined,
                  size: 48, color: _orgColor),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune catégorie disponible',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette organisation n\'a pas encore de\ncatégories configurées.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'mairie':
      case 'commune':
        return Icons.account_balance_rounded;
      case 'police':
        return Icons.local_police_rounded;
      case 'justice':
        return Icons.gavel_rounded;
      case 'sante':
      case 'santé':
        return Icons.health_and_safety_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'education':
      case 'éducation':
        return Icons.school_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  IconData _iconForCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('état civil') || name.contains('civil') || name.contains('naissance')) return Icons.badge_rounded;
    if (name.contains('urbanisme') || name.contains('construction')) return Icons.architecture_rounded;
    if (name.contains('transport') || name.contains('permis')) return Icons.directions_car_rounded;
    if (name.contains('social') || name.contains('aide')) return Icons.volunteer_activism_rounded;
    if (name.contains('education') || name.contains('école') || name.contains('diplôme')) return Icons.school_rounded;
    if (name.contains('santé') || name.contains('médical') || name.contains('certificat')) return Icons.health_and_safety_rounded;
    if (name.contains('commerce') || name.contains('business')) return Icons.store_rounded;
    if (name.contains('judiciaire') || name.contains('casier')) return Icons.gavel_rounded;
    if (name.contains('identité') || name.contains('passeport') || name.contains('cni')) return Icons.credit_card_rounded;
    return Icons.category_rounded;
  }
}
