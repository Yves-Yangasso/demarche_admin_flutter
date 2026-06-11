import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Simplifiez vos démarches",
      description: "Plus besoin de vous déplacer. Gérez toutes vos demandes administratives depuis votre smartphone.",
      icon: Icons.speed_rounded,
      color: const Color(0xFF2563EB),
    ),
    OnboardingContent(
      title: "Suivi en temps réel",
      description: "Recevez des notifications à chaque étape de l'avancement de votre dossier.",
      icon: Icons.track_changes_rounded,
      color: const Color(0xFF10B981),
    ),
    OnboardingContent(
      title: "Assistant IA Intelligent",
      description: "Posez vos questions à notre IA pour savoir quels documents fournir et comment remplir vos formulaires.",
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF6366F1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: _contents[index].color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _contents[index].icon,
                            size: 100,
                            color: _contents[index].color,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _contents[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _contents[index].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      if (_currentPage < _contents.length - 1)
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                            child: const Text(
                              "Passer",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _contents.length - 1) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Text(_currentPage == _contents.length - 1 ? "Commencer" : "Suivant"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
