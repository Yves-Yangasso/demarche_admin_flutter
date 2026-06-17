// lib/presentation/views/new_demarche/organisations_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dossier_provider.dart';

// ─── Constantes de types et régions ──────────────────────────────────────────

const _kRegions = [
  'Toutes les régions',
  'Dakar',
  'Thiès',
  'Saint-Louis',
  'Ziguinchor',
  'Kaolack',
  'Diourbel',
  'Louga',
  'Fatick',
  'Kolda',
  'Tambacounda',
  'Kaffrine',
  'Kédougou',
  'Matam',
  'Sédhiou',
];

const _kTypes = [
  {'key': 'all', 'label': 'Tous', 'icon': Icons.apps_rounded},
  {'key': 'mairie', 'label': 'Mairie', 'icon': Icons.account_balance_rounded},
  {'key': 'police', 'label': 'Police', 'icon': Icons.local_police_rounded},
  {'key': 'justice', 'label': 'Justice', 'icon': Icons.gavel_rounded},
  {'key': 'sante', 'label': 'Santé', 'icon': Icons.health_and_safety_rounded},
  {'key': 'transport', 'label': 'Transport', 'icon': Icons.directions_car_rounded},
  {'key': 'education', 'label': 'Éducation', 'icon': Icons.school_rounded},
];

