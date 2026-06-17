import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.speed_rounded,
      color: AppTheme.primary,
      title: 'Simplifiez vos démarches',
      description:
          'Plus besoin de vous déplacer. Gérez toutes vos demandes administratives depuis votre smartphone, où que vous soyez.',
    ),
    _OnboardingPage(
      icon: Icons.track_changes_rounded,
      color: AppTheme.success,
      title: 'Suivi en temps réel',
      description:
          'Recevez des notifications à chaque étape de l\'avancement de votre dossier et restez toujours informé.',
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      color: AppTheme.info,
      title: 'Assistant IA Intelligent',
      description:
          'Posez vos questions à notre IA pour savoir quels documents fournir et comment remplir vos formulaires.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Bouton Passer ──────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text(
                    'Passer',
                    style: TextStyle(
                      color: AppTheme.textMuted, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // ── Pages ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) =>
                    _buildPage(_pages[index]),
              ),
            ),

            // ── Bas de page ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                children: [
                  // Dots indicateurs
                  _buildDots(),
                  const SizedBox(height: 32),
                  // Bouton Suivant / Commencer
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Page individuelle ────────────────────────────────────────────────────

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône dans une carte
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 56, color: page.color),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Titre
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w900,
              color: AppTheme.textDark, height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15, color: AppTheme.textMedium,
              height: 1.6, fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dots indicateurs ─────────────────────────────────────────────────────

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 28 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme.primary
                : AppTheme.textLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color    color;
  final String   title;
  final String   description;

  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
