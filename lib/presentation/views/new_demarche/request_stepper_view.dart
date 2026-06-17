// lib/presentation/views/new_demarche/request_stepper_view.dart
// Full stepper: Info → Documents → Recap → Payment
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dossier_provider.dart';
import 'payment_view.dart';

class RequestStepperView extends StatefulWidget {
  const RequestStepperView({super.key});

  @override
  State<RequestStepperView> createState() => _RequestStepperViewState();
}

class _RequestStepperViewState extends State<RequestStepperView> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;

  // Form keys
  final _infoFormKey = GlobalKey<FormState>();

  // Step 1 — Info controllers (pre-filled from user profile)
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _dateNaissCtrl = TextEditingController();
  final _lieuNaissCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _nationaliteCtrl = TextEditingController();
  final _numeroCniCtrl = TextEditingController();
  final _nomPereCtrl = TextEditingController();
  final _nomMereCtrl = TextEditingController();
  final _commentaireCtrl = TextEditingController();

  // Step 2 — Documents
  Map<String, File?> _uploadedFiles = {};
  List<Map<String, dynamic>> _requiredDocs = [];

  // Step 3 — Recap & terms
  bool _acceptedTerms = false;

  // Route args
  Map<String, dynamic>? _args;
  bool _argsPrefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsPrefilled) {
      _args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _prefillForm();
      _loadRequiredDocs();
      _argsPrefilled = true;
    }
  }

  void _prefillForm() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nomCtrl.text = user.nom;
      _prenomCtrl.text = user.prenom;
      _emailCtrl.text = user.email;
      _telephoneCtrl.text = user.telephone;
      _nationaliteCtrl.text = 'Sénégalaise';
    }
  }

  Future<void> _loadRequiredDocs() async {
    final typeId = _args?['type_id'];
    if (typeId == null) return;
    try {
      final docs = await context.read<DossierProvider>().getDocumentsCriteres(typeId);
      setState(() {
        _requiredDocs = List<Map<String, dynamic>>.from(docs);
        _uploadedFiles = {for (var d in docs) d['id'].toString(): null};
      });
    } catch (_) {
      // Fallback to empty list
      setState(() => _requiredDocs = []);
    }
  }

  void _goTo(int step) {
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    setState(() => _currentStep = step);
  }

  bool _canNext() {
    if (_currentStep == 0) return _infoFormKey.currentState?.validate() ?? false;
    if (_currentStep == 1) {
      return _requiredDocs.isEmpty ||
          _requiredDocs.every((d) {
            final key = d['id'].toString();
            return !d['obligatoire'] || _uploadedFiles[key] != null;
          });
    }
    if (_currentStep == 2) return _acceptedTerms;
    return true;
  }

  Future<void> _submitAndPay() async {
    if (!_acceptedTerms) return;

    final typeId = _args?['type_id'];
    final typeNom = _args?['type_nom'] ?? 'Démarche';
    final prix = (_args?['prix'] ?? 0).toDouble();

    final dossierData = {
      'type_demarche_id': typeId,
      'nom': _nomCtrl.text,
      'prenom': _prenomCtrl.text,
      'email': _emailCtrl.text,
      'telephone': _telephoneCtrl.text,
      'date_naissance': _dateNaissCtrl.text,
      'lieu_naissance': _lieuNaissCtrl.text,
      'adresse': _adresseCtrl.text,
      'nationalite': _nationaliteCtrl.text,
      'numero_cni': _numeroCniCtrl.text,
      'nom_pere': _nomPereCtrl.text,
      'nom_mere': _nomMereCtrl.text,
      'commentaire': _commentaireCtrl.text,
    };

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentView(
          dossierData: dossierData,
          typeNom: typeNom,
          prix: prix,
          uploadedFiles: _uploadedFiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeNom = _args?['type_nom'] ?? l10n.newRequest;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(typeNom,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(l10n),
          // Page view
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStep1Info(l10n),
                _buildStep2Docs(l10n),
                _buildStep3Recap(l10n),
              ],
            ),
          ),
          // Navigation buttons
          _buildNavButtons(l10n),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(AppLocalizations l10n) {
    final steps = [l10n.stepInfo, l10n.stepDocs, l10n.stepRecap];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDone || isActive
                              ? const Color(0xFF176848)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : isActive
                                      ? const Color(0xFF176848)
                                      : const Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isActive ? Colors.white : const Color(0xFF94A3B8),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              steps[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                                color: isActive
                                    ? const Color(0xFF176848)
                                    : isDone
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF94A3B8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Step 1: Information ───────────────────────────────────────────────────
  Widget _buildStep1Info(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _infoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Informations personnelles', Icons.person_rounded),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(l10n.lastName, _nomCtrl, required: true, icon: Icons.person_outline_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _field(l10n.firstName, _prenomCtrl, required: true, icon: Icons.person_outline_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            _field(l10n.email, _emailCtrl, keyboard: TextInputType.emailAddress, icon: Icons.email_outlined),
            const SizedBox(height: 12),
            _field(l10n.phone, _telephoneCtrl, keyboard: TextInputType.phone, required: true, icon: Icons.phone_outlined),
            const SizedBox(height: 20),
            _sectionTitle('Filiation', Icons.family_restroom_rounded),
            const SizedBox(height: 12),
            _field(l10n.fatherName, _nomPereCtrl, icon: Icons.male_rounded),
            const SizedBox(height: 12),
            _field(l10n.motherName, _nomMereCtrl, icon: Icons.female_rounded),
            const SizedBox(height: 20),
            _sectionTitle('Identité', Icons.badge_rounded),
            const SizedBox(height: 12),
            _field(l10n.birthDate, _dateNaissCtrl,
                hint: 'JJ/MM/AAAA', keyboard: TextInputType.datetime, icon: Icons.calendar_today_rounded),
            const SizedBox(height: 12),
            _field(l10n.birthPlace, _lieuNaissCtrl, icon: Icons.location_city_rounded),
            const SizedBox(height: 12),
            _field(l10n.nationality, _nationaliteCtrl, icon: Icons.flag_rounded),
            const SizedBox(height: 12),
            _field(l10n.idNumber, _numeroCniCtrl, icon: Icons.badge_outlined),
            const SizedBox(height: 12),
            _field(l10n.address, _adresseCtrl, maxLines: 2, icon: Icons.home_outlined),
            const SizedBox(height: 20),
            _sectionTitle(l10n.comment, Icons.comment_rounded),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentaireCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.commentHint,
                alignLabelWithHint: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: Documents ────────────────────────────────────────────────────
  Widget _buildStep2Docs(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l10n.requiredDocs, Icons.folder_copy_rounded),
          const SizedBox(height: 4),
          const Text(
            'Tous les documents marqués * sont obligatoires.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          if (_requiredDocs.isEmpty)
            _buildNoDocsRequired()
          else
            ..._requiredDocs.map((doc) => _buildDocUploadCard(doc)),
        ],
      ),
    );
  }

  Widget _buildNoDocsRequired() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aucun document spécifique requis pour ce type de démarche.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocUploadCard(Map<String, dynamic> doc) {
    final key = doc['id'].toString();
    final file = _uploadedFiles[key];
    final isRequired = doc['obligatoire'] == true;
    final isUploaded = file != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isUploaded
                ? const Color(0xFF10B981)
                : isRequired
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUploaded
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFF176848).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              color: isUploaded ? const Color(0xFF10B981) : const Color(0xFF176848),
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  doc['nom'] ?? doc['libelle'] ?? 'Document',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              if (isRequired)
                const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900)),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (doc['description'] != null) ...[
                const SizedBox(height: 4),
                Text(doc['description'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
              if (doc['criteres'] != null && doc['criteres'].isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('• ${doc['criteres']}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1), fontWeight: FontWeight.w500)),
              ],
              if (isUploaded) ...[
                const SizedBox(height: 4),
                Text(
                  file!.path.split('/').last,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: GestureDetector(
            onTap: () async {
              FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
              );
              if (result != null && result.files.single.path != null) {
                setState(() {
                  _uploadedFiles[key] = File(result.files.single.path!);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFF176848).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isUploaded ? 'Modifier' : 'Ajouter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isUploaded ? const Color(0xFF10B981) : const Color(0xFF176848),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Step 3: Recap ────────────────────────────────────────────────────────
  Widget _buildStep3Recap(AppLocalizations l10n) {
    final typeNom = _args?['type_nom'] ?? '';
    final prix = (_args?['prix'] ?? 0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Résumé de la demande', Icons.summarize_rounded),
          const SizedBox(height: 12),
          // Type card
          _recapCard([
            _recapRow('Type de démarche', typeNom),
            _recapRow('Organisation', _args?['organisation_nom'] ?? ''),
            _recapRow('Catégorie', _args?['categorie_nom'] ?? ''),
          ], const Color(0xFF176848)),
          const SizedBox(height: 12),
          _sectionTitle('Informations personnelles', Icons.person_rounded),
          const SizedBox(height: 12),
          _recapCard([
            _recapRow(l10n.lastName, _nomCtrl.text),
            _recapRow(l10n.firstName, _prenomCtrl.text),
            _recapRow(l10n.email, _emailCtrl.text),
            _recapRow(l10n.phone, _telephoneCtrl.text),
            _recapRow(l10n.birthDate, _dateNaissCtrl.text),
            _recapRow(l10n.birthPlace, _lieuNaissCtrl.text),
            _recapRow(l10n.idNumber, _numeroCniCtrl.text),
          ], const Color(0xFF0F172A)),
          const SizedBox(height: 12),
          _sectionTitle('Filiation', Icons.family_restroom_rounded),
          const SizedBox(height: 12),
          _recapCard([
            _recapRow(l10n.fatherName, _nomPereCtrl.text),
            _recapRow(l10n.motherName, _nomMereCtrl.text),
          ], const Color(0xFF0F172A)),
          if (_commentaireCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            _sectionTitle(l10n.comment, Icons.comment_rounded),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(_commentaireCtrl.text,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
            ),
          ],
          const SizedBox(height: 12),
          _sectionTitle('Documents fournis', Icons.folder_copy_rounded),
          const SizedBox(height: 12),
          _recapCard(
            _requiredDocs.isEmpty
                ? [_recapRow('', 'Aucun document requis')]
                : _requiredDocs.map((d) {
                    final key = d['id'].toString();
                    final uploaded = _uploadedFiles[key] != null;
                    return _recapRow(
                      d['nom'] ?? '',
                      uploaded ? '✅ Fourni' : '❌ Non fourni',
                      valueColor: uploaded ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    );
                  }).toList(),
            const Color(0xFF0F172A),
          ),
          // Tarif
          if (prix > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF176848), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Montant à payer',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${prix.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Icon(Icons.payment_rounded, color: Colors.white70, size: 32),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Accept terms
          GestureDetector(
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _acceptedTerms ? const Color(0xFF176848) : Colors.white,
                    border: Border.all(
                      color: _acceptedTerms ? const Color(0xFF176848) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _acceptedTerms
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.acceptTerms,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recapCard(List<Widget> rows, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: accentColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          return Column(
            children: [
              e.value,
              if (e.key < rows.length - 1)
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _recapRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation buttons ───────────────────────────────────────────────────
  Widget _buildNavButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goTo(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  backgroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.previous,
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 0) {
                  if (_infoFormKey.currentState!.validate()) _goTo(1);
                } else if (_currentStep == 1) {
                  if (!_canNext()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez fournir tous les documents obligatoires marqués par une étoile (*).'),
                        backgroundColor: Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  _goTo(2);
                } else {
                  if (!_acceptedTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vous devez accepter les conditions pour continuer.'),
                        backgroundColor: Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  _submitAndPay();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176848),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFF176848).withValues(alpha: 0.4),
              ),
              child: Text(
                _currentStep < 2 ? l10n.next : 'Payer & Soumettre',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF176848).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF176848)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    TextInputType keyboard = TextInputType.text,
    bool required = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 14),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF94A3B8), size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Requis' : null : null,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telephoneCtrl.dispose();
    _dateNaissCtrl.dispose();
    _lieuNaissCtrl.dispose();
    _adresseCtrl.dispose();
    _nationaliteCtrl.dispose();
    _numeroCniCtrl.dispose();
    _nomPereCtrl.dispose();
    _nomMereCtrl.dispose();
    _commentaireCtrl.dispose();
    super.dispose();
  }
}
