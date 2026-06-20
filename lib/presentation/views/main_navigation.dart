// lib/presentation/views/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';
import 'dossier_list_view.dart';
import 'chatbot_view.dart';
import 'profile/profile_view_new.dart';
import 'notifications/notifications_view.dart';
import '../providers/notification_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const DossierListView(),
    const ChatBotView(),
    const NotificationsView(),
    const ProfileViewNew(),
  ];

  @override
  Widget build(BuildContext context) {
    // Safe area système : sur téléphones Android modernes la gesture-bar
    // mesure 16-48 px selon constructeur. Sans cette marge dynamique, la
    // bottom nav est collée (ou masquée) par la barre noire.
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    const navHeight = 68.0;
    const navMarginBottomBase = 16.0;
    // Hauteur totale occupée visuellement par la nav = à reporter sur les
    // pages enfant pour qu'elles ne soient pas masquées par le float-effect.
    final reservedBottom = navHeight + navMarginBottomBase + bottomSafe;

    return Scaffold(
      extendBody: true,
      body: MediaQuery.removePadding(
        // Les pages reçoivent leur padding bottom via `bottomPadding`
        // exposé en InheritedWidget - on évite le double padding.
        context: context,
        removeBottom: true,
        child: _BottomInset(
          inset: reservedBottom,
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.fromLTRB(16, 0, 16, navMarginBottomBase + bottomSafe),
        child: Container(
          height: navHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF176848),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF176848).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                  0, Icons.home_rounded, Icons.home_outlined, 'Accueil'),
              _buildNavItem(
                  1, Icons.folder_rounded, Icons.folder_outlined, 'Dossiers'),
              _buildNavItem(
                  2, Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'IA'),
              _buildNavItemWithBadge(3, Icons.notifications_rounded,
                  Icons.notifications_outlined, 'Alertes'),
              _buildNavItem(4, Icons.person_rounded,
                  Icons.person_outline_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
      int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? selectedIcon : unselectedIcon,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      size: 22,
                    ),
                    if (provider.unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              provider.unreadCount > 9
                                  ? '9+'
                                  : '${provider.unreadCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Injecte un padding bottom dans le MediaQuery des pages enfant pour qu'elles
/// laissent de la place à la bottom nav flottante (et ne soient pas masquées
/// par celle-ci). À utiliser à la racine d'un body avec `extendBody: true`.
class _BottomInset extends StatelessWidget {
  final double inset;
  final Widget child;
  const _BottomInset({required this.inset, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: inset),
        viewPadding: mq.viewPadding.copyWith(bottom: inset),
      ),
      child: child,
    );
  }
}