const _kSortOptions = [
  'Nom (A → Z)',
  'Nom (Z → A)',
  'Plus de services',
];

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

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  // Filtres
  String _selectedType = 'all';
  String _selectedRegion = 'Toutes les régions';
  String _selectedSort = 'Nom (A → Z)';

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
      final provider = context.read<DossierProvider>();
      final orgs = await provider.getOrganisations();
      setState(() {
        _organisations = orgs;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (_organisations == null) return;
    final q = _searchCtrl.text.trim().toLowerCase();

    List<dynamic> result = _organisations!.where((o) {
      // Filtre texte
      final nomMatch = (o['nom'] ?? '').toString().toLowerCase().contains(q);
      final descMatch = (o['description'] ?? '').toString().toLowerCase().contains(q);
      final regionMatch = (o['region'] ?? '').toString().toLowerCase().contains(q);
      if (q.isNotEmpty && !nomMatch && !descMatch && !regionMatch) return false;

      // Filtre type
      if (_selectedType != 'all') {
        final type = (o['type'] ?? '').toString().toLowerCase();
        if (type != _selectedType) return false;
      }

      // Filtre région
      if (_selectedRegion != 'Toutes les régions') {
        final region = (o['region'] ?? '').toString();
        if (region != _selectedRegion) return false;
      }

      return true;
    }).toList();

    // Tri
    switch (_selectedSort) {
      case 'Nom (A → Z)':
        result.sort((a, b) => (a['nom'] ?? '').toString().compareTo((b['nom'] ?? '').toString()));
        break;
      case 'Nom (Z → A)':
        result.sort((a, b) => (b['nom'] ?? '').toString().compareTo((a['nom'] ?? '').toString()));
        break;
      case 'Plus de services':
        result.sort((a, b) => ((b['nb_types'] ?? 0) as int).compareTo((a['nb_types'] ?? 0) as int));
        break;
    }

    setState(() => _filtered = result);
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'all';
      _selectedRegion = 'Toutes les régions';
      _selectedSort = 'Nom (A → Z)';
      _searchCtrl.clear();
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _selectedType != 'all' ||
      _selectedRegion != 'Toutes les régions' ||
      _selectedSort != 'Nom (A → Z)' ||
      _searchCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
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
                          color: const Color(0xFF176848),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                            itemCount: _filtered!.length,
                            itemBuilder: (context, i) =>
                                _buildOrgCard(_filtered![i], i),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisir une organisation',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Color(0xFF0F172A)),
                ),
                Text(
                  'Étape 1 sur 3',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          // Bouton filtres avancés
          GestureDetector(
            onTap: _toggleFilters,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _hasActiveFilters
                    ? const Color(0xFF176848)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasActiveFilters
                      ? const Color(0xFF176848)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: _hasActiveFilters
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _hasActiveFilters
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.circle,
                          size: 6, color: Color(0xFF176848)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barre de recherche ────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: 'Rechercher une organisation ou une région...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchCtrl.clear();
                    _applyFilters();
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF176848), width: 2),
          ),
        ),
      ),
    );
  }

  // ─── Chips de type ─────────────────────────────────────────────────────────

  Widget _buildTypeChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _kTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = _kTypes[i];
          final key = t['key'] as String;
          final isSelected = _selectedType == key;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedType = key);
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF176848)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF176848)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t['icon'] as IconData,
                    size: 15,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
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

  // ─── Filtres avancés (région + tri) ───────────────────────────────────────

  Widget _buildAdvancedFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtres avancés',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                GestureDetector(
                  onTap: _resetFilters,
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF176848),
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Région
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              const Text('Région :',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRegion,
                      isDense: true,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: Color(0xFF64748B)),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A)),
                      items: _kRegions
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRegion = val);
                          _applyFilters();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Tri
          Row(
            children: [
              const Icon(Icons.sort_rounded,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              const Text('Trier par :',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      isDense: true,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: Color(0xFF64748B)),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A)),
                      items: _kSortOptions
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSort = val);
                          _applyFilters();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Compteur de résultats ─────────────────────────────────────────────────

  Widget _buildResultsHeader() {
    final count = _filtered?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            '$count organisation${count > 1 ? 's' : ''} trouvée${count > 1 ? 's' : ''}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B)),
          ),
          const Spacer(),
          if (_isLoading)
            const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  // ─── Card Organisation ─────────────────────────────────────────────────────

  Widget _buildOrgCard(dynamic org, int index) {
    final color = _colorForType(org['type'] ?? '');
    final icon = _iconForType(org['type'] ?? '', org['nom'] ?? '');
    final region = org['region']?.toString() ?? '';
    final nbTypes = org['nb_types'] ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 40),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
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
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icône colorée
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  // Contenu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org['nom'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF0F172A)),
                        ),
                        if ((org['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            org['description'],
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Badge région
                            if (region.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFF1F5F9),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        Icons.location_on_rounded,
                                        size: 10,
                                        color: Color(0xFF64748B)),
                                    const SizedBox(width: 3),
                                    Text(
                                      region,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            // Badge services
                            if (nbTypes > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$nbTypes service${nbTypes > 1 ? 's' : ''}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE2E8F0),
              const Color(0xFFF1F5F9),
              const Color(0xFFE2E8F0),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ─── État vide ─────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 48, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune organisation trouvée',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez de modifier vos filtres ou\nvotre recherche',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Réinitialiser les filtres'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF176848),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers couleur / icône ───────────────────────────────────────────────

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'mairie':
      case 'commune':
        return const Color(0xFF176848);
      case 'police':
        return const Color(0xFF1E40AF);
      case 'justice':
        return const Color(0xFF7C3AED);
      case 'sante':
      case 'santé':
        return const Color(0xFF059669);
      case 'transport':
        return const Color(0xFFEF4444);
      case 'education':
      case 'éducation':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF0EA5E9);
    }
  }

  IconData _iconForType(String type, String name) {
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
        // Fallback sur le nom
        final n = name.toLowerCase();
        if (n.contains('mairie') || n.contains('commune')) return Icons.account_balance_rounded;
        if (n.contains('police')) return Icons.local_police_rounded;
        if (n.contains('justice') || n.contains('tribunal')) return Icons.gavel_rounded;
        if (n.contains('santé') || n.contains('hôpital')) return Icons.health_and_safety_rounded;
        if (n.contains('transport')) return Icons.directions_car_rounded;
        if (n.contains('éducation') || n.contains('école') || n.contains('académie')) return Icons.school_rounded;
        return Icons.business_rounded;
    }
  }
}
