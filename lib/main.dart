import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/app_localizations.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/dossier_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/dossier_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/notification_provider.dart';

import 'data/repositories/ia_repository_impl.dart';
import 'presentation/providers/ia_provider.dart';

import 'presentation/views/main_navigation.dart';
import 'presentation/views/auth/login_view.dart';
import 'presentation/views/auth/register_view.dart';

import 'presentation/views/new_demarche/organisations_view.dart';
import 'presentation/views/new_demarche/organisation_categories_view.dart';
import 'presentation/views/demarche_infinite_list_view.dart';
import 'presentation/views/new_demarche/type_selection_view.dart';
import 'presentation/views/new_demarche/request_stepper_view.dart';
import 'presentation/views/new_demarche/payment_view.dart';
import 'presentation/views/dossier/dossier_detail_view.dart';
import 'presentation/views/dossier/dossier_correction_view.dart';
import 'presentation/views/notifications/notifications_view.dart';
import 'presentation/views/profile/identity_verification_view.dart';
import 'presentation/views/documents_view.dart';
import 'presentation/views/qr_scanner_view.dart';
import 'presentation/views/assistance_view.dart';
import 'presentation/views/splash_view.dart';
import 'presentation/views/onboarding_view.dart';
import 'presentation/views/chatbot_view.dart';
import 'presentation/views/suivi_public_view.dart';
import 'models/models.dart';
import 'workflow/workflow.dart';
import 'workflow/status.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final apiClient = ApiClient();
  final authRepository = AuthRepositoryImpl(apiClient);
  final dossierRepository = DossierRepositoryImpl(apiClient);
  final iaRepository = IARepositoryImpl(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
            create: (_) => AuthProvider(authRepository)..checkAuth()),
        ChangeNotifierProvider(
            create: (_) => DossierProvider(dossierRepository)),
        ChangeNotifierProvider(create: (_) => IAProvider(iaRepository)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(apiClient)),
      ],
      child: const SunuDekkApp(),
    ),
  );
}

class SunuDekkApp extends StatelessWidget {
  const SunuDekkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      title: 'Sunu Dekk',
      debugShowCheckedModeBanner: false,

      // Internationalisation
      locale: languageProvider.locale,
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('wo')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
        FallbackWidgetsLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176848),
          primary: const Color(0xFF176848),
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          titleLarge:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          bodyLarge: const TextStyle(fontSize: 14),
          bodyMedium: const TextStyle(fontSize: 13),
          labelLarge:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF176848), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          labelStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF176848),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/onboarding': (context) => const OnboardingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const MainNavigation(),

        // Démarches - New flow
        '/organisations': (context) => const OrganisationsView(),
        '/organisation_categories': (context) =>
            const OrganisationCategoriesView(),
        '/nouvelle_demande': (context) => const OrganisationsView(),
        '/demarche_types': (context) => const TypeSelectionView(),
        '/request_stepper': (context) => const RequestStepperView(),

        // Legacy form (kept for compatibility)
        '/demarches_toutes': (context) => const DemarcheInfiniteListView(),

        // Documents, scan, assistance
        '/documents': (context) => const DocumentsView(),
        '/scan_qr': (context) => const QrScannerView(),
        '/assistance': (context) => const AssistanceView(),
        '/chatbot': (context) => const ChatBotView(),

        // Notifications
        '/notifications': (context) => const NotificationsView(),

        // Profile
        '/identity_verification': (context) => const IdentityVerificationView(),

        // Suivi public (sans authentification, conforme RGPD)
        '/suivi_public': (context) => const SuiviPublicView(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/suivi_dossier':
            final dossier = settings.arguments as DossierTracking;
            return MaterialPageRoute(
              builder: (_) => SuiviDossierScreen(dossier: dossier),
            );
          case '/dossier_detail':
            final dossier = settings.arguments as Dossier;
            return MaterialPageRoute(
              builder: (_) => DossierDetailView(dossier: dossier),
            );
          case '/dossier_correction':
            final dossier = settings.arguments as Dossier;
            return MaterialPageRoute(
              builder: (_) => DossierCorrectionView(dossier: dossier),
            );
          default:
            return null;
        }
      },
    );
  }
}

class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'wo';

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      GlobalMaterialLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'wo';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FallbackWidgetsLocalizationDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'wo';

  @override
  Future<WidgetsLocalizations> load(Locale locale) async =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(FallbackWidgetsLocalizationDelegate old) => false;
}
