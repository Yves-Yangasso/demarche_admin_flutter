// lib/core/app_localizations.dart
import 'package:flutter/material.dart';
import 'l10n/app_fr.dart';
import 'l10n/app_en.dart';
import 'l10n/app_wo.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': appFr,
    'en': appEn,
    'wo': appWo,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['fr']?[key] ??
        key;
  }

  // Convenience getters
  String get appName => get('app_name');
  String get loading => get('loading');
  String get error => get('error');
  String get retry => get('retry');
  String get cancel => get('cancel');
  String get confirm => get('confirm');
  String get save => get('save');
  String get next => get('next');
  String get previous => get('previous');
  String get submit => get('submit');
  String get close => get('close');
  String get yes => get('yes');
  String get no => get('no');
  String get ok => get('ok');
  String get search => get('search');
  String get filter => get('filter');
  String get all => get('all');

  String get login => get('login');
  String get register => get('register');
  String get logout => get('logout');
  String get phone => get('phone');
  String get email => get('email');
  String get password => get('password');
  String get otpCode => get('otp_code');
  String get sendOtp => get('send_otp');
  String get verify => get('verify');

  String get home => get('home');
  String get dossiers => get('dossiers');
  String get aiAssistant => get('ai_assistant');
  String get profile => get('profile');
  String get notifications => get('notifications');

  String get hello => get('hello');
  String get readyForAdmin => get('ready_for_admin');
  String get quickActions => get('quick_actions');
  String get newRequest => get('new_request');
  String get myDocuments => get('my_documents');
  String get scanQr => get('scan_qr');
  String get assistance => get('assistance');
  String get recentActivity => get('recent_activity');
  String get noDossier => get('no_dossier');
  String get startFirst => get('start_first');
  String get start => get('start');

  String get chooseOrganisation => get('choose_organisation');
  String get chooseCategory => get('choose_category');
  String get chooseDocType => get('choose_doc_type');
  String get selectOrg => get('select_org');
  String get requestForm => get('request_form');
  String get stepInfo => get('step_info');
  String get stepDocs => get('step_docs');
  String get stepRecap => get('step_recap');

  String get lastName => get('last_name');
  String get firstName => get('first_name');
  String get birthDate => get('birth_date');
  String get birthPlace => get('birth_place');
  String get address => get('address');
  String get fatherName => get('father_name');
  String get motherName => get('mother_name');
  String get nationality => get('nationality');
  String get idNumber => get('id_number');
  String get comment => get('comment');
  String get commentHint => get('comment_hint');
  String get uploadDocs => get('upload_docs');
  String get uploadHint => get('upload_hint');
  String get requiredDocs => get('required_docs');
  String get docCriteria => get('doc_criteria');
  String get acceptTerms => get('accept_terms');

  String get payment => get('payment');
  String get paymentAmount => get('payment_amount');
  String get paymentMethod => get('payment_method');
  String get waveMoney => get('wave_money');
  String get orangeMoney => get('orange_money');
  String get paymentConfirm => get('payment_confirm');
  String get paymentSuccess => get('payment_success');
  String get paymentPending => get('payment_pending');
  String get priceSetByAdmin => get('price_set_by_admin');

  String get myDossiers => get('my_dossiers');
  String get dossierDetail => get('dossier_detail');
  String get dossierHistory => get('dossier_history');
  String get dossierStatus => get('dossier_status');
  String get dossierRef => get('dossier_ref');
  String get dossierDate => get('dossier_date');
  String get dossierType => get('dossier_type');
  String get dossierRejected => get('dossier_rejected');
  String get dossierApproved => get('dossier_approved');
  String get dossierPending => get('dossier_pending');
  String get dossierProcessing => get('dossier_processing');
  String get correctAndResubmit => get('correct_and_resubmit');
  String get correctionInstructions => get('correction_instructions');
  String get trackProgress => get('track_progress');

  String get personalInfo => get('personal_info');
  String get accountSettings => get('account_settings');
  String get editProfile => get('edit_profile');
  String get changePhoto => get('change_photo');
  String get identityVerification => get('identity_verification');
  String get verifyIdentity => get('verify_identity');
  String get scanIdCard => get('scan_id_card');
  String get idVerified => get('id_verified');
  String get idNotVerified => get('id_not_verified');
  String get security => get('security');
  String get language => get('language');
  String get region => get('region');

  String get noNotifications => get('no_notifications');
  String get markAllRead => get('mark_all_read');
  String get docValidated => get('doc_validated');
  String get docRejected => get('doc_rejected');
  String get newMessage => get('new_message');

  String get askAi => get('ask_ai');
  String get aiGreeting => get('ai_greeting');

  String get networkError => get('network_error');
  String get serverError => get('server_error');
  String get fieldRequired => get('field_required');
  String get invalidPhone => get('invalid_phone');

  // Dynamically added
  String get howCanWeHelp => get('how_can_we_help');
  String get contactAgent => get('contact_agent');
  String get agentHours => get('agent_hours');
  String get callSupport => get('call_support');
  String get tollFree => get('toll_free');
  String get faq => get('faq');
  String get instantAnswers => get('instant_answers');
  String get activeRequests => get('active_requests');
  String get noSupportTicket => get('no_support_ticket');
  String get identityDocument => get('identity_document');
  String get addDocument => get('add_document');
  String get allMyDossiers => get('all_my_dossiers');
  String get searchDossiers => get('search_dossiers');
  String get categorySubtitle => get('category_subtitle');
  String get step1Of3 => get('step_1_of_3');
  String get searchOrganisation => get('search_organisation');
  String get step2Of3 => get('step_2_of_3');
  String get chooseDemarcheType => get('choose_demarche_type');
  String get searchDemarche => get('search_demarche');
  String get step3Of3 => get('step_3_of_3');
  String get back => get('back');
  String get continueBtn => get('continue_btn');
  String get imageSource => get('image_source');
  String get takePhoto => get('take_photo');
  String get fromGallery => get('from_gallery');
  String get scanFrontDoc => get('scan_front_doc');
  String get docType => get('doc_type');
  String get docFront => get('doc_front');
  String get docBackOptional => get('doc_back_optional');
  String get tapToScan => get('tap_to_scan');
  String get imgFormatSize => get('img_format_size');
  String get identityVerifiedExcl => get('identity_verified_excl');
  String get perfect => get('perfect');
  String get verificationFailed => get('verification_failed');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en', 'wo'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
