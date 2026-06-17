// lib/presentation/views/profile/identity_verification_view.dart
// Identity verification via ID card or passport scan
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/app_localizations.dart';

enum IDDocumentType { cni, passport }
enum VerificationState { idle, scanning, processing, success, failure }

class IdentityVerificationView extends StatefulWidget {
  const IdentityVerificationView({super.key});

  @override
  State<IdentityVerificationView> createState() => _IdentityVerificationViewState();
}

class _IdentityVerificationViewState extends State<IdentityVerificationView>
    with TickerProviderStateMixin {
  IDDocumentType _docType = IDDocumentType.cni;
  VerificationState _state = VerificationState.idle;
  File? _frontImage;
  File? _backImage;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.9, end: 1.1).animate(_pulseCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final source = await _showSourcePicker();
    if (source == null) return;

    final image = await picker.pickImage(source: source, imageQuality: 90);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  Future<ImageSource?> _showSourcePicker() {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.imageSource,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF176848)),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF6366F1)),
              title: Text(l10n.fromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    if (_frontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanFrontDoc)),
      );
      return;
    }

    setState(() => _state = VerificationState.scanning);
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _state = VerificationState.processing);
    await Future.delayed(const Duration(seconds: 2));

    // Simulate algorithm result (80% success)
    final isSuccess = DateTime.now().millisecond % 5 != 0;
    setState(() => _state = isSuccess ? VerificationState.success : VerificationState.failure);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_state == VerificationState.success) return _buildSuccessScreen();
    if (_state == VerificationState.failure) return _buildFailureScreen();
    if (_state == VerificationState.scanning || _state == VerificationState.processing) {
      return _buildProcessingScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(l10n.identityVerification,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, color: Color(0xFF176848), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Votre identité sera vérifiée par notre algorithme IA. Assurez-vous que le document est bien éclairé et lisible.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Document type selector
            Text(l10n.docType,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _typeSelector(
                    IDDocumentType.cni,
                    'Carte d\'Identité',
                    Icons.badge_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeSelector(
                    IDDocumentType.passport,
                    'Passeport',
                    Icons.menu_book_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Front scan
            Text(l10n.docFront,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            _buildScanBox(isFront: true),
            const SizedBox(height: 16),

            // Back scan (optional for passport)
            if (_docType == IDDocumentType.cni) ...[
              Text(l10n.docBackOptional,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              _buildScanBox(isFront: false),
              const SizedBox(height: 24),
            ],

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _verify,
                icon: const Icon(Icons.verified_user_rounded),
                label: Text(l10n.verifyIdentity,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector(IDDocumentType type, String label, IconData icon) {
    final isSelected = _docType == type;
    return GestureDetector(
      onTap: () => setState(() => _docType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF176848).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF176848) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF176848) : const Color(0xFF94A3B8),
                size: 30),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF176848)
                        : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildScanBox({required bool isFront}) {
    final image = isFront ? _frontImage : _backImage;
    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: image != null ? Colors.transparent : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null
                ? const Color(0xFF10B981)
                : const Color(0xFFCBD5E1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(image, fit: BoxFit.cover, width: double.infinity),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner_rounded,
                      size: 40, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context).tapToScan,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context).imgFormatSize,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
      ),
    );
  }

  Widget _buildProcessingScreen() {
    final l10n = AppLocalizations.of(context);
    final message = _state == VerificationState.scanning
        ? l10n.loading
        : l10n.identityVerification;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF176848).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.document_scanner_rounded,
                    size: 56, color: Color(0xFF176848)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.scanIdCard,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(strokeWidth: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded,
                    size: 64, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 32),
              Text(l10n.identityVerifiedExcl,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Text(
                l10n.idVerified,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.perfect,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFailureScreen() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_rounded,
                    size: 64, color: Color(0xFFEF4444)),
              ),
              const SizedBox(height: 32),
              Text(l10n.verificationFailed,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Text(
                l10n.idNotVerified,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => setState(() {
                  _state = VerificationState.idle;
                  _frontImage = null;
                  _backImage = null;
                }),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.retry,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Text(l10n.cancel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
