import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/dossier_service.dart';
import 'widgets/dossier_card.dart';

class DemarcheInfiniteListView extends StatefulWidget {
  const DemarcheInfiniteListView({super.key});

  @override
  State<DemarcheInfiniteListView> createState() => _DemarcheInfiniteListViewState();
}

class _DemarcheInfiniteListViewState extends State<DemarcheInfiniteListView> {
  final DossierService _dossierService = DossierService();
  final List<Dossier> _dossiers = [];
  final ScrollController _scrollController = ScrollController();
  
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchMore();
      }
    });
  }

  Future<void> _fetchMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final newDossiers = await _dossierService.getMesDossiersPagines(_currentPage, 10);
    
    setState(() {
      _isLoading = false;
      if (newDossiers.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage++;
        _dossiers.addAll(newDossiers);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Toutes mes démarches", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: _dossiers.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _dossiers.length) {
            return DossierCard(dossier: _dossiers[index]);
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
            );
          }
        },
      ),
    );
  }
}
