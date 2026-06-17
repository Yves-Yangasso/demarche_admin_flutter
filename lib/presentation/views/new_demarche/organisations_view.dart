// lib/presentation/views/new_demarche/organisations_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../providers/dossier_provider.dart';

// ─── Constantes ───────────────────────────────────────────────────────────────

const _kRegions = [
  'Toutes les régions', 'Dakar', 'Thiès', 'Saint-Louis', 'Ziguinchor',
  'Kaolack', 'Diourbel', 'Louga', 'Fatick', 'Kolda',
  'Tambacounda', 'Kaffrine', 'Kédougou', 'Matam', 'Sédhiou',
];

const _kTypes = [
  {'key': 'all',       'label': 'Tous',      'icon': Icons.apps_rounded},
  {'key': 'mairie',    'label': 'Mairie',    'icon': Icons.account_balance_rounded},
  {'key': 'police',    'label': 'Police',    'icon': Icons.local_police_rounded},
  {'key': 'justice',   'label': 'Justice',   'icon': Icons.gavel_rounded},
  {'key': 'sante',     'label': 'Santé',     'icon': Icons.health_and_safety_rounded},
  {'key': 'transport', 'label': 'Transport', 'icon': Icons.directions_car_rounded},
  {'key': 'education', 'label': 'Éducation', 'icon': Icons.school_rounded},
];

const _kSortOptions = ['Nom (A → Z)', 'Nom (Z → A)', 'Plus de services'];

// ─── Widget principal ─────────────────────────────────────────────────────────

class OrganisationsView extends StatefulWidget {
  const OrganisationsView({super.key});

  @override
  State<OrganisationsView> createState() => _OrganisationsViewState();
}

class _OrganisationsViewState extends State<OrganisationsView> {
  List<dynamic>? _organisations;
  List<dynamic>? _filtered;
  bool _isLoading = true;
  bool _showFilters = false;

  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();

  String _selectedType   = 'all';
  String _selectedRegion = 'Toutes les régions';
  String _selectedSort   = 'Nom (A → Z)';

