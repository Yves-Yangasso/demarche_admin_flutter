import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:terreadmin_mobile/presentation/views/form_new/screens/new_request_flow.dart';


import 'core/network/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/dossier_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/dossier_provider.dart';

import 'presentation/views/main_navigation.dart';

import 'presentation/views/auth/register_view.dart';
import 'presentation/views/demarche_infinite_list_view.dart';
import 'presentation/views/new_demarche/category_selection_view.dart';
import 'presentation/views/new_demarche/type_selection_view.dart';
import 'presentation/views/documents_view.dart';
import 'presentation/views/qr_scanner_view.dart';
import 'presentation/views/assistance_view.dart';
import 'presentation/views/splash_view.dart';
import 'presentation/views/onboarding_view.dart';

void main() {
  final apiClient = ApiClient();
  final authRepository = AuthRepositoryImpl(apiClient);
  final dossierRepository = DossierRepositoryImpl(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)..checkAuth()),
        ChangeNotifierProvider(create: (_) => DossierProvider(dossierRepository)),
      ],
      child: const TerreAdminApp(),
    ),
  );
}

class TerreAdminApp extends StatelessWidget {
  const TerreAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunu Dekk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        //'splash': (context) => const FormDemandeView(),
        '/onboarding': (context) => const OnboardingView(),
       '/login':(context) => const NewRequestFlow(),
        '/register': (context) => const RegisterView(),

        '/home': (context) => const MainNavigation(),
        '/demarches_toutes': (context) => const DemarcheInfiniteListView(),
        '/nouvelle_demande': (context) => const CategorySelectionView(),
       // "/form_demande" : (context) => const FormDemandeView(),
        '/demarche_types': (context) => const TypeSelectionView(),
        '/documents': (context) => const DocumentsView(),
        '/scan_qr': (context) => const QrScannerView(),
        '/assistance': (context) => const AssistanceView(),
      },
    );
  }
}