  @override
  void initState() {
    super.initState();
    _loadOrganisations();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadOrganisations() async {
    setState(() => _isLoading = true);
    try {
      final orgs = await context.read<DossierProvider>().getOrganisations();
      setState(() { _organisations = orgs; _isLoading = false; });
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (_organisations == null) return;
    final q = _searchCtrl.text.trim().toLowerCase();

    List<dynamic> result = _organisations!.where((o) {
      final nomMatch    = (o['nom']         ?? '').toString().toLowerCase().contains(q);
      final descMatch   = (o['description'] ?? '').toString().toLowerCase().contains(q);
      final regionMatch = (o['region']      ?? '').toString().toLowerCase().contains(q);
      if (q.isNotEmpty && !nomMatch && !descMatch && !regionMatch) return false;
      if (_selectedType != 'all') {
        if ((o['type'] ?? '').toString().toLowerCase() != _selectedType) return false;
      }
      if (_selectedRegion != 'Toutes les régions') {
        if ((o['region'] ?? '').toString() != _selectedRegion) return false;
      }
      return true;
    }).toList();

    switch (_selectedSort) {
      case 'Nom (A → Z)': result.sort((a, b) => (a['nom'] ?? '').toString().compareTo((b['nom'] ?? '').toString())); break;
      case 'Nom (Z → A)': result.sort((a, b) => (b['nom'] ?? '').toString().compareTo((a['nom'] ?? '').toString())); break;
      case 'Plus de services': result.sort((a, b) => ((b['nb_types'] ?? 0) as int).compareTo((a['nb_types'] ?? 0) as int)); break;
    }

    setState(() => _filtered = result);
  }

  void _resetFilters() {
    setState(() {
      _selectedType   = 'all';
      _selectedRegion = 'Toutes les régions';
      _selectedSort   = 'Nom (A → Z)';
      _searchCtrl.clear();
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _selectedType != 'all' ||
      _selectedRegion != 'Toutes les régions' ||
      _selectedSort != 'Nom (A → Z)' ||
      _searchCtrl.text.isNotEmpty;

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            const SizedBox(height: 8),
            _buildTypeChips(),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _showFilters ? _buildAdvancedFilters() : const SizedBox.shrink(),
            ),
            _buildResultsHeader(),
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : (_filtered == null || _filtered!.isEmpty)
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _loadOrganisations,
                          color: AppTheme.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: _filtered!.length,
                            itemBuilder: (context, i) => _buildOrgCard(_filtered![i], i),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header avec barre de progression ─────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Bouton retour
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textDark, size: 18),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisir une organisation',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Étape 1 sur 3',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton filtres
              GestureDetector(
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _hasActiveFilters ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: _hasActiveFilters ? Colors.white : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Filtres',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _hasActiveFilters ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
                      if (_hasActiveFilters) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Barre de progression étapes ──────────────────────────────
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i == 0 ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  // ─── Barre de recherche pill ───────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
        decoration: InputDecoration(
          hintText: 'Rechercher une organisation...',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search_rounded, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textMuted),
                  onPressed: () { _searchCtrl.clear(); _applyFilters(); },
                )
              : null,
        ),
      ),
    );
  }

  // ─── Chips type (pill) ─────────────────────────────────────────────────────

  Widget _buildTypeChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _kTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = _kTypes[i];
          final key = t['key'] as String;
          final isSelected = _selectedType == key;
          return GestureDetector(
            onTap: () { setState(() => _selectedType = key); _applyFilters(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                boxShadow: isSelected ? AppTheme.primaryShadow : AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t['icon'] as IconData,
                    size: 15,
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Filtres avancés ───────────────────────────────────────────────────────

  Widget _buildAdvancedFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Filtres avancés',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
              const Spacer(),
              if (_hasActiveFilters)
                GestureDetector(
                  onTap: _resetFilters,
                  child: const Text('Réinitialiser',
                      style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDropdownRow(
            icon: Icons.location_on_rounded,
            label: 'Région',
            value: _selectedRegion,
            items: _kRegions,
            onChanged: (val) { setState(() => _selectedRegion = val!); _applyFilters(); },
          ),
          const SizedBox(height: 10),
          _buildDropdownRow(
            icon: Icons.sort_rounded,
            label: 'Trier par',
            value: _selectedSort,
            items: _kSortOptions,
            onChanged: (val) { setState(() => _selectedSort = val!); _applyFilters(); },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 6),
        Text('$label :', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textMuted),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                items: items.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Compteur résultats ────────────────────────────────────────────────────

  Widget _buildResultsHeader() {
    final count = _filtered?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: Text(
              '$count résultat${count > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary,
              ),
            ),
          ),
          const Spacer(),
          if (_isLoading)
            const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
            ),
        ],
      ),
    );
  }

  // ─── Carte organisation ────────────────────────────────────────────────────

  Widget _buildOrgCard(dynamic org, int index) {
    final color  = _colorForType(org['type'] ?? '');
    final icon   = _iconForType(org['type'] ?? '', org['nom'] ?? '');
    final region = org['region']?.toString() ?? '';
    final nbTypes = org['nb_types'] ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + index * 40),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/organisation_categories',
              arguments: {
                'id': org['id'],
                'nom': org['nom'],
                'description': org['description'],
                'type': org['type'],
                'region': region,
                'color': color.toARGB32(),
              },
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ── Icône ────────────────────────────────────────────
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  // ── Contenu ───────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org['nom'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppTheme.textDark,
                          ),
                        ),
                        if ((org['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            org['description'],
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (region.isNotEmpty) ...[
                              _buildBadge(
                                icon: Icons.location_on_rounded,
                                label: region,
                                bgColor: AppTheme.surfaceGrey,
                                textColor: AppTheme.textMuted,
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (nbTypes > 0)
                              _buildBadge(
                                label: '$nbTypes service${nbTypes > 1 ? 's' : ''}',
                                bgColor: color.withValues(alpha: 0.1),
                                textColor: color,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ── Chevron ───────────────────────────────────────────
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    IconData? icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }

  // ─── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 88,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
      ),
    );
  }

  // ─── État vide ─────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textLight),
              ),
              const SizedBox(height: 20),
              const Text(
                'Aucune organisation trouvée',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Essayez de modifier vos filtres\nou votre recherche',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                label: const Text('Réinitialiser', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 44),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'mairie':
      case 'commune':   return AppTheme.primary;
      case 'police':    return const Color(0xFF1E40AF);
      case 'justice':   return const Color(0xFF7C3AED);
      case 'sante':
      case 'santé':     return AppTheme.success;
      case 'transport': return AppTheme.error;
      case 'education':
      case 'éducation': return AppTheme.warning;
      default:          return const Color(0xFF0EA5E9);
    }
  }

  IconData _iconForType(String type, String name) {
    switch (type.toLowerCase()) {
      case 'mairie':
      case 'commune':   return Icons.account_balance_rounded;
      case 'police':    return Icons.local_police_rounded;
      case 'justice':   return Icons.gavel_rounded;
      case 'sante':
      case 'santé':     return Icons.health_and_safety_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'education':
      case 'éducation': return Icons.school_rounded;
      default:
        final n = name.toLowerCase();
        if (n.contains('mairie') || n.contains('commune')) return Icons.account_balance_rounded;
        if (n.contains('police'))  return Icons.local_police_rounded;
        if (n.contains('justice') || n.contains('tribunal')) return Icons.gavel_rounded;
        if (n.contains('santé')   || n.contains('hôpital'))  return Icons.health_and_safety_rounded;
        if (n.contains('transport')) return Icons.directions_car_rounded;
        if (n.contains('éducation') || n.contains('école') || n.contains('académie')) return Icons.school_rounded;
        return Icons.business_rounded;
    }
  }
}
