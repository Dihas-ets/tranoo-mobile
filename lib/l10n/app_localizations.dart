import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('ar')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get validate;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @service_sales_cars.
  ///
  /// In en, this message translates to:
  /// **'Sales (Cars)'**
  String get service_sales_cars;

  /// No description provided for @service_delivery_parts.
  ///
  /// In en, this message translates to:
  /// **'Delivery (Parts)'**
  String get service_delivery_parts;

  /// No description provided for @service_tricycle.
  ///
  /// In en, this message translates to:
  /// **'Tricycle'**
  String get service_tricycle;

  /// No description provided for @tricycle_location_required.
  ///
  /// In en, this message translates to:
  /// **'Please enable location to use the Tricycle service.'**
  String get tricycle_location_required;

  /// No description provided for @tricycle_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get tricycle_permission_denied;

  /// No description provided for @tricycle_permission_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'Location permission blocked. Enable it in settings.'**
  String get tricycle_permission_denied_forever;

  /// No description provided for @tricycle_position_active_title.
  ///
  /// In en, this message translates to:
  /// **'Location active'**
  String get tricycle_position_active_title;

  /// No description provided for @tricycle_position_active_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Location is running… Nearby tricycles will refresh automatically.'**
  String get tricycle_position_active_subtitle;

  /// No description provided for @tricycle_none_nearby.
  ///
  /// In en, this message translates to:
  /// **'No nearby tricycles at the moment.'**
  String get tricycle_none_nearby;

  /// No description provided for @tricycle_out_of_range.
  ///
  /// In en, this message translates to:
  /// **'Out of range'**
  String get tricycle_out_of_range;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @enable_location.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enable_location;

  /// No description provided for @open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get open_settings;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @callShort.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callShort;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @tricycle_auth_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get tricycle_auth_required;

  /// No description provided for @tricycle_connect_to_see.
  ///
  /// In en, this message translates to:
  /// **'Connect to see'**
  String get tricycle_connect_to_see;

  /// No description provided for @tricycle_connect_description.
  ///
  /// In en, this message translates to:
  /// **'Please connect your account to view this content'**
  String get tricycle_connect_description;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get agree;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccount;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose a currency'**
  String get chooseCurrency;

  /// No description provided for @currencyXof.
  ///
  /// In en, this message translates to:
  /// **'XOF'**
  String get currencyXof;

  /// No description provided for @currencyEuro.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEuro;

  /// No description provided for @currencyDollars.
  ///
  /// In en, this message translates to:
  /// **'Dollars'**
  String get currencyDollars;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get pieces;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fillAllFields;

  /// No description provided for @networkOrServerError.
  ///
  /// In en, this message translates to:
  /// **'Network or server error.'**
  String get networkOrServerError;

  /// No description provided for @invalidSessionReconnect.
  ///
  /// In en, this message translates to:
  /// **'Invalid session. Please sign in again.'**
  String get invalidSessionReconnect;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @noUserData.
  ///
  /// In en, this message translates to:
  /// **'No user data'**
  String get noUserData;

  /// No description provided for @pleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get pleaseSignIn;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get addImages;

  /// No description provided for @filterByBudget.
  ///
  /// In en, this message translates to:
  /// **'Filter by budget'**
  String get filterByBudget;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min.'**
  String get minLabel;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max.'**
  String get maxLabel;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @deletionError.
  ///
  /// In en, this message translates to:
  /// **'Error during deletion.'**
  String get deletionError;

  /// No description provided for @sendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send alert'**
  String get sendAlert;

  /// No description provided for @alertSent.
  ///
  /// In en, this message translates to:
  /// **'Alert sent'**
  String get alertSent;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @errorOpening.
  ///
  /// In en, this message translates to:
  /// **'Error opening: {error}'**
  String errorOpening(String error);

  /// No description provided for @errorDeletion.
  ///
  /// In en, this message translates to:
  /// **'Deletion error: {error}'**
  String errorDeletion(String error);

  /// No description provided for @errorPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment error: {error}'**
  String errorPayment(String error);

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error: {error}'**
  String errorNetwork(String error);

  /// No description provided for @vehiclesAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} vehicle(s) available'**
  String vehiclesAvailableCount(int count);

  /// No description provided for @partsAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} part(s) available'**
  String partsAvailableCount(int count);

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @welcomeTranoo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tranoo'**
  String get welcomeTranoo;

  /// No description provided for @welcomeTranooPro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tranoo Pro'**
  String get welcomeTranooPro;

  /// No description provided for @phoneTab.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneTab;

  /// No description provided for @legacyEmailTab.
  ///
  /// In en, this message translates to:
  /// **'Email (legacy account)'**
  String get legacyEmailTab;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'example@mail.com'**
  String get emailExample;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @invalidEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmailTitle;

  /// No description provided for @legacyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select « Email » and enter your old address.'**
  String get legacyEmailSubtitle;

  /// No description provided for @invalidPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidPhoneTitle;

  /// No description provided for @invalidPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter {hint} for {country}.'**
  String invalidPhoneSubtitle(String hint, String country);

  /// No description provided for @loginSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Login successful. Welcome!'**
  String get loginSuccessTitle;

  /// No description provided for @cannotLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in with these credentials.'**
  String get cannotLoginTitle;

  /// No description provided for @noBuyerAccount.
  ///
  /// In en, this message translates to:
  /// **'No buyer account linked to this number.'**
  String get noBuyerAccount;

  /// No description provided for @checkCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Create an account or verify the country code.'**
  String get checkCountryCode;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get wrongPassword;

  /// No description provided for @verifyAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Check your information and try again.'**
  String get verifyAndRetry;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect number, email or password.'**
  String get wrongCredentials;

  /// No description provided for @accountBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your account is temporarily blocked.'**
  String get accountBlocked;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support.'**
  String get contactSupport;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many login attempts.'**
  String get tooManyAttempts;

  /// No description provided for @retryInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Try again in a few minutes.'**
  String get retryInMinutes;

  /// No description provided for @cannotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server.'**
  String get cannotReachServer;

  /// No description provided for @checkInternet.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection.'**
  String get checkInternet;

  /// No description provided for @serviceTemporaryIssue.
  ///
  /// In en, this message translates to:
  /// **'Our service is experiencing a temporary issue.'**
  String get serviceTemporaryIssue;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get tryAgainLater;

  /// No description provided for @sessionInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Session could not be initialized. Try again.'**
  String get sessionInitFailed;

  /// No description provided for @searchCountryOrCode.
  ///
  /// In en, this message translates to:
  /// **'Search a country or code'**
  String get searchCountryOrCode;

  /// No description provided for @buyerBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'This app is for buyers only'**
  String get buyerBlockedTitle;

  /// No description provided for @buyerBlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Tranoo Pro for seller, driver or delivery accounts.'**
  String get buyerBlockedSubtitle;

  /// No description provided for @noSellerAccount.
  ///
  /// In en, this message translates to:
  /// **'No seller account linked to this number.'**
  String get noSellerAccount;

  /// No description provided for @useTranooForBuyer.
  ///
  /// In en, this message translates to:
  /// **'Use the Tranoo app for buyer accounts.'**
  String get useTranooForBuyer;

  /// No description provided for @findDreamCar.
  ///
  /// In en, this message translates to:
  /// **'Find your dream car!'**
  String get findDreamCar;

  /// No description provided for @referralCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Referral code (optional)'**
  String get referralCodeOptional;

  /// No description provided for @referralPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ex: TRN-ABCD1234'**
  String get referralPlaceholder;

  /// No description provided for @searchCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Search a country code (country or +code)'**
  String get searchCountryCode;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get whatsappNumber;

  /// No description provided for @whatsappHint.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp · {hint}'**
  String whatsappHint(String hint);

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'Retype password'**
  String get retypePassword;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get passwordMin8;

  /// No description provided for @missingFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Some fields are missing.'**
  String get missingFieldsTitle;

  /// No description provided for @completeRequiredInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete the required information.'**
  String get completeRequiredInfo;

  /// No description provided for @passwordMin8Title.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMin8Title;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account was created successfully.'**
  String get accountCreatedTitle;

  /// No description provided for @welcomeTranooExclaim.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tranoo!'**
  String get welcomeTranooExclaim;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @passwordVeryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very strong'**
  String get passwordVeryStrong;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStep;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search a country'**
  String get searchCountry;

  /// No description provided for @incompleteServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Incomplete server response.'**
  String get incompleteServerResponse;

  /// No description provided for @retryShortly.
  ///
  /// In en, this message translates to:
  /// **'Try again in a few moments.'**
  String get retryShortly;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent'**
  String get codeSent;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @verifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCodeTitle;

  /// No description provided for @missingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing information.'**
  String get missingInfoTitle;

  /// No description provided for @restartFromForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Please start over from the forgot-password page.'**
  String get restartFromForgotPassword;

  /// No description provided for @errorOccurredTitle.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorOccurredTitle;

  /// No description provided for @checkConnectionAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get checkConnectionAndRetry;

  /// No description provided for @passwordTooShortTitle.
  ///
  /// In en, this message translates to:
  /// **'Password too short.'**
  String get passwordTooShortTitle;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum {count} characters.'**
  String passwordMinLength(int count);

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @whatsappNumberWarning.
  ///
  /// In en, this message translates to:
  /// **'Use a WhatsApp-reachable number: it will be used for OTP and communication between our team and users.'**
  String get whatsappNumberWarning;

  /// No description provided for @phoneDigitsExact.
  ///
  /// In en, this message translates to:
  /// **'{count} digits'**
  String phoneDigitsExact(int count);

  /// No description provided for @phoneDigitsRange.
  ///
  /// In en, this message translates to:
  /// **'{min} to {max} digits'**
  String phoneDigitsRange(int min, int max);

  /// No description provided for @passwordStrengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Password strength: {label}'**
  String passwordStrengthLabel(String label);

  /// No description provided for @stepInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get stepInfo;

  /// No description provided for @placeholderFirstName.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get placeholderFirstName;

  /// No description provided for @placeholderLastName.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get placeholderLastName;

  /// No description provided for @accountAlreadyExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this number.'**
  String get accountAlreadyExistsTitle;

  /// No description provided for @accountAlreadyExistsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or use another number.'**
  String get accountAlreadyExistsSubtitle;

  /// No description provided for @referralCodeRegistered.
  ///
  /// In en, this message translates to:
  /// **'Referral code saved (status: {status})'**
  String referralCodeRegistered(String status);

  /// No description provided for @accountCreatedAgentReferral.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Agent referral validated.'**
  String get accountCreatedAgentReferral;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Choose your country, then enter the national number\n(without repeating the +229 code).\nThe code is sent to the WhatsApp registered on the account.'**
  String get forgotPasswordInstructions;

  /// No description provided for @enterYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your number'**
  String get enterYourPhone;

  /// No description provided for @invalidPhoneWithHint.
  ///
  /// In en, this message translates to:
  /// **'Invalid number ({hint})'**
  String invalidPhoneWithHint(String hint);

  /// No description provided for @forgotPasswordBeninHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. for +229: enter 593XXXXXXX (8 digits), not 01593XXXXXXX or +229 prefix.'**
  String get forgotPasswordBeninHint;

  /// No description provided for @forgotPasswordNationalHint.
  ///
  /// In en, this message translates to:
  /// **'Enter only the national number; country code {code} is already selected.'**
  String forgotPasswordNationalHint(String code);

  /// No description provided for @accountNotFoundForNumber.
  ///
  /// In en, this message translates to:
  /// **'No account found for this number.'**
  String get accountNotFoundForNumber;

  /// No description provided for @useSameWhatsappAsSignup.
  ///
  /// In en, this message translates to:
  /// **'Use the same WhatsApp number as at sign-up (without 0 after +229).'**
  String get useSameWhatsappAsSignup;

  /// No description provided for @errorTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing or invalid token.'**
  String get errorTokenMissing;

  /// No description provided for @errorTokenInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid token.'**
  String get errorTokenInvalid;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found. Please sign in again.'**
  String get errorUserNotFound;

  /// No description provided for @errorAccountBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your account has been blocked. Contact support.'**
  String get errorAccountBlocked;

  /// No description provided for @errorSessionRequired.
  ///
  /// In en, this message translates to:
  /// **'Web session required. Please sign in again.'**
  String get errorSessionRequired;

  /// No description provided for @errorSessionRevoked.
  ///
  /// In en, this message translates to:
  /// **'Your session was opened elsewhere. Sign in again.'**
  String get errorSessionRevoked;

  /// No description provided for @errorSessionInactive.
  ///
  /// In en, this message translates to:
  /// **'Session expired due to inactivity. Please sign in again.'**
  String get errorSessionInactive;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid number. Check country code and number.'**
  String get errorInvalidPhone;

  /// No description provided for @errorAppRequired.
  ///
  /// In en, this message translates to:
  /// **'App required (tranoo or tranoo_pro).'**
  String get errorAppRequired;

  /// No description provided for @errorAccountAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Multiple accounts share this number. Contact support.'**
  String get errorAccountAmbiguous;

  /// No description provided for @errorAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for this number.'**
  String get errorAccountNotFound;

  /// No description provided for @errorOtpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to send code. Check the number or try again.'**
  String get errorOtpSendFailed;

  /// No description provided for @errorMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Required fields missing.'**
  String get errorMissingFields;

  /// No description provided for @errorOtpInvalidOrExpired.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code.'**
  String get errorOtpInvalidOrExpired;

  /// No description provided for @errorDeviceMismatch.
  ///
  /// In en, this message translates to:
  /// **'This phone does not match the request.'**
  String get errorDeviceMismatch;

  /// No description provided for @errorRequestInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid request.'**
  String get errorRequestInvalid;

  /// No description provided for @errorOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Request a new code.'**
  String get errorOtpExpired;

  /// No description provided for @errorOtpLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Request a new code.'**
  String get errorOtpLocked;

  /// No description provided for @errorOtpIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code.'**
  String get errorOtpIncorrect;

  /// No description provided for @errorVerifyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify the code first.'**
  String get errorVerifyFirst;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short.'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update password. Contact support.'**
  String get errorPasswordUpdateFailed;

  /// No description provided for @errorInternalError.
  ///
  /// In en, this message translates to:
  /// **'Error. Please try again.'**
  String get errorInternalError;

  /// No description provided for @errorValidationError.
  ///
  /// In en, this message translates to:
  /// **'Invalid data.'**
  String get errorValidationError;

  /// No description provided for @errorNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated.'**
  String get errorNotAuthenticated;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Access denied.'**
  String get errorForbidden;

  /// No description provided for @errorAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied.'**
  String get errorAccessDenied;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get errorNotFound;

  /// No description provided for @errorNoUpdateData.
  ///
  /// In en, this message translates to:
  /// **'No data to update.'**
  String get errorNoUpdateData;

  /// No description provided for @errorDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Description too long (500 characters max).'**
  String get errorDescriptionTooLong;

  /// No description provided for @errorGalleryTransitaireOnly.
  ///
  /// In en, this message translates to:
  /// **'Gallery is for forwarders only.'**
  String get errorGalleryTransitaireOnly;

  /// No description provided for @errorGalleryMustBeArray.
  ///
  /// In en, this message translates to:
  /// **'Gallery must be a list.'**
  String get errorGalleryMustBeArray;

  /// No description provided for @errorGalleryMaxItems.
  ///
  /// In en, this message translates to:
  /// **'Maximum 20 items in the gallery.'**
  String get errorGalleryMaxItems;

  /// No description provided for @errorGalleryInvalidItem.
  ///
  /// In en, this message translates to:
  /// **'Invalid gallery item.'**
  String get errorGalleryInvalidItem;

  /// No description provided for @errorGalleryItemTypeUrl.
  ///
  /// In en, this message translates to:
  /// **'Each item must have a type (image or video) and a URL.'**
  String get errorGalleryItemTypeUrl;

  /// No description provided for @errorVendeurTypeSellersOnly.
  ///
  /// In en, this message translates to:
  /// **'This setting is for sellers only.'**
  String get errorVendeurTypeSellersOnly;

  /// No description provided for @errorVendeurTypeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid seller type.'**
  String get errorVendeurTypeInvalid;

  /// No description provided for @errorPhoneAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This number is already used for this app.'**
  String get errorPhoneAlreadyUsed;

  /// No description provided for @errorPhoneAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'This number is linked to multiple accounts. Contact support.'**
  String get errorPhoneAmbiguous;

  /// No description provided for @errorUserIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete user information.'**
  String get errorUserIncomplete;

  /// No description provided for @errorProfileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get errorProfileUpdateFailed;

  /// No description provided for @errorFirebaseEmailSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Email updated locally but not on the account.'**
  String get errorFirebaseEmailSyncFailed;

  /// No description provided for @errorFcmTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification token required.'**
  String get errorFcmTokenRequired;

  /// No description provided for @errorArticleIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Article ID required.'**
  String get errorArticleIdRequired;

  /// No description provided for @errorFileRequired.
  ///
  /// In en, this message translates to:
  /// **'No file uploaded.'**
  String get errorFileRequired;

  /// No description provided for @errorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get errorConnectionFailed;

  /// No description provided for @errorEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your number.'**
  String get errorEnterPhoneNumber;

  /// No description provided for @codeSentWhatsappDefault.
  ///
  /// In en, this message translates to:
  /// **'Code sent via WhatsApp to your account number.'**
  String get codeSentWhatsappDefault;

  /// No description provided for @enterCodePlease.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get enterCodePlease;

  /// No description provided for @otpMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'The code must be 6 digits'**
  String get otpMustBe6Digits;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code.'**
  String get invalidCode;

  /// No description provided for @verifyCodeBanner.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.\nValid for {minutes} min. Check the Tranoo notification or WhatsApp on the account number.'**
  String verifyCodeBanner(int minutes);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @connectSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get connectSupport;

  /// No description provided for @cannotOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Unable to open WhatsApp.'**
  String get cannotOpenWhatsApp;

  /// No description provided for @installWhatsAppRetry.
  ///
  /// In en, this message translates to:
  /// **'Install WhatsApp and try again.'**
  String get installWhatsAppRetry;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @geolocation.
  ///
  /// In en, this message translates to:
  /// **'Geolocation'**
  String get geolocation;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get pushNotificationsSubtitle;

  /// No description provided for @locationTracking.
  ///
  /// In en, this message translates to:
  /// **'Location tracking'**
  String get locationTracking;

  /// No description provided for @shareRealtimeLocation.
  ///
  /// In en, this message translates to:
  /// **'Share your real-time location'**
  String get shareRealtimeLocation;

  /// No description provided for @cfaFranc.
  ///
  /// In en, this message translates to:
  /// **'CFA Franc'**
  String get cfaFranc;

  /// No description provided for @usDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// No description provided for @createAccountToContinue.
  ///
  /// In en, this message translates to:
  /// **'Create an account to continue.'**
  String get createAccountToContinue;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get actionRequired;

  /// No description provided for @uploadProfilePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload your profile photo to continue.'**
  String get uploadProfilePhotoRequired;

  /// No description provided for @proBuyerBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer account not allowed on Tranoo Pro'**
  String get proBuyerBlockedTitle;

  /// No description provided for @proBuyerBlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buyers use the Tranoo app.'**
  String get proBuyerBlockedSubtitle;

  /// No description provided for @thisCountry.
  ///
  /// In en, this message translates to:
  /// **'this country'**
  String get thisCountry;

  /// No description provided for @passwordDotsHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordDotsHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location required'**
  String get locationRequired;

  /// No description provided for @authorizationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authorization required'**
  String get authorizationRequired;

  /// No description provided for @whatWeUse.
  ///
  /// In en, this message translates to:
  /// **'What we use:'**
  String get whatWeUse;

  /// No description provided for @locationBackgroundWarning.
  ///
  /// In en, this message translates to:
  /// **'Location is used even when the app is in the background for continuous tracking.'**
  String get locationBackgroundWarning;

  /// No description provided for @backgroundLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Background location'**
  String get backgroundLocationTitle;

  /// No description provided for @backgroundLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'To ensure continuous tracking of your missions, we need access to your location even when the app is in the background.\n\nYou can enable this permission in your device settings.'**
  String get backgroundLocationMessage;

  /// No description provided for @deviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get deviceSettings;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @locationRequiredForRole.
  ///
  /// In en, this message translates to:
  /// **'Location is required to use {role} features. Some features may be limited.'**
  String locationRequiredForRole(String role);

  /// No description provided for @permissionRequestError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while requesting permission: {error}'**
  String permissionRequestError(String error);

  /// No description provided for @welcomeTranooProExclaim.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tranoo Pro!'**
  String get welcomeTranooProExclaim;

  /// No description provided for @locationAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Location authorization'**
  String get locationAuthorization;

  /// No description provided for @locationUsageIntro.
  ///
  /// In en, this message translates to:
  /// **'For proper operation, Tranoo Pro uses your location to:'**
  String get locationUsageIntro;

  /// No description provided for @locationBackgroundServicesWarning.
  ///
  /// In en, this message translates to:
  /// **'Location may be used even when the app is in the background to ensure continuous service tracking.'**
  String get locationBackgroundServicesWarning;

  /// No description provided for @changeDecisionLaterInSettings.
  ///
  /// In en, this message translates to:
  /// **'You can change this decision later in settings'**
  String get changeDecisionLaterInSettings;

  /// No description provided for @authorizeLocationInSettings.
  ///
  /// In en, this message translates to:
  /// **'Allow location in settings.'**
  String get authorizeLocationInSettings;

  /// No description provided for @cannotGetPosition.
  ///
  /// In en, this message translates to:
  /// **'Unable to get position.'**
  String get cannotGetPosition;

  /// No description provided for @yourCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Your current position'**
  String get yourCurrentPosition;

  /// No description provided for @positionUsageForListings.
  ///
  /// In en, this message translates to:
  /// **'Used for your listings and supplier location. You can update it in your profile.'**
  String get positionUsageForListings;

  /// No description provided for @saveCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Save my current position'**
  String get saveCurrentPosition;

  /// No description provided for @refreshPosition.
  ///
  /// In en, this message translates to:
  /// **'Refresh position'**
  String get refreshPosition;

  /// No description provided for @positionSavedGps.
  ///
  /// In en, this message translates to:
  /// **'Position saved (GPS coordinates)'**
  String get positionSavedGps;

  /// No description provided for @profilePositionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile position updated'**
  String get profilePositionUpdated;

  /// No description provided for @savePositionToContinue.
  ///
  /// In en, this message translates to:
  /// **'Save your current position to continue.'**
  String get savePositionToContinue;

  /// No description provided for @saveYourCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Save your current position.'**
  String get saveYourCurrentPosition;

  /// No description provided for @sellerUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller update'**
  String get sellerUpdateTitle;

  /// No description provided for @sellerTypeChoiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Tranoo Pro now lets you choose your seller type: vehicles, spare parts or mixed.'**
  String get sellerTypeChoiceIntro;

  /// No description provided for @sellerTypeChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Make your choice on the dedicated page to adapt your menus and listings.'**
  String get sellerTypeChoiceHint;

  /// No description provided for @makeChoice.
  ///
  /// In en, this message translates to:
  /// **'Make a choice'**
  String get makeChoice;

  /// No description provided for @professionalAccess.
  ///
  /// In en, this message translates to:
  /// **'Professional access'**
  String get professionalAccess;

  /// No description provided for @useAlternativeAppForProfessionalRole.
  ///
  /// In en, this message translates to:
  /// **'Use {app} instead for your professional role'**
  String useAlternativeAppForProfessionalRole(String app);

  /// No description provided for @subscriptionExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Your subscription expires in {days} day(s).'**
  String subscriptionExpiresIn(int days);

  /// No description provided for @freeTrialEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Your free trial ends in {days} day(s).'**
  String freeTrialEndsIn(int days);

  /// No description provided for @currentPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Current plan: {plan}'**
  String currentPlanLabel(String plan);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage my subscription'**
  String get manageSubscription;

  /// No description provided for @historyLast10.
  ///
  /// In en, this message translates to:
  /// **'History (last 10)'**
  String get historyLast10;

  /// No description provided for @noSubscriptionPayments.
  ///
  /// In en, this message translates to:
  /// **'No subscription payments yet.'**
  String get noSubscriptionPayments;

  /// No description provided for @serverTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long to respond. Try again shortly.'**
  String get serverTimeout;

  /// No description provided for @cannotReachServerDetailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Check your connection and backend URL.'**
  String get cannotReachServerDetailed;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed. Try again later.'**
  String get accountDeletionFailed;

  /// No description provided for @unexpectedDeletionError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during deletion.'**
  String get unexpectedDeletionError;

  /// No description provided for @myPurchases.
  ///
  /// In en, this message translates to:
  /// **'My purchases'**
  String get myPurchases;

  /// No description provided for @myPurchasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your order history'**
  String get myPurchasesSubtitle;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My reviews'**
  String get myReviews;

  /// No description provided for @myReviewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View or edit your comments'**
  String get myReviewsSubtitle;

  /// No description provided for @myInvoices.
  ///
  /// In en, this message translates to:
  /// **'My invoices'**
  String get myInvoices;

  /// No description provided for @myInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download your purchase receipts'**
  String get myInvoicesSubtitle;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully.'**
  String get accountCreatedSuccess;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @addDeliveryNote.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery note'**
  String get addDeliveryNote;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @packageLabel.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get packageLabel;

  /// No description provided for @packagesToDeliver.
  ///
  /// In en, this message translates to:
  /// **'Packages to deliver'**
  String get packagesToDeliver;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @qrContent.
  ///
  /// In en, this message translates to:
  /// **'QR content'**
  String get qrContent;

  /// No description provided for @carDescription.
  ///
  /// In en, this message translates to:
  /// **'Car description'**
  String get carDescription;

  /// No description provided for @becomeCertifiedDriver.
  ///
  /// In en, this message translates to:
  /// **'Become a certified driver'**
  String get becomeCertifiedDriver;

  /// No description provided for @adDuration.
  ///
  /// In en, this message translates to:
  /// **'Ad duration'**
  String get adDuration;

  /// No description provided for @inDelivery.
  ///
  /// In en, this message translates to:
  /// **'In delivery'**
  String get inDelivery;

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get inTransit;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// No description provided for @enterVehicleName.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle name'**
  String get enterVehicleName;

  /// No description provided for @enterCarDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter a description of your car (optional)'**
  String get enterCarDescriptionOptional;

  /// No description provided for @enterClientDestination.
  ///
  /// In en, this message translates to:
  /// **'Enter client destination'**
  String get enterClientDestination;

  /// No description provided for @enterBrand.
  ///
  /// In en, this message translates to:
  /// **'Enter brand'**
  String get enterBrand;

  /// No description provided for @enterModel.
  ///
  /// In en, this message translates to:
  /// **'Enter model'**
  String get enterModel;

  /// No description provided for @enterCustomModel.
  ///
  /// In en, this message translates to:
  /// **'Enter custom model'**
  String get enterCustomModel;

  /// No description provided for @enterDestinationDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your destination details here...'**
  String get enterDestinationDetails;

  /// No description provided for @engineDisplacementExample.
  ///
  /// In en, this message translates to:
  /// **'E.g. 1600 or 1.6'**
  String get engineDisplacementExample;

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @supplierToBuyer.
  ///
  /// In en, this message translates to:
  /// **'Supplier -> Buyer'**
  String get supplierToBuyer;

  /// No description provided for @deliveryEarnings.
  ///
  /// In en, this message translates to:
  /// **'Delivery earnings'**
  String get deliveryEarnings;

  /// No description provided for @vehicleInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration, type, brand and model are required.'**
  String get vehicleInfoRequired;

  /// No description provided for @vehicleInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information missing.'**
  String get vehicleInfoMissing;

  /// No description provided for @mileageHint.
  ///
  /// In en, this message translates to:
  /// **'Mileage (km), e.g. 12500 or 12.5'**
  String get mileageHint;

  /// No description provided for @externalLinkOptional.
  ///
  /// In en, this message translates to:
  /// **'External link (optional)'**
  String get externalLinkOptional;

  /// No description provided for @partOrCarName.
  ///
  /// In en, this message translates to:
  /// **'Part/car name'**
  String get partOrCarName;

  /// No description provided for @nameOnCard.
  ///
  /// In en, this message translates to:
  /// **'Name on card'**
  String get nameOnCard;

  /// No description provided for @seatCount.
  ///
  /// In en, this message translates to:
  /// **'Number of seats'**
  String get seatCount;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @notificationDefault.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationDefault;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderNumber;

  /// No description provided for @cashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash payment'**
  String get cashPayment;

  /// No description provided for @positionRequired.
  ///
  /// In en, this message translates to:
  /// **'Position required'**
  String get positionRequired;

  /// No description provided for @priceFcfa.
  ///
  /// In en, this message translates to:
  /// **'Price (FCFA)'**
  String get priceFcfa;

  /// No description provided for @priceFcfaExample.
  ///
  /// In en, this message translates to:
  /// **'Price in FCFA (e.g. 1500000 or 1,500,000.5)'**
  String get priceFcfaExample;

  /// No description provided for @offerDeliveryServices.
  ///
  /// In en, this message translates to:
  /// **'Offer delivery services'**
  String get offerDeliveryServices;

  /// No description provided for @specifyModel.
  ///
  /// In en, this message translates to:
  /// **'Specify model'**
  String get specifyModel;

  /// No description provided for @searchCarHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a car (brand, model, title)...'**
  String get searchCarHint;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @engineType.
  ///
  /// In en, this message translates to:
  /// **'Engine type'**
  String get engineType;

  /// No description provided for @adType.
  ///
  /// In en, this message translates to:
  /// **'Ad type'**
  String get adType;

  /// No description provided for @engineTypeShort.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engineTypeShort;

  /// No description provided for @toBuyer.
  ///
  /// In en, this message translates to:
  /// **'To buyer'**
  String get toBuyer;

  /// No description provided for @toSupplier.
  ///
  /// In en, this message translates to:
  /// **'To supplier'**
  String get toSupplier;

  /// No description provided for @pleaseEnterCompany.
  ///
  /// In en, this message translates to:
  /// **'Please enter your company.'**
  String get pleaseEnterCompany;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionLabel;

  /// No description provided for @buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyer;

  /// No description provided for @positionGpsSaved.
  ///
  /// In en, this message translates to:
  /// **'GPS position saved'**
  String get positionGpsSaved;

  /// No description provided for @enterLink.
  ///
  /// In en, this message translates to:
  /// **'Enter link'**
  String get enterLink;

  /// No description provided for @passwordSuperStrong.
  ///
  /// In en, this message translates to:
  /// **'Super strong'**
  String get passwordSuperStrong;

  /// No description provided for @onboardingTagline1.
  ///
  /// In en, this message translates to:
  /// **'Tranoo\nFind your parts and\nvehicles quickly'**
  String get onboardingTagline1;

  /// No description provided for @onboardingTagline2.
  ///
  /// In en, this message translates to:
  /// **'Discover your\nideal vehicle in\na few clicks'**
  String get onboardingTagline2;

  /// No description provided for @accountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account deletion'**
  String get accountDeletion;

  /// No description provided for @accountDeletionIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.'**
  String get accountDeletionIrreversible;

  /// No description provided for @accountDeletionDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Your account, app access and related data will be deleted.'**
  String get accountDeletionDataWarning;

  /// No description provided for @accountDeletionConfirmWarning.
  ///
  /// In en, this message translates to:
  /// **'Make sure you no longer need this account before confirming.'**
  String get accountDeletionConfirmWarning;

  /// No description provided for @editAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make changes to your account'**
  String get editAccountSubtitle;

  /// No description provided for @referral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referral;

  /// No description provided for @referralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn by referring friends'**
  String get referralSubtitle;

  /// No description provided for @sellMyCar.
  ///
  /// In en, this message translates to:
  /// **'Sell my car'**
  String get sellMyCar;

  /// No description provided for @sellMyPart.
  ///
  /// In en, this message translates to:
  /// **'Sell my part'**
  String get sellMyPart;

  /// No description provided for @becomeSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Become a seller and sell with us'**
  String get becomeSellerSubtitle;

  /// No description provided for @sellerAccessOnly.
  ///
  /// In en, this message translates to:
  /// **'Access reserved for sellers.'**
  String get sellerAccessOnly;

  /// No description provided for @transitaireAccessOnly.
  ///
  /// In en, this message translates to:
  /// **'Access reserved for freight forwarders.'**
  String get transitaireAccessOnly;

  /// No description provided for @transitHistory.
  ///
  /// In en, this message translates to:
  /// **'Transit history'**
  String get transitHistory;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @userNotConnected.
  ///
  /// In en, this message translates to:
  /// **'User not signed in'**
  String get userNotConnected;

  /// No description provided for @newAlertDefault.
  ///
  /// In en, this message translates to:
  /// **'New alert'**
  String get newAlertDefault;

  /// No description provided for @buyerSearchingPart.
  ///
  /// In en, this message translates to:
  /// **'A buyer is looking for a part.'**
  String get buyerSearchingPart;

  /// No description provided for @buyerSearchingVehicle.
  ///
  /// In en, this message translates to:
  /// **'A buyer is looking for a vehicle.'**
  String get buyerSearchingVehicle;

  /// No description provided for @characteristics.
  ///
  /// In en, this message translates to:
  /// **'Characteristics:'**
  String get characteristics;

  /// No description provided for @noCharacteristicsProvided.
  ///
  /// In en, this message translates to:
  /// **'- No characteristics provided'**
  String get noCharacteristicsProvided;

  /// No description provided for @proposeOffer.
  ///
  /// In en, this message translates to:
  /// **'Propose an offer'**
  String get proposeOffer;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add items to start shopping'**
  String get cartEmptyHint;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get checkout;

  /// No description provided for @carsOnline.
  ///
  /// In en, this message translates to:
  /// **'Cars online'**
  String get carsOnline;

  /// No description provided for @motosOnline.
  ///
  /// In en, this message translates to:
  /// **'Motorcycles online'**
  String get motosOnline;

  /// No description provided for @buyThisMoto.
  ///
  /// In en, this message translates to:
  /// **'Buy this motorcycle'**
  String get buyThisMoto;

  /// No description provided for @signInToBuyThisMoto.
  ///
  /// In en, this message translates to:
  /// **'Sign in to buy this motorcycle'**
  String get signInToBuyThisMoto;

  /// No description provided for @carDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Car deleted successfully!'**
  String get carDeletedSuccess;

  /// No description provided for @newCondition.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCondition;

  /// No description provided for @usedCondition.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedCondition;

  /// No description provided for @budgetFcfa.
  ///
  /// In en, this message translates to:
  /// **'Budget (FCFA)'**
  String get budgetFcfa;

  /// No description provided for @spareParts.
  ///
  /// In en, this message translates to:
  /// **'Spare parts'**
  String get spareParts;

  /// No description provided for @confirmDeletePart.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this part?'**
  String get confirmDeletePart;

  /// No description provided for @partDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Part deleted successfully!'**
  String get partDeletedSuccess;

  /// No description provided for @searchPartHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a part...'**
  String get searchPartHint;

  /// No description provided for @searchVehiclesPartsHint.
  ///
  /// In en, this message translates to:
  /// **'Search vehicles, parts...'**
  String get searchVehiclesPartsHint;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @tricycles.
  ///
  /// In en, this message translates to:
  /// **'Tricycles'**
  String get tricycles;

  /// No description provided for @fillMiniForm.
  ///
  /// In en, this message translates to:
  /// **'Fill mini form'**
  String get fillMiniForm;

  /// No description provided for @discussions.
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get discussions;

  /// No description provided for @noDiscussions.
  ///
  /// In en, this message translates to:
  /// **'No discussions'**
  String get noDiscussions;

  /// No description provided for @startDiscussionWithSeller.
  ///
  /// In en, this message translates to:
  /// **'Start a discussion with a seller'**
  String get startDiscussionWithSeller;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessageHint;

  /// No description provided for @messageSendError.
  ///
  /// In en, this message translates to:
  /// **'Error sending message'**
  String get messageSendError;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @notificationDetails.
  ///
  /// In en, this message translates to:
  /// **'Notification details'**
  String get notificationDetails;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrders;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get noOrders;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @orderTracking.
  ///
  /// In en, this message translates to:
  /// **'Order tracking'**
  String get orderTracking;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My wallet'**
  String get myWallet;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNow;

  /// No description provided for @returnToApp.
  ///
  /// In en, this message translates to:
  /// **'Return to app'**
  String get returnToApp;

  /// No description provided for @wooHoo.
  ///
  /// In en, this message translates to:
  /// **'Woo hoo!!'**
  String get wooHoo;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goToHome;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @publishedOnline.
  ///
  /// In en, this message translates to:
  /// **'Published online!'**
  String get publishedOnline;

  /// No description provided for @returnHome.
  ///
  /// In en, this message translates to:
  /// **'Return home'**
  String get returnHome;

  /// No description provided for @referralTitle.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referralTitle;

  /// No description provided for @referralLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral link copied!'**
  String get referralLinkCopied;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @yourStats.
  ///
  /// In en, this message translates to:
  /// **'Your statistics'**
  String get yourStats;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @chooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose location'**
  String get chooseLocation;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @livreurHome.
  ///
  /// In en, this message translates to:
  /// **'Delivery home'**
  String get livreurHome;

  /// No description provided for @chauffeurHome.
  ///
  /// In en, this message translates to:
  /// **'Driver home'**
  String get chauffeurHome;

  /// No description provided for @myDeliveries.
  ///
  /// In en, this message translates to:
  /// **'My deliveries'**
  String get myDeliveries;

  /// No description provided for @sellerSubscription.
  ///
  /// In en, this message translates to:
  /// **'Seller subscription'**
  String get sellerSubscription;

  /// No description provided for @premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription'**
  String get premiumSubscription;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now'**
  String get subscribeNow;

  /// No description provided for @sellerWallet.
  ///
  /// In en, this message translates to:
  /// **'Seller wallet'**
  String get sellerWallet;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @signInForProfile.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your profile'**
  String get signInForProfile;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile. Check your connection or permissions.'**
  String get profileLoadError;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get profileSaveError;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error during update'**
  String get profileUpdateError;

  /// No description provided for @restrictedAccess.
  ///
  /// In en, this message translates to:
  /// **'Restricted access'**
  String get restrictedAccess;

  /// No description provided for @roleNotAllowedOnApp.
  ///
  /// In en, this message translates to:
  /// **'Your role ({role}) is not allowed on {app}'**
  String roleNotAllowedOnApp(String role, String app);

  /// No description provided for @useAlternativeAppForRole.
  ///
  /// In en, this message translates to:
  /// **'Use {app} instead for your role'**
  String useAlternativeAppForRole(String app);

  /// No description provided for @googlePlay.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get googlePlay;

  /// No description provided for @appStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get appStore;

  /// No description provided for @alertNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert notifications'**
  String get alertNotificationsTitle;

  /// No description provided for @alertNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to be alerted when a seller responds to your alert, even when the app is in the background.'**
  String get alertNotificationsDescription;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @referralLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Your referral link'**
  String get referralLinkTitle;

  /// No description provided for @referralShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your referral link'**
  String get referralShareTitle;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @yourReferrals.
  ///
  /// In en, this message translates to:
  /// **'Your referrals'**
  String get yourReferrals;

  /// No description provided for @noReferralsYet.
  ///
  /// In en, this message translates to:
  /// **'No referrals yet'**
  String get noReferralsYet;

  /// No description provided for @shareReferralHint.
  ///
  /// In en, this message translates to:
  /// **'Share your code with friends to get started!'**
  String get shareReferralHint;

  /// No description provided for @referralShareMessage.
  ///
  /// In en, this message translates to:
  /// **'🚗 Join me on Tranoo!\n\nDownload the app via my referral link: {link}\n\nTogether, let\'s find the best cars and spare parts! 🚙✨'**
  String referralShareMessage(String link);

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error: {status} - {message}'**
  String serverError(String status, String message);

  /// No description provided for @alertLabelBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand: {value}'**
  String alertLabelBrand(String value);

  /// No description provided for @alertLabelModel.
  ///
  /// In en, this message translates to:
  /// **'Model: {value}'**
  String alertLabelModel(String value);

  /// No description provided for @alertLabelCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition: {value}'**
  String alertLabelCondition(String value);

  /// No description provided for @alertLabelYear.
  ///
  /// In en, this message translates to:
  /// **'Year: {value}'**
  String alertLabelYear(String value);

  /// No description provided for @alertLabelYearMin.
  ///
  /// In en, this message translates to:
  /// **'Min year: {value}'**
  String alertLabelYearMin(String value);

  /// No description provided for @alertLabelYearMax.
  ///
  /// In en, this message translates to:
  /// **'Max year: {value}'**
  String alertLabelYearMax(String value);

  /// No description provided for @alertLabelBudgetMax.
  ///
  /// In en, this message translates to:
  /// **'Max budget: {value} FCFA'**
  String alertLabelBudgetMax(String value);

  /// No description provided for @alertLabelPart.
  ///
  /// In en, this message translates to:
  /// **'Part: {value}'**
  String alertLabelPart(String value);

  /// No description provided for @alertLabelUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency: {value}'**
  String alertLabelUrgency(String value);

  /// No description provided for @alertLabelLocation.
  ///
  /// In en, this message translates to:
  /// **'Location: {value}'**
  String alertLabelLocation(String value);

  /// No description provided for @alertLabelDetails.
  ///
  /// In en, this message translates to:
  /// **'Details: {value}'**
  String alertLabelDetails(String value);

  /// No description provided for @confirmDeleteCar.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this car?'**
  String get confirmDeleteCar;

  /// No description provided for @vehicleBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle brand'**
  String get vehicleBrandLabel;

  /// No description provided for @partNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Part name'**
  String get partNameLabel;

  /// No description provided for @urgencyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get urgencyLow;

  /// No description provided for @urgencyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get urgencyNormal;

  /// No description provided for @urgencyHigh.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgencyHigh;

  /// No description provided for @alertSendError.
  ///
  /// In en, this message translates to:
  /// **'Alert send error: {error}'**
  String alertSendError(String error);

  /// No description provided for @searchTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Search type'**
  String get searchTypeTitle;

  /// No description provided for @whatDoYouWantToSearch.
  ///
  /// In en, this message translates to:
  /// **'What do you want to search?'**
  String get whatDoYouWantToSearch;

  /// No description provided for @noArticleLinkedToAd.
  ///
  /// In en, this message translates to:
  /// **'No item linked to this ad.'**
  String get noArticleLinkedToAd;

  /// No description provided for @sellerPhoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Seller phone number unavailable'**
  String get sellerPhoneUnavailable;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @requestValidatedWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Request approved — opening WhatsApp'**
  String get requestValidatedWhatsApp;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get requestRejected;

  /// No description provided for @errorActionStatus.
  ///
  /// In en, this message translates to:
  /// **'Action error: {status}'**
  String errorActionStatus(int status);

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get notificationsLoadError;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @markedAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Marked as unread'**
  String get markedAsUnread;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @confirmDeleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete this notification?'**
  String get confirmDeleteNotification;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get orderSummary;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select an address'**
  String get selectAddress;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get direction;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @orderPayment.
  ///
  /// In en, this message translates to:
  /// **'Order payment'**
  String get orderPayment;

  /// No description provided for @preparingPayment.
  ///
  /// In en, this message translates to:
  /// **'Preparing payment...'**
  String get preparingPayment;

  /// No description provided for @noActiveOrderToTrack.
  ///
  /// In en, this message translates to:
  /// **'No active order to track'**
  String get noActiveOrderToTrack;

  /// No description provided for @ordersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get ordersLoadError;

  /// No description provided for @orderRegisteredDeliverySoon.
  ///
  /// In en, this message translates to:
  /// **'Your order is registered. A driver will take charge of delivery soon.'**
  String get orderRegisteredDeliverySoon;

  /// No description provided for @driverAssignedTrackRealtime.
  ///
  /// In en, this message translates to:
  /// **'Driver assigned. Track their position in real time.'**
  String get driverAssignedTrackRealtime;

  /// No description provided for @returnPackage.
  ///
  /// In en, this message translates to:
  /// **'Return package'**
  String get returnPackage;

  /// No description provided for @pickupMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Pick up my order'**
  String get pickupMyOrder;

  /// No description provided for @deliveryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Delivery not found.'**
  String get deliveryNotFound;

  /// No description provided for @orderPickedUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order picked up successfully.'**
  String get orderPickedUpSuccess;

  /// No description provided for @pickupError.
  ///
  /// In en, this message translates to:
  /// **'Pickup error: {error}'**
  String pickupError(String error);

  /// No description provided for @returnReasonHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. wrong part, defect, model error…'**
  String get returnReasonHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason required.'**
  String get reasonRequired;

  /// No description provided for @returnReportedPaymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Return reported. Delivery fee payment required.'**
  String get returnReportedPaymentRequired;

  /// No description provided for @returnError.
  ///
  /// In en, this message translates to:
  /// **'Return error: {error}'**
  String returnError(String error);

  /// No description provided for @paymentInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Payment interrupted'**
  String get paymentInterrupted;

  /// No description provided for @paymentInterruptedMessage.
  ///
  /// In en, this message translates to:
  /// **'You left the payment screen or the transaction was not completed.'**
  String get paymentInterruptedMessage;

  /// No description provided for @paymentInterruptedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No charge recorded. You can try again anytime.'**
  String get paymentInterruptedSubtitle;

  /// No description provided for @paymentErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during the transaction.'**
  String get paymentErrorMessage;

  /// No description provided for @paymentErrorRetrySupport.
  ///
  /// In en, this message translates to:
  /// **'Please try again or contact support.'**
  String get paymentErrorRetrySupport;

  /// No description provided for @transactionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your transaction was completed successfully.'**
  String get transactionSuccessMessage;

  /// No description provided for @closePageReturnToApp.
  ///
  /// In en, this message translates to:
  /// **'You can now close this page and return to the app.'**
  String get closePageReturnToApp;

  /// No description provided for @selectToChoose.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectToChoose;

  /// No description provided for @bankPayment.
  ///
  /// In en, this message translates to:
  /// **'Bank payment'**
  String get bankPayment;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoney;

  /// No description provided for @paymentSuccessUpdatingStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment successful! Updating status...'**
  String get paymentSuccessUpdatingStatus;

  /// No description provided for @adPaidSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ad paid successfully!'**
  String get adPaidSuccess;

  /// No description provided for @subscriptionActivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated successfully!'**
  String get subscriptionActivatedSuccess;

  /// No description provided for @redirecting.
  ///
  /// In en, this message translates to:
  /// **'Redirecting...'**
  String get redirecting;

  /// No description provided for @verifyPayment.
  ///
  /// In en, this message translates to:
  /// **'Verify payment'**
  String get verifyPayment;

  /// No description provided for @finalizePayment.
  ///
  /// In en, this message translates to:
  /// **'Finalize payment'**
  String get finalizePayment;

  /// No description provided for @purchaseSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Dear customer, your purchase was successful. '**
  String get purchaseSuccessMessage;

  /// No description provided for @purchaseSuccessDelivery.
  ///
  /// In en, this message translates to:
  /// **'Your product will be delivered within 5 days at most. Thank you for your trust!'**
  String get purchaseSuccessDelivery;

  /// No description provided for @articleCreatedPendingValidation.
  ///
  /// In en, this message translates to:
  /// **'Well done! You created your listing. It is pending validation.'**
  String get articleCreatedPendingValidation;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get almostThere;

  /// No description provided for @spotlightCostPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your spotlight will cost about '**
  String get spotlightCostPrefix;

  /// No description provided for @spotlightCostSuffix.
  ///
  /// In en, this message translates to:
  /// **' for this vehicle. Continue and complete payment to see your vehicle at the top of our listings.'**
  String get spotlightCostSuffix;

  /// No description provided for @saleSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale successful!'**
  String get saleSuccessTitle;

  /// No description provided for @publishedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your listing is now online!'**
  String get publishedSuccessMessage;

  /// No description provided for @yourBalanceIs.
  ///
  /// In en, this message translates to:
  /// **'Your balance is:'**
  String get yourBalanceIs;

  /// No description provided for @entry.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get entry;

  /// No description provided for @makeWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Make a withdrawal'**
  String get makeWithdrawal;

  /// No description provided for @transferAccount.
  ///
  /// In en, this message translates to:
  /// **'Transfer account'**
  String get transferAccount;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @securityCode.
  ///
  /// In en, this message translates to:
  /// **'Card security code'**
  String get securityCode;

  /// No description provided for @codeHint.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeHint;

  /// No description provided for @requestWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Request withdrawal'**
  String get requestWithdrawal;

  /// No description provided for @myWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'My withdrawals'**
  String get myWithdrawals;

  /// No description provided for @withdrawalRequest.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request'**
  String get withdrawalRequest;

  /// No description provided for @noMessage.
  ///
  /// In en, this message translates to:
  /// **'No message'**
  String get noMessage;

  /// No description provided for @articleDefault.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get articleDefault;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @errorSendingImage.
  ///
  /// In en, this message translates to:
  /// **'Error sending image'**
  String get errorSendingImage;

  /// No description provided for @errorSendingDocument.
  ///
  /// In en, this message translates to:
  /// **'Error sending document'**
  String get errorSendingDocument;

  /// No description provided for @pdfLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfLabel;

  /// No description provided for @openingDocument.
  ///
  /// In en, this message translates to:
  /// **'Opening document...'**
  String get openingDocument;

  /// No description provided for @myTransits.
  ///
  /// In en, this message translates to:
  /// **'My transits'**
  String get myTransits;

  /// No description provided for @noArticlesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No items in this category'**
  String get noArticlesInCategory;

  /// No description provided for @discussionCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating discussion'**
  String get discussionCreationError;

  /// No description provided for @articleWithoutId.
  ///
  /// In en, this message translates to:
  /// **'Item without ID'**
  String get articleWithoutId;

  /// No description provided for @contactTransitaire.
  ///
  /// In en, this message translates to:
  /// **'Contact forwarder'**
  String get contactTransitaire;

  /// No description provided for @finalizePurchase.
  ///
  /// In en, this message translates to:
  /// **'Complete purchase'**
  String get finalizePurchase;

  /// No description provided for @chosenForwarderRate.
  ///
  /// In en, this message translates to:
  /// **'Selected forwarder rate'**
  String get chosenForwarderRate;

  /// No description provided for @additionalFees.
  ///
  /// In en, this message translates to:
  /// **'Additional fees'**
  String get additionalFees;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get totalPrice;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download invoice'**
  String get downloadInvoice;

  /// No description provided for @chooseFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose format:'**
  String get chooseFormat;

  /// No description provided for @imageFormat.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageFormat;

  /// No description provided for @documentFormat.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get documentFormat;

  /// No description provided for @imageGallery.
  ///
  /// In en, this message translates to:
  /// **'Image (Gallery)'**
  String get imageGallery;

  /// No description provided for @chooseDownloadFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose download format:'**
  String get chooseDownloadFormat;

  /// No description provided for @preparingShare.
  ///
  /// In en, this message translates to:
  /// **'Preparing share...'**
  String get preparingShare;

  /// No description provided for @invoiceReadyToShare.
  ///
  /// In en, this message translates to:
  /// **'Invoice ready to share!'**
  String get invoiceReadyToShare;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Share error: {error}'**
  String shareError(String error);

  /// No description provided for @maxImagesReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 12 images reached'**
  String get maxImagesReached;

  /// No description provided for @videoUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded successfully!'**
  String get videoUploadedSuccess;

  /// No description provided for @waitUploadFinish.
  ///
  /// In en, this message translates to:
  /// **'Please wait for upload to finish.'**
  String get waitUploadFinish;

  /// No description provided for @addAtLeastOneMedia.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image or video.'**
  String get addAtLeastOneMedia;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get fillRequiredFields;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitle;

  /// No description provided for @enterYear.
  ///
  /// In en, this message translates to:
  /// **'Enter year (e.g. 2020)'**
  String get enterYear;

  /// No description provided for @enterCylinder.
  ///
  /// In en, this message translates to:
  /// **'Enter cylinder (e.g. 1600)'**
  String get enterCylinder;

  /// No description provided for @enterDistance.
  ///
  /// In en, this message translates to:
  /// **'Enter distance (km)'**
  String get enterDistance;

  /// No description provided for @enterSeats.
  ///
  /// In en, this message translates to:
  /// **'Enter number of seats'**
  String get enterSeats;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @enterCarDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a description of your car'**
  String get enterCarDescription;

  /// No description provided for @uploadInProgress.
  ///
  /// In en, this message translates to:
  /// **'Upload in progress...'**
  String get uploadInProgress;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish listing'**
  String get publishListing;

  /// No description provided for @uploadImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed.'**
  String get uploadImageFailed;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get noImageSelected;

  /// No description provided for @newOffer.
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get newOffer;

  /// No description provided for @selectAtLeastOneImage.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one image.'**
  String get selectAtLeastOneImage;

  /// No description provided for @fillCarFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all car fields.'**
  String get fillCarFields;

  /// No description provided for @requestCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating request.'**
  String get requestCreationError;

  /// No description provided for @statusUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating status.'**
  String get statusUpdateError;

  /// No description provided for @clickableLinkOptional.
  ///
  /// In en, this message translates to:
  /// **'Clickable link (optional)'**
  String get clickableLinkOptional;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Part/car name'**
  String get itemName;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get locationPermissionDeniedForever;

  /// No description provided for @confirmThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm this location'**
  String get confirmThisLocation;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving license'**
  String get drivingLicense;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get yourMessage;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get submitApplication;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully!'**
  String get applicationSubmitted;

  /// No description provided for @applicationSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Error submitting application.'**
  String get applicationSubmitError;

  /// No description provided for @vendreTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get vendreTitle;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get buyNow;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact seller'**
  String get contactSeller;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get errorLoading;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get orderStatus;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get orderDate;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @errorUserNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Error: User not signed in'**
  String get errorUserNotConnected;

  /// No description provided for @adPaymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment was completed successfully! '**
  String get adPaymentSuccessMessage;

  /// No description provided for @adPaymentSuccessHighlight.
  ///
  /// In en, this message translates to:
  /// **'Your listing will be featured once validated by our team. You will receive a confirmation notification.'**
  String get adPaymentSuccessHighlight;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparing;

  /// No description provided for @listingPublishedVisiblePrefix.
  ///
  /// In en, this message translates to:
  /// **'Your listing is published and visible '**
  String get listingPublishedVisiblePrefix;

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'immediately'**
  String get immediately;

  /// No description provided for @listingPublishedVisibleSuffix.
  ///
  /// In en, this message translates to:
  /// **' on the app.\n\nYou can already find it in the listings.'**
  String get listingPublishedVisibleSuffix;

  /// No description provided for @listingAlreadyOnline.
  ///
  /// In en, this message translates to:
  /// **'Your listing is already online.'**
  String get listingAlreadyOnline;

  /// No description provided for @noVehicleSearchResultHint.
  ///
  /// In en, this message translates to:
  /// **'No car matches your search.\nCreate a mini alert to be contacted quickly.'**
  String get noVehicleSearchResultHint;

  /// No description provided for @noPartSearchResultHint.
  ///
  /// In en, this message translates to:
  /// **'No part matches your search.\nCreate a mini alert to be contacted quickly.'**
  String get noPartSearchResultHint;

  /// No description provided for @priceFcfaLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (FCFA)'**
  String get priceFcfaLabel;

  /// No description provided for @vehicleAlert.
  ///
  /// In en, this message translates to:
  /// **'Vehicle alert'**
  String get vehicleAlert;

  /// No description provided for @partAlert.
  ///
  /// In en, this message translates to:
  /// **'Part alert'**
  String get partAlert;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @vehicleCondition.
  ///
  /// In en, this message translates to:
  /// **'Vehicle condition'**
  String get vehicleCondition;

  /// No description provided for @brandRequired.
  ///
  /// In en, this message translates to:
  /// **'Brand required'**
  String get brandRequired;

  /// No description provided for @modelRequired.
  ///
  /// In en, this message translates to:
  /// **'Model required'**
  String get modelRequired;

  /// No description provided for @yearRequired.
  ///
  /// In en, this message translates to:
  /// **'Year required'**
  String get yearRequired;

  /// No description provided for @budgetRequired.
  ///
  /// In en, this message translates to:
  /// **'Budget required'**
  String get budgetRequired;

  /// No description provided for @alertRegisteredFeedback.
  ///
  /// In en, this message translates to:
  /// **'Your request has been registered. You will hear back from sellers very soon.'**
  String get alertRegisteredFeedback;

  /// No description provided for @whatsappOpenDetailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open WhatsApp. Check that the app or a browser is installed on your phone.'**
  String get whatsappOpenDetailed;

  /// No description provided for @noVideoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No video available'**
  String get noVideoAvailable;

  /// No description provided for @cannotMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Unable to make a call'**
  String get cannotMakeCall;

  /// No description provided for @cylinder.
  ///
  /// In en, this message translates to:
  /// **'Cylinder'**
  String get cylinder;

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuel;

  /// No description provided for @airConditioner.
  ///
  /// In en, this message translates to:
  /// **'Air conditioning'**
  String get airConditioner;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceKm;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// No description provided for @doors.
  ///
  /// In en, this message translates to:
  /// **'Doors'**
  String get doors;

  /// No description provided for @gearbox.
  ///
  /// In en, this message translates to:
  /// **'Gearbox'**
  String get gearbox;

  /// No description provided for @customsClearance.
  ///
  /// In en, this message translates to:
  /// **'Customs clearance'**
  String get customsClearance;

  /// No description provided for @inConsumption.
  ///
  /// In en, this message translates to:
  /// **'For consumption'**
  String get inConsumption;

  /// No description provided for @chooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose a country'**
  String get chooseCountry;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get additionalDetails;

  /// No description provided for @signInForVerification.
  ///
  /// In en, this message translates to:
  /// **'Sign in to request verification'**
  String get signInForVerification;

  /// No description provided for @signInForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Sign in to order with delivery'**
  String get signInForDelivery;

  /// No description provided for @signInToBuyThisCar.
  ///
  /// In en, this message translates to:
  /// **'Sign in to buy this car'**
  String get signInToBuyThisCar;

  /// No description provided for @chooseDeliveryMode.
  ///
  /// In en, this message translates to:
  /// **'Please choose a delivery mode (For consumption or In transit).'**
  String get chooseDeliveryMode;

  /// No description provided for @selectLocationPlease.
  ///
  /// In en, this message translates to:
  /// **'Please select a location.'**
  String get selectLocationPlease;

  /// No description provided for @verificationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Verification in progress'**
  String get verificationInProgress;

  /// No description provided for @verificationChecksPrefix.
  ///
  /// In en, this message translates to:
  /// **'Checks will be performed and sent to you within '**
  String get verificationChecksPrefix;

  /// No description provided for @tenBusinessDays.
  ///
  /// In en, this message translates to:
  /// **'10 days'**
  String get tenBusinessDays;

  /// No description provided for @verificationChecksMiddle.
  ///
  /// In en, this message translates to:
  /// **'. To start, please pay the '**
  String get verificationChecksMiddle;

  /// No description provided for @verificationFeesLabel.
  ///
  /// In en, this message translates to:
  /// **'verification fees'**
  String get verificationFeesLabel;

  /// No description provided for @payVerificationFees.
  ///
  /// In en, this message translates to:
  /// **'Pay verification fees'**
  String get payVerificationFees;

  /// No description provided for @requestVerification.
  ///
  /// In en, this message translates to:
  /// **'Request verification'**
  String get requestVerification;

  /// No description provided for @buyThisCar.
  ///
  /// In en, this message translates to:
  /// **'Buy this car'**
  String get buyThisCar;

  /// No description provided for @sampleCarDescription.
  ///
  /// In en, this message translates to:
  /// **'The Tesla Model 3 is a mid-size electric sedan known for impressive performance, acceleration and range.'**
  String get sampleCarDescription;

  /// No description provided for @chooseCondition.
  ///
  /// In en, this message translates to:
  /// **'Choose condition'**
  String get chooseCondition;

  /// No description provided for @chooseBrand.
  ///
  /// In en, this message translates to:
  /// **'Choose brand'**
  String get chooseBrand;

  /// No description provided for @chooseModel.
  ///
  /// In en, this message translates to:
  /// **'Choose model'**
  String get chooseModel;

  /// No description provided for @chooseDoorCount.
  ///
  /// In en, this message translates to:
  /// **'Choose number of doors'**
  String get chooseDoorCount;

  /// No description provided for @chooseGearbox.
  ///
  /// In en, this message translates to:
  /// **'Choose gearbox'**
  String get chooseGearbox;

  /// No description provided for @chooseFuel.
  ///
  /// In en, this message translates to:
  /// **'Choose fuel'**
  String get chooseFuel;

  /// No description provided for @chooseAirConditioner.
  ///
  /// In en, this message translates to:
  /// **'Choose air conditioning'**
  String get chooseAirConditioner;

  /// No description provided for @brandsLabel.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brandsLabel;

  /// No description provided for @doorSingular.
  ///
  /// In en, this message translates to:
  /// **'Door'**
  String get doorSingular;

  /// No description provided for @seatSingular.
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get seatSingular;

  /// No description provided for @selectedColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected color: {color}'**
  String selectedColorLabel(String color);

  /// No description provided for @companyBlOwner.
  ///
  /// In en, this message translates to:
  /// **'Company name on bill of lading'**
  String get companyBlOwner;

  /// No description provided for @imagesOptionalMax12.
  ///
  /// In en, this message translates to:
  /// **'Images (optional, max 12)'**
  String get imagesOptionalMax12;

  /// No description provided for @videoOptionalMax500.
  ///
  /// In en, this message translates to:
  /// **'Video (optional, max 500 MB)'**
  String get videoOptionalMax500;

  /// No description provided for @addImagesButton.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get addImagesButton;

  /// No description provided for @videoReady.
  ///
  /// In en, this message translates to:
  /// **'Video ready'**
  String get videoReady;

  /// No description provided for @mediaSlot.
  ///
  /// In en, this message translates to:
  /// **'Slot {index}'**
  String mediaSlot(int index);

  /// No description provided for @tapToAddVideo.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get tapToAddVideo;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @videoTooHeavy.
  ///
  /// In en, this message translates to:
  /// **'Video is too large ({size} MB). Limit: 500 MB.'**
  String videoTooHeavy(String size);

  /// No description provided for @videoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading video. Please try again.'**
  String get videoUploadError;

  /// No description provided for @maxMediaCount.
  ///
  /// In en, this message translates to:
  /// **'You can select at most {count} media items.'**
  String maxMediaCount(int count);

  /// No description provided for @manualTransmission.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manualTransmission;

  /// No description provided for @automaticTransmission.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automaticTransmission;

  /// No description provided for @petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get petrol;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @otherOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherOption;

  /// No description provided for @pieceName.
  ///
  /// In en, this message translates to:
  /// **'Part name'**
  String get pieceName;

  /// No description provided for @enterYearShort.
  ///
  /// In en, this message translates to:
  /// **'Enter year'**
  String get enterYearShort;

  /// No description provided for @placement.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get placement;

  /// No description provided for @enterPartDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a description of your part'**
  String get enterPartDescription;

  /// No description provided for @verificationAction.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationAction;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(String error);

  /// No description provided for @videoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Video upload failed: {error}'**
  String videoUploadFailed(String error);

  /// No description provided for @selectedModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected model: {model}'**
  String selectedModelLabel(String model);

  /// No description provided for @customModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom model: {model}'**
  String customModelLabel(String model);

  /// No description provided for @enterEngineType.
  ///
  /// In en, this message translates to:
  /// **'Enter engine type'**
  String get enterEngineType;

  /// No description provided for @noEngine.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noEngine;

  /// No description provided for @gazoil.
  ///
  /// In en, this message translates to:
  /// **'Gas oil'**
  String get gazoil;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add a video'**
  String get addVideo;

  /// No description provided for @videoUploadedLabel.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded'**
  String get videoUploadedLabel;

  /// No description provided for @beforeContactSeller.
  ///
  /// In en, this message translates to:
  /// **'Before contacting the seller'**
  String get beforeContactSeller;

  /// No description provided for @contactSellerTips.
  ///
  /// In en, this message translates to:
  /// **'• Confirm price and any fees\n• Check location and availability\n• Discuss item condition clearly\n• Prefer a safe place for the transaction'**
  String get contactSellerTips;

  /// No description provided for @orderWithDelivery.
  ///
  /// In en, this message translates to:
  /// **'Order with delivery'**
  String get orderWithDelivery;

  /// No description provided for @buyViaApp.
  ///
  /// In en, this message translates to:
  /// **'Buy via the app'**
  String get buyViaApp;

  /// No description provided for @secureOrderViaCart.
  ///
  /// In en, this message translates to:
  /// **'Secure order via Tranoo cart (delivery available).'**
  String get secureOrderViaCart;

  /// No description provided for @partTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Part type'**
  String get partTypeLabel;

  /// No description provided for @ratingOutOf5.
  ///
  /// In en, this message translates to:
  /// **'0 / 5'**
  String get ratingOutOf5;

  /// No description provided for @mastervacSampleDescription.
  ///
  /// In en, this message translates to:
  /// **'Essential braking component, the brake booster amplifies pedal force to make braking easier.'**
  String get mastervacSampleDescription;

  /// No description provided for @rare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rare;

  /// No description provided for @sellYourPart.
  ///
  /// In en, this message translates to:
  /// **'Sell your part'**
  String get sellYourPart;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @createAd.
  ///
  /// In en, this message translates to:
  /// **'Create an ad'**
  String get createAd;

  /// No description provided for @adRequest.
  ///
  /// In en, this message translates to:
  /// **'Ad request'**
  String get adRequest;

  /// No description provided for @standaloneAd.
  ///
  /// In en, this message translates to:
  /// **'Standalone ad'**
  String get standaloneAd;

  /// No description provided for @existingArticleAd.
  ///
  /// In en, this message translates to:
  /// **'Existing item ad'**
  String get existingArticleAd;

  /// No description provided for @standaloneAdDesc.
  ///
  /// In en, this message translates to:
  /// **'Standalone featured ad. Upload a flyer (1080 x 1350 px recommended) and add an optional link to your site or catalog.'**
  String get standaloneAdDesc;

  /// No description provided for @nonExistingPubDesc.
  ///
  /// In en, this message translates to:
  /// **'Non-existing listing. You are creating a new offer. Users can tap to see your offer details.'**
  String get nonExistingPubDesc;

  /// No description provided for @existingArticlePubDesc.
  ///
  /// In en, this message translates to:
  /// **'You are creating an ad for an existing item. Users can tap to see the full item.'**
  String get existingArticlePubDesc;

  /// No description provided for @loadingArticleInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading item information...'**
  String get loadingArticleInfo;

  /// No description provided for @articleLoadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item loaded successfully! You can now advertise this item.'**
  String get articleLoadedSuccess;

  /// No description provided for @linkExampleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. https://wa.me/2250700000000 or https://my-site.com'**
  String get linkExampleHint;

  /// No description provided for @linkHelperText.
  ///
  /// In en, this message translates to:
  /// **'Let users open your site, catalog or payment form.'**
  String get linkHelperText;

  /// No description provided for @selectAdType.
  ///
  /// In en, this message translates to:
  /// **'Please select a type'**
  String get selectAdType;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Please select a duration'**
  String get selectDuration;

  /// No description provided for @sponsoredType.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsoredType;

  /// No description provided for @featuredType.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featuredType;

  /// No description provided for @oneWeek.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get oneWeek;

  /// No description provided for @twoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks'**
  String get twoWeeks;

  /// No description provided for @oneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get oneMonth;

  /// No description provided for @twoMonths.
  ///
  /// In en, this message translates to:
  /// **'2 months'**
  String get twoMonths;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get threeMonths;

  /// No description provided for @pricePerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'{price}/day'**
  String pricePerDayLabel(String price);

  /// No description provided for @carInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information'**
  String get carInfoSection;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name'**
  String get enterName;

  /// No description provided for @enterYearValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter the year'**
  String get enterYearValidator;

  /// No description provided for @enterLocationValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter the location'**
  String get enterLocationValidator;

  /// No description provided for @enterPriceValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter the price'**
  String get enterPriceValidator;

  /// No description provided for @enterDescriptionValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get enterDescriptionValidator;

  /// No description provided for @enterCompanyValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter the company name'**
  String get enterCompanyValidator;

  /// No description provided for @selectEngineTypeValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select engine type'**
  String get selectEngineTypeValidator;

  /// No description provided for @selectModelValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select the model'**
  String get selectModelValidator;

  /// No description provided for @selectTypeValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select the type'**
  String get selectTypeValidator;

  /// No description provided for @mainFlyerImage.
  ///
  /// In en, this message translates to:
  /// **'Main image (flyer)'**
  String get mainFlyerImage;

  /// No description provided for @recommendedDimensions.
  ///
  /// In en, this message translates to:
  /// **'Recommended dimensions: 1080 x 1350 px (PNG/JPG)'**
  String get recommendedDimensions;

  /// No description provided for @addMainImage.
  ///
  /// In en, this message translates to:
  /// **'Add main image'**
  String get addMainImage;

  /// No description provided for @dimensions1080x1350.
  ///
  /// In en, this message translates to:
  /// **'1080 x 1350 px'**
  String get dimensions1080x1350;

  /// No description provided for @additionalImagesOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional images (optional)'**
  String get additionalImagesOptional;

  /// No description provided for @standaloneFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured ad'**
  String get standaloneFeaturedTitle;

  /// No description provided for @standaloneFeaturedDesc.
  ///
  /// In en, this message translates to:
  /// **'Dedicated flyer, no existing item needed. Just add your visual and (optionally) an external link.'**
  String get standaloneFeaturedDesc;

  /// No description provided for @addMainImageForFeatured.
  ///
  /// In en, this message translates to:
  /// **'Please add a main image for \"Featured\".'**
  String get addMainImageForFeatured;

  /// No description provided for @articleCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating item.'**
  String get articleCreateError;

  /// No description provided for @articleCreateNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error while creating item: {error}'**
  String articleCreateNetworkError(String error);

  /// No description provided for @articleLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading item'**
  String get articleLoadError;

  /// No description provided for @articleLoadNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error while loading item'**
  String get articleLoadNetworkError;

  /// No description provided for @mediaUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading media: {error}'**
  String mediaUploadError(String error);

  /// No description provided for @fillAllFieldsShort.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fillAllFieldsShort;

  /// No description provided for @articleNotExistCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'This item does not exist. Please create it and after admin validation you can feature it.'**
  String get articleNotExistCreateFirst;

  /// No description provided for @articleNotExistFeaturedFirst.
  ///
  /// In en, this message translates to:
  /// **'This item does not exist. For \"Featured\" ads, create the item first and after admin validation you can feature it.'**
  String get articleNotExistFeaturedFirst;

  /// No description provided for @articleCreateRetryError.
  ///
  /// In en, this message translates to:
  /// **'Error creating item. Please try again.'**
  String get articleCreateRetryError;

  /// No description provided for @paymentSuccessPendingValidation.
  ///
  /// In en, this message translates to:
  /// **'Payment successful, pending admin validation. You will receive a notification once approved.'**
  String get paymentSuccessPendingValidation;

  /// No description provided for @pubForTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad for {title}'**
  String pubForTitle(String title);

  /// No description provided for @noDescriptionAd.
  ///
  /// In en, this message translates to:
  /// **'Ad without description'**
  String get noDescriptionAd;

  /// No description provided for @defaultCarName.
  ///
  /// In en, this message translates to:
  /// **'Car name'**
  String get defaultCarName;

  /// No description provided for @defaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get defaultLocation;

  /// No description provided for @defaultPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get defaultPrice;

  /// No description provided for @defaultCarDescription.
  ///
  /// In en, this message translates to:
  /// **'Car description'**
  String get defaultCarDescription;

  /// No description provided for @defaultCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get defaultCompanyName;

  /// No description provided for @defaultBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get defaultBrand;

  /// No description provided for @standaloneFeaturedDescriptionDefault.
  ///
  /// In en, this message translates to:
  /// **'Featured ad (Tranoo storefront flyer)'**
  String get standaloneFeaturedDescriptionDefault;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @boostVisibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Boost your visibility with clients'**
  String get boostVisibilitySubtitle;

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'Premium benefits'**
  String get premiumBenefits;

  /// No description provided for @prioritySpotlight.
  ///
  /// In en, this message translates to:
  /// **'Priority spotlight'**
  String get prioritySpotlight;

  /// No description provided for @prioritySpotlightDesc.
  ///
  /// In en, this message translates to:
  /// **'Appear first in search results'**
  String get prioritySpotlightDesc;

  /// No description provided for @premiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium badge'**
  String get premiumBadge;

  /// No description provided for @premiumBadgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Gold badge visible on your profile'**
  String get premiumBadgeDesc;

  /// No description provided for @boostedVisibility.
  ///
  /// In en, this message translates to:
  /// **'Boosted visibility'**
  String get boostedVisibility;

  /// No description provided for @boostedVisibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'More clients contact you'**
  String get boostedVisibilityDesc;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get prioritySupport;

  /// No description provided for @prioritySupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Dedicated assistance 24/7'**
  String get prioritySupportDesc;

  /// No description provided for @monthlySubscription.
  ///
  /// In en, this message translates to:
  /// **'Monthly subscription'**
  String get monthlySubscription;

  /// No description provided for @subscriptionAutoRenewNote.
  ///
  /// In en, this message translates to:
  /// **'Your subscription renews automatically each month. You can cancel anytime.'**
  String get subscriptionAutoRenewNote;

  /// No description provided for @subscribeNowPrice.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now - {price} FCFA'**
  String subscribeNowPrice(String price);

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not signed in'**
  String get userNotLoggedIn;

  /// No description provided for @feexpayConfigMissing.
  ///
  /// In en, this message translates to:
  /// **'FeexPay configuration missing'**
  String get feexpayConfigMissing;

  /// No description provided for @feexpayConfigMissingDetailed.
  ///
  /// In en, this message translates to:
  /// **'FeexPay configuration missing (FP_TOKEN_FEEXPAY / ID_USER_FEEXPAY)'**
  String get feexpayConfigMissingDetailed;

  /// No description provided for @verificationFeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification fees'**
  String get verificationFeesTitle;

  /// No description provided for @documentVerification.
  ///
  /// In en, this message translates to:
  /// **'Document verification'**
  String get documentVerification;

  /// No description provided for @verifyDocumentsAuthenticity.
  ///
  /// In en, this message translates to:
  /// **'Verify the authenticity of your documents'**
  String get verifyDocumentsAuthenticity;

  /// No description provided for @includedServices.
  ///
  /// In en, this message translates to:
  /// **'Included services'**
  String get includedServices;

  /// No description provided for @fullVerification.
  ///
  /// In en, this message translates to:
  /// **'Full verification'**
  String get fullVerification;

  /// No description provided for @fullVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Review of all your official documents'**
  String get fullVerificationDesc;

  /// No description provided for @fastProcessing.
  ///
  /// In en, this message translates to:
  /// **'Fast processing'**
  String get fastProcessing;

  /// No description provided for @fastProcessingDesc.
  ///
  /// In en, this message translates to:
  /// **'Results within 10 business days'**
  String get fastProcessingDesc;

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'one-time payment'**
  String get oneTimePayment;

  /// No description provided for @verificationPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'After payment, you will receive a summary and checks will be completed within 10 business days.'**
  String get verificationPaymentNote;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to payment - {price} FCFA'**
  String proceedToPayment(String price);

  /// No description provided for @paymentReceivedIncompleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Payment received but server record incomplete. Retry or contact support.'**
  String get paymentReceivedIncompleteRecord;

  /// No description provided for @paymentReceivedVerificationProcessing.
  ///
  /// In en, this message translates to:
  /// **'Payment received. Your verification request is being processed.'**
  String get paymentReceivedVerificationProcessing;

  /// No description provided for @paymentCancelledNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled or not confirmed. Try again if needed.'**
  String get paymentCancelledNotConfirmed;

  /// No description provided for @cannotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data'**
  String get cannotLoadData;

  /// No description provided for @recommendedForwarders.
  ///
  /// In en, this message translates to:
  /// **'Recommended forwarders'**
  String get recommendedForwarders;

  /// No description provided for @seeMoreForwarders.
  ///
  /// In en, this message translates to:
  /// **'See more forwarders'**
  String get seeMoreForwarders;

  /// No description provided for @forwarderPremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium subscriber'**
  String get forwarderPremiumBadge;

  /// No description provided for @forwarderVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get forwarderVerifiedBadge;

  /// No description provided for @forwarderStandardBadge.
  ///
  /// In en, this message translates to:
  /// **'Forwarder'**
  String get forwarderStandardBadge;

  /// No description provided for @internationalTransit.
  ///
  /// In en, this message translates to:
  /// **'International transit'**
  String get internationalTransit;

  /// No description provided for @noForwardersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No forwarders available'**
  String get noForwardersAvailable;

  /// No description provided for @forwarderSubscribedShort.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get forwarderSubscribedShort;

  /// No description provided for @forwarderStandardShort.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get forwarderStandardShort;

  /// No description provided for @forwardersTitle.
  ///
  /// In en, this message translates to:
  /// **'Forwarders'**
  String get forwardersTitle;

  /// No description provided for @forwarderTabStarred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get forwarderTabStarred;

  /// No description provided for @forwarderTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get forwarderTabAll;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @galleryMediaCount.
  ///
  /// In en, this message translates to:
  /// **'{count} media'**
  String galleryMediaCount(int count);

  /// No description provided for @subscribedSince.
  ///
  /// In en, this message translates to:
  /// **'Subscribed since {date}'**
  String subscribedSince(String date);

  /// No description provided for @noStarredForwarders.
  ///
  /// In en, this message translates to:
  /// **'No starred forwarders.'**
  String get noStarredForwarders;

  /// No description provided for @transitaireProfileTabGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get transitaireProfileTabGallery;

  /// No description provided for @transitaireGalleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photos or videos at the moment.'**
  String get transitaireGalleryEmpty;

  /// No description provided for @transitaireGalleryEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add photos or videos.'**
  String get transitaireGalleryEmptyOwner;

  /// No description provided for @transitaireGalleryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to gallery'**
  String get transitaireGalleryAddTitle;

  /// No description provided for @transitaireGalleryPhotosMulti.
  ///
  /// In en, this message translates to:
  /// **'Photos (one or more)'**
  String get transitaireGalleryPhotosMulti;

  /// No description provided for @transitaireGalleryVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get transitaireGalleryVideo;

  /// No description provided for @transitaireGalleryUploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Sending photos…'**
  String get transitaireGalleryUploadingPhotos;

  /// No description provided for @transitaireGalleryUploadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Sending video…'**
  String get transitaireGalleryUploadingVideo;

  /// No description provided for @transitaireGalleryUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Try again.'**
  String get transitaireGalleryUploadFailed;

  /// No description provided for @transitaireGallerySaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving gallery.'**
  String get transitaireGallerySaveError;

  /// No description provided for @transitaireGalleryUploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload error.'**
  String get transitaireGalleryUploadError;

  /// No description provided for @transitaireGalleryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get transitaireGalleryDeleteTitle;

  /// No description provided for @transitaireGalleryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this item from the gallery?'**
  String get transitaireGalleryDeleteConfirm;

  /// No description provided for @transitaireGalleryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete.'**
  String get transitaireGalleryDeleteFailed;

  /// No description provided for @transitaireGalleryMaxItems.
  ///
  /// In en, this message translates to:
  /// **'Limit of {count} items reached.'**
  String transitaireGalleryMaxItems(int count);

  /// No description provided for @videoPlaybackError.
  ///
  /// In en, this message translates to:
  /// **'Unable to play video'**
  String get videoPlaybackError;

  /// No description provided for @contactPhoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Contact number unavailable.'**
  String get contactPhoneUnavailable;

  /// No description provided for @transitaireDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Forwarder'**
  String get transitaireDefaultName;

  /// No description provided for @transitaireServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'International transit services'**
  String get transitaireServicesSubtitle;

  /// No description provided for @transitaireDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get transitaireDescriptionLabel;

  /// No description provided for @transitaireDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your transit services…'**
  String get transitaireDescriptionHint;

  /// No description provided for @transitaireBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Forwarder'**
  String get transitaireBadgeLabel;

  /// No description provided for @westAfricaDefault.
  ///
  /// In en, this message translates to:
  /// **'West Africa'**
  String get westAfricaDefault;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @filterTypeTab.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterTypeTab;

  /// No description provided for @filterBrandTab.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get filterBrandTab;

  /// No description provided for @filterLocationTab.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocationTab;

  /// No description provided for @pieceTypeSpareParts.
  ///
  /// In en, this message translates to:
  /// **'Spare parts'**
  String get pieceTypeSpareParts;

  /// No description provided for @pieceTypeTires.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get pieceTypeTires;

  /// No description provided for @pieceTypeOils.
  ///
  /// In en, this message translates to:
  /// **'Oils and lubricants'**
  String get pieceTypeOils;

  /// No description provided for @pieceTypeBatteries.
  ///
  /// In en, this message translates to:
  /// **'Batteries'**
  String get pieceTypeBatteries;

  /// No description provided for @pieceTypeAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get pieceTypeAccessories;

  /// No description provided for @forwarderSubscription.
  ///
  /// In en, this message translates to:
  /// **'Forwarder subscription'**
  String get forwarderSubscription;

  /// No description provided for @activateMonthlySubscription.
  ///
  /// In en, this message translates to:
  /// **'Activate a monthly subscription to be featured to buyers.'**
  String get activateMonthlySubscription;

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} FCFA / month'**
  String pricePerMonth(String price);

  /// No description provided for @activatedOn.
  ///
  /// In en, this message translates to:
  /// **'Activated on: {date}'**
  String activatedOn(String date);

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on: {date}'**
  String expiresOn(String date);

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @boosted.
  ///
  /// In en, this message translates to:
  /// **'Boosted'**
  String get boosted;

  /// No description provided for @spotlight.
  ///
  /// In en, this message translates to:
  /// **'Spotlight'**
  String get spotlight;

  /// No description provided for @subscriptionStatus.
  ///
  /// In en, this message translates to:
  /// **'Subscription status'**
  String get subscriptionStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @noActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get noActiveSubscription;

  /// No description provided for @performances.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performances;

  /// No description provided for @ordersDeliveredPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Orders delivered / month'**
  String get ordersDeliveredPerMonth;

  /// No description provided for @clientDistribution.
  ///
  /// In en, this message translates to:
  /// **'Client distribution'**
  String get clientDistribution;

  /// No description provided for @chartBuyers.
  ///
  /// In en, this message translates to:
  /// **'Buyers'**
  String get chartBuyers;

  /// No description provided for @chartDrivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get chartDrivers;

  /// No description provided for @chartOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get chartOthers;

  /// No description provided for @discuss.
  ///
  /// In en, this message translates to:
  /// **'Discuss'**
  String get discuss;

  /// No description provided for @priceWithValue.
  ///
  /// In en, this message translates to:
  /// **'Price: {price}'**
  String priceWithValue(String price);

  /// No description provided for @priceNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get priceNotSpecified;

  /// No description provided for @sellerInfoError.
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to retrieve seller information'**
  String get sellerInfoError;

  /// No description provided for @transitHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Transit history'**
  String get transitHistoryTitle;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client: {name}'**
  String clientLabel(String name);

  /// No description provided for @departurePortLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure port: {port}'**
  String departurePortLabel(String port);

  /// No description provided for @arrivalPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Arrival port: {port}'**
  String arrivalPortLabel(String port);

  /// No description provided for @transitDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Transit date: {date}'**
  String transitDateLabel(String date);

  /// No description provided for @statusWithValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusWithValue(String status);

  /// No description provided for @deliveredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Delivered successfully'**
  String get deliveredSuccessfully;

  /// No description provided for @atCustoms.
  ///
  /// In en, this message translates to:
  /// **'At customs'**
  String get atCustoms;

  /// No description provided for @billOfLading.
  ///
  /// In en, this message translates to:
  /// **'Bill of lading'**
  String get billOfLading;

  /// No description provided for @proformaInvoice.
  ///
  /// In en, this message translates to:
  /// **'Pro forma invoice'**
  String get proformaInvoice;

  /// No description provided for @transitCertificate.
  ///
  /// In en, this message translates to:
  /// **'Transit certificate'**
  String get transitCertificate;

  /// No description provided for @partialCustomsCertificate.
  ///
  /// In en, this message translates to:
  /// **'Partial customs clearance certificate'**
  String get partialCustomsCertificate;

  /// No description provided for @inspectionCertificate.
  ///
  /// In en, this message translates to:
  /// **'Inspection certificate'**
  String get inspectionCertificate;

  /// No description provided for @transitFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Transit forms'**
  String get transitFormTitle;

  /// No description provided for @carNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Car name'**
  String get carNameLabel;

  /// No description provided for @clientField.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientField;

  /// No description provided for @departurePort.
  ///
  /// In en, this message translates to:
  /// **'Departure port'**
  String get departurePort;

  /// No description provided for @arrivalPort.
  ///
  /// In en, this message translates to:
  /// **'Arrival port'**
  String get arrivalPort;

  /// No description provided for @transitDate.
  ///
  /// In en, this message translates to:
  /// **'Transit date'**
  String get transitDate;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get uploadDocuments;

  /// No description provided for @registrationForm.
  ///
  /// In en, this message translates to:
  /// **'Registration form'**
  String get registrationForm;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get familyName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterYourFirstName;

  /// No description provided for @typeYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get typeYourPhone;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get licenseNumber;

  /// No description provided for @enterLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your license number'**
  String get enterLicenseNumber;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @writeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Write your message'**
  String get writeYourMessage;

  /// No description provided for @uploadImagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload images'**
  String get uploadImagesLabel;

  /// No description provided for @myLicensePdf.
  ///
  /// In en, this message translates to:
  /// **'My license PDF'**
  String get myLicensePdf;

  /// No description provided for @fillFieldsAndUploadLicense.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields and upload your license.'**
  String get fillFieldsAndUploadLicense;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully!'**
  String get requestSentSuccess;

  /// No description provided for @sendErrorWithBody.
  ///
  /// In en, this message translates to:
  /// **'Error sending: {body}'**
  String sendErrorWithBody(String body);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) ago'**
  String timeAgoDays(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeAgoMinutes(int count);

  /// No description provided for @checkingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get checkingPermissions;

  /// No description provided for @redirectingIfNeeded.
  ///
  /// In en, this message translates to:
  /// **'Redirecting if necessary'**
  String get redirectingIfNeeded;

  /// No description provided for @unauthorizedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access'**
  String get unauthorizedAccess;

  /// No description provided for @tricycle_home_title.
  ///
  /// In en, this message translates to:
  /// **'Tricycles'**
  String get tricycle_home_title;

  /// No description provided for @tricycle_request_accepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get tricycle_request_accepted;

  /// No description provided for @tricycle_request_sent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get tricycle_request_sent;

  /// No description provided for @tricycle_order_command.
  ///
  /// In en, this message translates to:
  /// **'Order · Tricycle'**
  String get tricycle_order_command;

  /// No description provided for @feexpayPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'FeexPay payment'**
  String get feexpayPaymentTitle;

  /// No description provided for @feexpayInitSuccess.
  ///
  /// In en, this message translates to:
  /// **'FeexPay service initialized successfully'**
  String get feexpayInitSuccess;

  /// No description provided for @feexpayInitError.
  ///
  /// In en, this message translates to:
  /// **'Initialization error: {error}'**
  String feexpayInitError(String error);

  /// No description provided for @paymentInitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment initialized successfully!'**
  String get paymentInitSuccess;

  /// No description provided for @cannotOpenPaymentPage.
  ///
  /// In en, this message translates to:
  /// **'Unable to open payment page'**
  String get cannotOpenPaymentPage;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get transactionDetailsTitle;

  /// No description provided for @labelTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get labelTransactionId;

  /// No description provided for @valueAmountFcfa.
  ///
  /// In en, this message translates to:
  /// **'{amount} FCFA'**
  String valueAmountFcfa(String amount);

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the amount'**
  String get enterAmount;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBePositive;

  /// No description provided for @enterDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get enterDescriptionRequired;

  /// No description provided for @enterOrderId.
  ///
  /// In en, this message translates to:
  /// **'Please enter an order ID'**
  String get enterOrderId;

  /// No description provided for @commandIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get commandIdLabel;

  /// No description provided for @paymentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get paymentTypeLabel;

  /// No description provided for @mobileMoneyProviders.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money (MTN, Moov, Orange)'**
  String get mobileMoneyProviders;

  /// No description provided for @bankCardPayment.
  ///
  /// In en, this message translates to:
  /// **'Bank card (VISA, Mastercard)'**
  String get bankCardPayment;

  /// No description provided for @feexpayWallet.
  ///
  /// In en, this message translates to:
  /// **'FeexPay wallet'**
  String get feexpayWallet;

  /// No description provided for @initializeFeexpay.
  ///
  /// In en, this message translates to:
  /// **'Initialize FeexPay'**
  String get initializeFeexpay;

  /// No description provided for @aboutFeexpay.
  ///
  /// In en, this message translates to:
  /// **'About FeexPay'**
  String get aboutFeexpay;

  /// No description provided for @feexpayAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'FeexPay is a secure payment aggregator that accepts:'**
  String get feexpayAboutDescription;

  /// No description provided for @feexpayAcceptedMethods.
  ///
  /// In en, this message translates to:
  /// **'• MTN Mobile Money, Moov Money, Orange Money\n• VISA and Mastercard cards\n• Digital wallets'**
  String get feexpayAcceptedMethods;

  /// No description provided for @feexpayTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'FeexPay transactions'**
  String get feexpayTransactionsTitle;

  /// No description provided for @transactionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading: {error}'**
  String transactionsLoadError(String error);

  /// No description provided for @processRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Process a refund'**
  String get processRefundTitle;

  /// No description provided for @transactionWithId.
  ///
  /// In en, this message translates to:
  /// **'Transaction: {id}'**
  String transactionWithId(String id);

  /// No description provided for @refundAmountFcfa.
  ///
  /// In en, this message translates to:
  /// **'Refund amount (FCFA)'**
  String get refundAmountFcfa;

  /// No description provided for @refundReason.
  ///
  /// In en, this message translates to:
  /// **'Refund reason'**
  String get refundReason;

  /// No description provided for @refundAction.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refundAction;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @refundSuccess.
  ///
  /// In en, this message translates to:
  /// **'Refund completed successfully'**
  String get refundSuccess;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get transactionHistory;

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transaction(s)'**
  String transactionCount(int count);

  /// No description provided for @accountBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Account balance'**
  String get accountBalanceLabel;

  /// No description provided for @currencyWithValue.
  ///
  /// In en, this message translates to:
  /// **'Currency: {currency}'**
  String currencyWithValue(String currency);

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @transactionsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Transactions will appear here after your first payments'**
  String get transactionsEmptyHint;

  /// No description provided for @transactionNoDescription.
  ///
  /// In en, this message translates to:
  /// **'Transaction without description'**
  String get transactionNoDescription;

  /// No description provided for @idWithValue.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idWithValue(String id);

  /// No description provided for @dateWithValue.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateWithValue(String date);

  /// No description provided for @methodWithValue.
  ///
  /// In en, this message translates to:
  /// **'Method: {method}'**
  String methodWithValue(String method);

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @customerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer email'**
  String get customerEmailLabel;

  /// No description provided for @accountBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account blocked'**
  String get accountBlockedTitle;

  /// No description provided for @accountBlockedDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'You cannot access the app because an administrator has temporarily blocked you.'**
  String get accountBlockedDialogMessage;

  /// No description provided for @contactSupportTeam.
  ///
  /// In en, this message translates to:
  /// **'Contact the support team for more information.'**
  String get contactSupportTeam;

  /// No description provided for @driverArrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your delivery driver has arrived'**
  String get driverArrivedTitle;

  /// No description provided for @chooseAnAction.
  ///
  /// In en, this message translates to:
  /// **'Choose an action.'**
  String get chooseAnAction;

  /// No description provided for @orderTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Order total'**
  String get orderTotalLabel;

  /// No description provided for @deliveryFeesLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFeesLabel;

  /// No description provided for @payMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Pay my order'**
  String get payMyOrder;

  /// No description provided for @returnReasonRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Return reason (required)'**
  String get returnReasonRequiredTitle;

  /// No description provided for @partsOrderPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Parts order payment'**
  String get partsOrderPaymentLabel;

  /// No description provided for @deliveryFeePaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee payment'**
  String get deliveryFeePaymentLabel;

  /// No description provided for @fileDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to download the file'**
  String get fileDownloadFailed;

  /// No description provided for @tranooDocumentShare.
  ///
  /// In en, this message translates to:
  /// **'Tranoo document'**
  String get tranooDocumentShare;

  /// No description provided for @refWithId.
  ///
  /// In en, this message translates to:
  /// **'Ref. {id}'**
  String refWithId(String id);

  /// No description provided for @attachedImages.
  ///
  /// In en, this message translates to:
  /// **'Attached images'**
  String get attachedImages;

  /// No description provided for @attachedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attached documents'**
  String get attachedDocuments;

  /// No description provided for @stampAndSignature.
  ///
  /// In en, this message translates to:
  /// **'Stamp and signature'**
  String get stampAndSignature;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @downloadReportPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF report'**
  String get downloadReportPdf;

  /// No description provided for @imageWithIndex.
  ///
  /// In en, this message translates to:
  /// **'Image {index}'**
  String imageWithIndex(int index);

  /// No description provided for @documentWithIndex.
  ///
  /// In en, this message translates to:
  /// **'Document {index}'**
  String documentWithIndex(int index);

  /// No description provided for @buyerAlert.
  ///
  /// In en, this message translates to:
  /// **'Buyer alert'**
  String get buyerAlert;

  /// No description provided for @swipeUpOrTap.
  ///
  /// In en, this message translates to:
  /// **'Swipe up or tap'**
  String get swipeUpOrTap;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @newAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'New alert'**
  String get newAlertTitle;

  /// No description provided for @sellerRespondedToAlert.
  ///
  /// In en, this message translates to:
  /// **'A seller responded to your alert'**
  String get sellerRespondedToAlert;

  /// No description provided for @videoAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video available'**
  String get videoAvailable;

  /// No description provided for @withdrawalProcessingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request is being processed and you will receive confirmation once the withdrawal is complete. If you have questions or wish to modify your request, contact us. Thank you for your trust.'**
  String get withdrawalProcessingMessage;

  /// No description provided for @departurePortField.
  ///
  /// In en, this message translates to:
  /// **'Departure port'**
  String get departurePortField;

  /// No description provided for @arrivalPortField.
  ///
  /// In en, this message translates to:
  /// **'Arrival port'**
  String get arrivalPortField;

  /// No description provided for @transitDateField.
  ///
  /// In en, this message translates to:
  /// **'Transit date'**
  String get transitDateField;

  /// No description provided for @carNameExample.
  ///
  /// In en, this message translates to:
  /// **'Toyota Corolla 2018'**
  String get carNameExample;

  /// No description provided for @clientExample.
  ///
  /// In en, this message translates to:
  /// **'Marcel T'**
  String get clientExample;

  /// No description provided for @departurePortExample.
  ///
  /// In en, this message translates to:
  /// **'Antwerp, Belgium'**
  String get departurePortExample;

  /// No description provided for @arrivalPortExample.
  ///
  /// In en, this message translates to:
  /// **'Cotonou, Benin'**
  String get arrivalPortExample;

  /// No description provided for @transitDateExample.
  ///
  /// In en, this message translates to:
  /// **'April 10, 2025'**
  String get transitDateExample;

  /// No description provided for @timeAgoMinutesLong.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String timeAgoMinutesLong(int count);

  /// No description provided for @notificationsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String notificationsSelectedCount(int count);

  /// No description provided for @confirmDeleteNotificationsCount.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} notification(s)?'**
  String confirmDeleteNotificationsCount(int count);

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequest;

  /// No description provided for @budgetAmountFcfa.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount} FCFA'**
  String budgetAmountFcfa(String amount);

  /// No description provided for @alertProposalForYourAlert.
  ///
  /// In en, this message translates to:
  /// **'Offer for your alert'**
  String get alertProposalForYourAlert;

  /// No description provided for @whatsappInterestWithRef.
  ///
  /// In en, this message translates to:
  /// **'Hello Tranoo, I confirm my interest in purchasing: {title} (ref. {articleId}).'**
  String whatsappInterestWithRef(String title, String articleId);

  /// No description provided for @whatsappInterestNoRef.
  ///
  /// In en, this message translates to:
  /// **'Hello Tranoo, I confirm my interest in purchasing: {title}.'**
  String whatsappInterestNoRef(String title);

  /// No description provided for @whatsappCarInterestWithRef.
  ///
  /// In en, this message translates to:
  /// **'Hello Tranoo, I would like to buy the car \"{title}\" (ref. {articleId}).'**
  String whatsappCarInterestWithRef(String title, String articleId);

  /// No description provided for @whatsappCarInterestNoRef.
  ///
  /// In en, this message translates to:
  /// **'Hello Tranoo, I would like to buy the car \"{title}\".'**
  String whatsappCarInterestNoRef(String title);

  /// No description provided for @whatsappMotoInterestWithRef.
  ///
  /// In en, this message translates to:
  /// **'Hello Tranoo, I would like to buy the motorcycle \"{title}\" (ref. {articleId}).'**
  String whatsappMotoInterestWithRef(String title, String articleId);

  /// No description provided for @whatsappMotoInterestNoRef.
  ///
  /// In en, this message translates to:
  /// **'Hello Tranoo, I would like to buy the motorcycle \"{title}\".'**
  String whatsappMotoInterestNoRef(String title);

  /// No description provided for @defaultMotoTitle.
  ///
  /// In en, this message translates to:
  /// **'this motorcycle'**
  String get defaultMotoTitle;

  /// No description provided for @defaultVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'vehicle'**
  String get defaultVehicleTitle;

  /// No description provided for @cannotLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your orders'**
  String get cannotLoadOrders;

  /// No description provided for @noOrdersYetHint.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t placed any orders yet'**
  String get noOrdersYetHint;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @filterTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get filterTracking;

  /// No description provided for @finishedOrdersHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'Completed or cancelled orders do not appear here'**
  String get finishedOrdersHiddenHint;

  /// No description provided for @orderCmdNumber.
  ///
  /// In en, this message translates to:
  /// **'CMD #{id}'**
  String orderCmdNumber(String id);

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orderStatusReady;

  /// No description provided for @orderStatusDelivering.
  ///
  /// In en, this message translates to:
  /// **'Delivering'**
  String get orderStatusDelivering;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusDriverAssigned.
  ///
  /// In en, this message translates to:
  /// **'Driver assigned'**
  String get orderStatusDriverAssigned;

  /// No description provided for @tranooDelivery.
  ///
  /// In en, this message translates to:
  /// **'Tranoo Delivery'**
  String get tranooDelivery;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @addressNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Address not specified'**
  String get addressNotSpecified;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty: x{qty}'**
  String quantityLabel(int qty);

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get deliveryDetails;

  /// No description provided for @driverAssignmentPending.
  ///
  /// In en, this message translates to:
  /// **'Assignment in progress'**
  String get driverAssignmentPending;

  /// No description provided for @defaultLocationCotonou.
  ///
  /// In en, this message translates to:
  /// **'Cotonou, Benin'**
  String get defaultLocationCotonou;

  /// No description provided for @apiErrorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'API error ({status}): {details}'**
  String apiErrorWithDetails(String status, String details);

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'JAN'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'FEB'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'MAR'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'MAY'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'JUN'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'JUL'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'AUG'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'SEP'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'OCT'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'NOV'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'DEC'**
  String get monthDec;

  /// No description provided for @fetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get fetchingLocation;

  /// No description provided for @fetchMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get fetchMyLocation;

  /// No description provided for @chooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get chooseOnMap;

  /// No description provided for @currentPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current position'**
  String get currentPositionLabel;

  /// No description provided for @selectedPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get selectedPositionLabel;

  /// No description provided for @coordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Lat: {lat}\nLon: {lng}'**
  String coordinatesLabel(String lat, String lng);

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFeeLabel;

  /// No description provided for @processingOrder.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingOrder;

  /// No description provided for @supplierCoordsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Supplier coordinates unavailable to calculate delivery.'**
  String get supplierCoordsUnavailable;

  /// No description provided for @invalidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinates'**
  String get invalidCoordinates;

  /// No description provided for @selectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Selection cancelled'**
  String get selectionCancelled;

  /// No description provided for @mapSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Map selection error: {error}'**
  String mapSelectionError(String error);

  /// No description provided for @locationRetrievedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Current position retrieved successfully!'**
  String get locationRetrievedSuccess;

  /// No description provided for @deliveryAddressSelectedOnMap.
  ///
  /// In en, this message translates to:
  /// **'Delivery address selected on the map!'**
  String get deliveryAddressSelectedOnMap;

  /// No description provided for @enableLocationInSettingsMsg.
  ///
  /// In en, this message translates to:
  /// **'Enable location in settings'**
  String get enableLocationInSettingsMsg;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Location error: {error}'**
  String locationError(String error);

  /// No description provided for @invalidDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid delivery address'**
  String get invalidDeliveryAddress;

  /// No description provided for @selectDeliveryAddressPlease.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address'**
  String get selectDeliveryAddressPlease;

  /// No description provided for @confirmYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm your order'**
  String get confirmYourOrder;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay: {amount} F'**
  String totalToPay(String amount);

  /// No description provided for @transactionFailedNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction failed/cancelled. Order not saved.'**
  String get transactionFailedNotSaved;

  /// No description provided for @orderConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed!'**
  String get orderConfirmedTitle;

  /// No description provided for @orderSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your order was saved successfully.'**
  String get orderSavedSuccess;

  /// No description provided for @deliveryExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected delivery'**
  String get deliveryExpected;

  /// No description provided for @deliveryBetween3And7Days.
  ///
  /// In en, this message translates to:
  /// **'Within 3 to 7 business days'**
  String get deliveryBetween3And7Days;

  /// No description provided for @youWillReceiveNotification.
  ///
  /// In en, this message translates to:
  /// **'You will receive a notification'**
  String get youWillReceiveNotification;

  /// No description provided for @availAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availAvailable;

  /// No description provided for @avail15to30min.
  ///
  /// In en, this message translates to:
  /// **'In 15-30 min'**
  String get avail15to30min;

  /// No description provided for @avail1to2h.
  ///
  /// In en, this message translates to:
  /// **'In 1-2h'**
  String get avail1to2h;

  /// No description provided for @availBefore12.
  ///
  /// In en, this message translates to:
  /// **'Before 12pm'**
  String get availBefore12;

  /// No description provided for @availBefore18.
  ///
  /// In en, this message translates to:
  /// **'Before 6pm'**
  String get availBefore18;

  /// No description provided for @availBefore20.
  ///
  /// In en, this message translates to:
  /// **'Before 8pm'**
  String get availBefore20;

  /// No description provided for @availFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get availFlexible;

  /// No description provided for @supplierDefault.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierDefault;

  /// No description provided for @supplierAddressDefault.
  ///
  /// In en, this message translates to:
  /// **'Supplier address'**
  String get supplierAddressDefault;

  /// No description provided for @orderSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving order: {error}'**
  String orderSaveError(String error);

  /// No description provided for @positionCoords.
  ///
  /// In en, this message translates to:
  /// **'Position: {lat}, {lng}'**
  String positionCoords(String lat, String lng);

  /// No description provided for @orderPaymentTranooDescription.
  ///
  /// In en, this message translates to:
  /// **'Tranoo order payment'**
  String get orderPaymentTranooDescription;

  /// No description provided for @mobileMoneyPayment.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money payment'**
  String get mobileMoneyPayment;

  /// No description provided for @adDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your ad details'**
  String get adDetailsTitle;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get amountToPay;

  /// No description provided for @viaMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'via Mobile Money'**
  String get viaMobileMoney;

  /// No description provided for @supportedOperators.
  ///
  /// In en, this message translates to:
  /// **'Supported operators'**
  String get supportedOperators;

  /// No description provided for @afterPaymentAdValidationNote.
  ///
  /// In en, this message translates to:
  /// **'After payment, your ad will be submitted for admin validation before publication.'**
  String get afterPaymentAdValidationNote;

  /// No description provided for @payAmountFcfa.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} FCFA'**
  String payAmountFcfa(String amount);

  /// No description provided for @adForYourListing.
  ///
  /// In en, this message translates to:
  /// **'Ad for your listing'**
  String get adForYourListing;

  /// No description provided for @adPaymentMobileDescription.
  ///
  /// In en, this message translates to:
  /// **'Ad payment (mobile money) {pubId}'**
  String adPaymentMobileDescription(String pubId);

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @invoicesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load invoices'**
  String get invoicesLoadError;

  /// No description provided for @signInForInvoices.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your invoices'**
  String get signInForInvoices;

  /// No description provided for @signInForPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your purchase history'**
  String get signInForPurchaseHistory;

  /// No description provided for @signInForCart.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your cart'**
  String get signInForCart;

  /// No description provided for @signInForNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access notifications'**
  String get signInForNotifications;

  /// No description provided for @noInvoicesYet.
  ///
  /// In en, this message translates to:
  /// **'You have no invoices yet.'**
  String get noInvoicesYet;

  /// No description provided for @unreadLabel.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unreadLabel;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @filterAllDates.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAllDates;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get filterThisWeek;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get filterThisMonth;

  /// No description provided for @filterCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get filterCustom;

  /// No description provided for @selectedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected date: {date}'**
  String selectedDateLabel(String date);

  /// No description provided for @invoicePreview.
  ///
  /// In en, this message translates to:
  /// **'Invoice preview'**
  String get invoicePreview;

  /// No description provided for @transactionSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction success'**
  String get transactionSuccessTitle;

  /// No description provided for @transactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Transaction number {ref}'**
  String transactionNumber(String ref);

  /// No description provided for @dateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateTimeLabel;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @sellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerLabel;

  /// No description provided for @shopLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopLabel;

  /// No description provided for @fundsSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Funding source'**
  String get fundsSourceLabel;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationLabel;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get referenceLabel;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details:'**
  String get productDetails;

  /// No description provided for @productPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Product price'**
  String get productPriceLabel;

  /// No description provided for @deliveryPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery price'**
  String get deliveryPriceLabel;

  /// No description provided for @vatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vatLabel;

  /// No description provided for @totalTransaction.
  ///
  /// In en, this message translates to:
  /// **'Total transaction'**
  String get totalTransaction;

  /// No description provided for @tranooSupport.
  ///
  /// In en, this message translates to:
  /// **'Tranoo support'**
  String get tranooSupport;

  /// No description provided for @thankYouForTrust.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your trust '**
  String get thankYouForTrust;

  /// No description provided for @officialInvoiceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This invoice is an official document. In case of dispute, please contact our support.'**
  String get officialInvoiceDisclaimer;

  /// No description provided for @saveInvoiceImage.
  ///
  /// In en, this message translates to:
  /// **'Save invoice (image)'**
  String get saveInvoiceImage;

  /// No description provided for @saveInvoiceDocument.
  ///
  /// In en, this message translates to:
  /// **'Save invoice (document)'**
  String get saveInvoiceDocument;

  /// No description provided for @imageSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully'**
  String get imageSavedSuccess;

  /// No description provided for @imageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image'**
  String get imageSaveFailed;

  /// No description provided for @documentSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF document saved successfully'**
  String get documentSavedSuccess;

  /// No description provided for @documentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save PDF document'**
  String get documentSaveFailed;

  /// No description provided for @captureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Capture unavailable'**
  String get captureUnavailable;

  /// No description provided for @imageGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate image'**
  String get imageGenerationFailed;

  /// No description provided for @paidStatus.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidStatus;

  /// No description provided for @pendingPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingPaymentStatus;

  /// No description provided for @sellerDefault.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerDefault;

  /// No description provided for @shopDefault.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopDefault;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'INVOICE {number}'**
  String invoiceTitle(String number);

  /// No description provided for @purchasesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading purchases'**
  String get purchasesLoadError;

  /// No description provided for @purchaseStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String purchaseStatusLabel(String status);

  /// No description provided for @deliveryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery date: {date}'**
  String deliveryDateLabel(String date);

  /// No description provided for @deliveryLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery location: {location}'**
  String deliveryLocationLabel(String location);

  /// No description provided for @fuelTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuel type: {type}'**
  String fuelTypeLabel(String type);

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color: {color}'**
  String colorLabel(String color);

  /// No description provided for @publishedOn.
  ///
  /// In en, this message translates to:
  /// **'Published on {date}'**
  String publishedOn(String date);

  /// No description provided for @ratingOutOf.
  ///
  /// In en, this message translates to:
  /// **'{rating}/5'**
  String ratingOutOf(int rating);

  /// No description provided for @minutesAgo2.
  ///
  /// In en, this message translates to:
  /// **'2 min ago'**
  String get minutesAgo2;

  /// No description provided for @inProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgressStatus;

  /// No description provided for @yearDropdown.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearDropdown;

  /// No description provided for @cardPlaceholderName.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get cardPlaceholderName;

  /// No description provided for @cardNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0000 0000 0000 0000'**
  String get cardNumberPlaceholder;

  /// No description provided for @paymentFormFor.
  ///
  /// In en, this message translates to:
  /// **'Payment form for {name}'**
  String paymentFormFor(String name);

  /// No description provided for @partNameLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Part name: {name}'**
  String partNameLabelShort(String name);

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @unknownCompany.
  ///
  /// In en, this message translates to:
  /// **'Unknown company'**
  String get unknownCompany;

  /// No description provided for @piecesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading parts'**
  String get piecesLoadError;

  /// No description provided for @carsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading cars'**
  String get carsLoadError;

  /// No description provided for @adsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading ads'**
  String get adsLoadError;

  /// No description provided for @dataFormatError.
  ///
  /// In en, this message translates to:
  /// **'Data format error'**
  String get dataFormatError;

  /// No description provided for @filterModelsTab.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get filterModelsTab;

  /// No description provided for @filterBudgetTab.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get filterBudgetTab;

  /// No description provided for @noCarsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cars available at the moment.'**
  String get noCarsAvailable;

  /// No description provided for @noPartsAvailableOnline.
  ///
  /// In en, this message translates to:
  /// **'No parts online at the moment'**
  String get noPartsAvailableOnline;

  /// No description provided for @noCarsOnlineSeller.
  ///
  /// In en, this message translates to:
  /// **'You have no cars online'**
  String get noCarsOnlineSeller;

  /// No description provided for @noPartsOnlineSeller.
  ///
  /// In en, this message translates to:
  /// **'You have no parts online at the moment'**
  String get noPartsOnlineSeller;

  /// No description provided for @doorsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} doors'**
  String doorsCountLabel(String count);

  /// No description provided for @sponsoredLabel.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsoredLabel;

  /// No description provided for @chooseTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose type'**
  String get chooseTypeTitle;

  /// No description provided for @youTyped.
  ///
  /// In en, this message translates to:
  /// **'You typed: \"{text}\"'**
  String youTyped(String text);

  /// No description provided for @whatArticleTypeSearch.
  ///
  /// In en, this message translates to:
  /// **'What type of item are you looking for?'**
  String get whatArticleTypeSearch;

  /// No description provided for @vehicleSingular.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleSingular;

  /// No description provided for @partSingular.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get partSingular;

  /// No description provided for @unknownArticleType.
  ///
  /// In en, this message translates to:
  /// **'Unknown item type.'**
  String get unknownArticleType;

  /// No description provided for @urgencyLevel.
  ///
  /// In en, this message translates to:
  /// **'Urgency level'**
  String get urgencyLevel;

  /// No description provided for @partNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Part name required'**
  String get partNameRequired;

  /// No description provided for @showVehiclesCount.
  ///
  /// In en, this message translates to:
  /// **'Show {count} vehicle(s)'**
  String showVehiclesCount(int count);

  /// No description provided for @buyerSearchingPartShort.
  ///
  /// In en, this message translates to:
  /// **'A buyer is looking for a part'**
  String get buyerSearchingPartShort;

  /// No description provided for @buyerSearchingVehicleShort.
  ///
  /// In en, this message translates to:
  /// **'A buyer is looking for a vehicle'**
  String get buyerSearchingVehicleShort;

  /// No description provided for @validateLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get validateLocation;

  /// No description provided for @colorField.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorField;

  /// No description provided for @pubRequestCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating request.'**
  String get pubRequestCreateError;

  /// No description provided for @videoOptional.
  ///
  /// In en, this message translates to:
  /// **'Video (optional)'**
  String get videoOptional;

  /// No description provided for @viewListing.
  ///
  /// In en, this message translates to:
  /// **'View listing'**
  String get viewListing;

  /// No description provided for @enlarge.
  ///
  /// In en, this message translates to:
  /// **'Enlarge'**
  String get enlarge;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @cannotGenerateImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate image'**
  String get cannotGenerateImage;

  /// No description provided for @errorLoadingArticle.
  ///
  /// In en, this message translates to:
  /// **'Error loading item.'**
  String get errorLoadingArticle;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get conditionNew;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetLabel;

  /// No description provided for @budgetMinHint.
  ///
  /// In en, this message translates to:
  /// **'Min budget'**
  String get budgetMinHint;

  /// No description provided for @budgetMaxHint.
  ///
  /// In en, this message translates to:
  /// **'Max budget'**
  String get budgetMaxHint;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @tvaLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get tvaLabel;

  /// No description provided for @deliveryLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryLabelShort;

  /// No description provided for @totalLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabelShort;

  /// No description provided for @articleLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get articleLabel;

  /// No description provided for @urgencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgencyLabel;

  /// No description provided for @invoicesLoadErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Unable to load invoices ({status}): {message}'**
  String invoicesLoadErrorDetail(String status, String message);

  /// No description provided for @verifyProPermissions.
  ///
  /// In en, this message translates to:
  /// **'Verifying professional permissions...'**
  String get verifyProPermissions;

  /// No description provided for @advertisingLabel.
  ///
  /// In en, this message translates to:
  /// **'Advertising'**
  String get advertisingLabel;

  /// No description provided for @sellerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller type'**
  String get sellerTypeLabel;

  /// No description provided for @deliveryToLabel.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliveryToLabel;

  /// No description provided for @cashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashLabel;

  /// No description provided for @onlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineLabel;

  /// No description provided for @placeOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Order • {total} F'**
  String placeOrderButton(String total);

  /// No description provided for @cashOnDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDeliveryTitle;

  /// No description provided for @cashOnDeliveryChosen.
  ///
  /// In en, this message translates to:
  /// **'You chose cash on delivery.'**
  String get cashOnDeliveryChosen;

  /// No description provided for @cashOnDeliveryBilled.
  ///
  /// In en, this message translates to:
  /// **'You will be charged when you receive your order.'**
  String get cashOnDeliveryBilled;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get changesSaved;

  /// No description provided for @saveErrorStatus.
  ///
  /// In en, this message translates to:
  /// **'Save error: {status}'**
  String saveErrorStatus(String status);

  /// No description provided for @saveErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String saveErrorGeneric(String error);

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart'**
  String get itemAddedToCart;

  /// No description provided for @modifyPart.
  ///
  /// In en, this message translates to:
  /// **'Edit part'**
  String get modifyPart;

  /// No description provided for @someImagesNotAdded.
  ///
  /// In en, this message translates to:
  /// **'Some images could not be added:'**
  String get someImagesNotAdded;

  /// No description provided for @imagesAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} image(s) added successfully'**
  String imagesAddedSuccess(int count);

  /// No description provided for @unsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported format. Accepted: {formats}'**
  String unsupportedFormat(String formats);

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// No description provided for @phoneWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone {number}'**
  String phoneWithNumber(String number);

  /// No description provided for @phoneNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Phone not provided — complete your profile'**
  String get phoneNotProvided;

  /// No description provided for @locationMissingProfile.
  ///
  /// In en, this message translates to:
  /// **'Location missing — update your position in profile.'**
  String get locationMissingProfile;

  /// No description provided for @profileContactLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Phone and location from sign-up. Update your profile if needed.'**
  String get profileContactLocationHint;

  /// No description provided for @vehicleLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle location'**
  String get vehicleLocationLabel;

  /// No description provided for @profileLocationReuse.
  ///
  /// In en, this message translates to:
  /// **'Uses your registered sign-up position (profile).'**
  String get profileLocationReuse;

  /// No description provided for @noProfileLocation.
  ///
  /// In en, this message translates to:
  /// **'No profile location — update your position in Profile.'**
  String get noProfileLocation;

  /// No description provided for @descriptionNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Description not provided'**
  String get descriptionNotProvided;

  /// No description provided for @mileageLabel.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get mileageLabel;

  /// No description provided for @maxImages12.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 12 images reached'**
  String get maxImages12;

  /// No description provided for @maxImages10.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 10 images reached'**
  String get maxImages10;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(String error);

  /// No description provided for @selectionError.
  ///
  /// In en, this message translates to:
  /// **'Selection error: {error}'**
  String selectionError(String error);

  /// No description provided for @imageAdded.
  ///
  /// In en, this message translates to:
  /// **'Image added: {name}'**
  String imageAdded(String name);

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded: {name}'**
  String imageUploaded(String name);

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload error: {error}'**
  String uploadError(String error);

  /// No description provided for @errorDetail.
  ///
  /// In en, this message translates to:
  /// **'Detailed error: {error}'**
  String errorDetail(String error);

  /// No description provided for @verificationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification details'**
  String get verificationDetailTitle;

  /// No description provided for @recipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipientLabel;

  /// No description provided for @cannotOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Unable to open document'**
  String get cannotOpenDocument;

  /// No description provided for @featureNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This feature is no longer available'**
  String get featureNoLongerAvailable;

  /// No description provided for @articleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found'**
  String get articleNotFound;

  /// No description provided for @articleNoLongerOnline.
  ///
  /// In en, this message translates to:
  /// **'This listing is no longer online.'**
  String get articleNoLongerOnline;

  /// No description provided for @sessionExpiredReconnect.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Sign in again.'**
  String get sessionExpiredReconnect;

  /// No description provided for @cannotLoadProposal.
  ///
  /// In en, this message translates to:
  /// **'Unable to load proposal.'**
  String get cannotLoadProposal;

  /// No description provided for @searchDetails.
  ///
  /// In en, this message translates to:
  /// **'Search details'**
  String get searchDetails;

  /// No description provided for @proposeOfferButton.
  ///
  /// In en, this message translates to:
  /// **'Propose an offer'**
  String get proposeOfferButton;

  /// No description provided for @specialPromotion.
  ///
  /// In en, this message translates to:
  /// **'Special promotion'**
  String get specialPromotion;

  /// No description provided for @viewProposal.
  ///
  /// In en, this message translates to:
  /// **'View proposal'**
  String get viewProposal;

  /// No description provided for @partSearched.
  ///
  /// In en, this message translates to:
  /// **'Part searched'**
  String get partSearched;

  /// No description provided for @articleNotFoundVerification.
  ///
  /// In en, this message translates to:
  /// **'Item not found for verification'**
  String get articleNotFoundVerification;

  /// No description provided for @noUserForNotifications.
  ///
  /// In en, this message translates to:
  /// **'No signed-in user. Cannot load notifications.'**
  String get noUserForNotifications;

  /// No description provided for @verifySubscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify subscription plan.'**
  String get verifySubscriptionPlan;

  /// No description provided for @viewSubscription.
  ///
  /// In en, this message translates to:
  /// **'View subscription'**
  String get viewSubscription;

  /// No description provided for @addPartTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a part'**
  String get addPartTitle;

  /// No description provided for @myCarsTitle.
  ///
  /// In en, this message translates to:
  /// **'My cars'**
  String get myCarsTitle;

  /// No description provided for @noCarsPublished.
  ///
  /// In en, this message translates to:
  /// **'You have no cars published'**
  String get noCarsPublished;

  /// No description provided for @myPartsTitle.
  ///
  /// In en, this message translates to:
  /// **'My parts'**
  String get myPartsTitle;

  /// No description provided for @recommendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedLabel;

  /// No description provided for @priceNotCommunicated.
  ///
  /// In en, this message translates to:
  /// **'Price not disclosed'**
  String get priceNotCommunicated;

  /// No description provided for @noSponsoredCars.
  ///
  /// In en, this message translates to:
  /// **'No sponsored cars.'**
  String get noSponsoredCars;

  /// No description provided for @linkedArticleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Linked item not found for this ad.'**
  String get linkedArticleNotFound;

  /// No description provided for @cannotLoadAdDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to load ad details.'**
  String get cannotLoadAdDetails;

  /// No description provided for @verifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedLabel;

  /// No description provided for @vehiclesPending.
  ///
  /// In en, this message translates to:
  /// **'Pending vehicles'**
  String get vehiclesPending;

  /// No description provided for @noVehiclesPending.
  ///
  /// In en, this message translates to:
  /// **'No vehicles pending validation.'**
  String get noVehiclesPending;

  /// No description provided for @statsForSellersOnly.
  ///
  /// In en, this message translates to:
  /// **'Detailed statistics are reserved for sellers.'**
  String get statsForSellersOnly;

  /// No description provided for @saleCreditsRegistered.
  ///
  /// In en, this message translates to:
  /// **'{count} sale credit(s) recorded'**
  String saleCreditsRegistered(int count);

  /// No description provided for @vehiclesOnlineStat.
  ///
  /// In en, this message translates to:
  /// **'Vehicles online'**
  String get vehiclesOnlineStat;

  /// No description provided for @partsOnlineStat.
  ///
  /// In en, this message translates to:
  /// **'Parts online'**
  String get partsOnlineStat;

  /// No description provided for @vehiclesSoldStat.
  ///
  /// In en, this message translates to:
  /// **'Vehicles sold'**
  String get vehiclesSoldStat;

  /// No description provided for @partsSoldStat.
  ///
  /// In en, this message translates to:
  /// **'Parts sold'**
  String get partsSoldStat;

  /// No description provided for @articlesMarkedSold.
  ///
  /// In en, this message translates to:
  /// **'Items marked sold'**
  String get articlesMarkedSold;

  /// No description provided for @viewsRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded views'**
  String get viewsRecorded;

  /// No description provided for @topVehiclesViews.
  ///
  /// In en, this message translates to:
  /// **'Top vehicles (views)'**
  String get topVehiclesViews;

  /// No description provided for @globalViewsHint.
  ///
  /// In en, this message translates to:
  /// **'Global views will appear here when your vehicles are viewed.'**
  String get globalViewsHint;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @inTransitStatus.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get inTransitStatus;

  /// No description provided for @placeLabel.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get placeLabel;

  /// No description provided for @packageDelivered.
  ///
  /// In en, this message translates to:
  /// **'Package delivered'**
  String get packageDelivered;

  /// No description provided for @arrivalNotified.
  ///
  /// In en, this message translates to:
  /// **'Arrival notified to buyer'**
  String get arrivalNotified;

  /// No description provided for @arrivalError.
  ///
  /// In en, this message translates to:
  /// **'Arrival error: {error}'**
  String arrivalError(String error);

  /// No description provided for @validateOnSiteFirst.
  ///
  /// In en, this message translates to:
  /// **'Confirm \"On site\" at supplier before buyer step.'**
  String get validateOnSiteFirst;

  /// No description provided for @doorToDoor.
  ///
  /// In en, this message translates to:
  /// **'Door to door'**
  String get doorToDoor;

  /// No description provided for @geolocateSupplier.
  ///
  /// In en, this message translates to:
  /// **'Geolocate supplier'**
  String get geolocateSupplier;

  /// No description provided for @geolocateBuyer.
  ///
  /// In en, this message translates to:
  /// **'Geolocate buyer'**
  String get geolocateBuyer;

  /// No description provided for @contactButton.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactButton;

  /// No description provided for @cashOnDeliveryShort.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDeliveryShort;

  /// No description provided for @onSite.
  ///
  /// In en, this message translates to:
  /// **'On site'**
  String get onSite;

  /// No description provided for @finishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finishedLabel;

  /// No description provided for @rejectedTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedTabLabel;

  /// No description provided for @addMultipleImages.
  ///
  /// In en, this message translates to:
  /// **'Add multiple images'**
  String get addMultipleImages;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large: {size}MB (max: 5MB)'**
  String imageTooLarge(String size);

  /// No description provided for @formatNotSupportedExt.
  ///
  /// In en, this message translates to:
  /// **'Unsupported format: {ext}. Formats: {formats}'**
  String formatNotSupportedExt(String ext, String formats);

  /// No description provided for @articleNetworkCreateError.
  ///
  /// In en, this message translates to:
  /// **'Network error creating item: {error}'**
  String articleNetworkCreateError(String error);

  /// No description provided for @searchingAddress.
  ///
  /// In en, this message translates to:
  /// **'Searching address...'**
  String get searchingAddress;

  /// No description provided for @saveProfileError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile.'**
  String get saveProfileError;

  /// No description provided for @backToSettings.
  ///
  /// In en, this message translates to:
  /// **'Back to settings'**
  String get backToSettings;

  /// No description provided for @sellerTypeUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Seller type updated successfully!'**
  String get sellerTypeUpdatedSuccess;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update error: {error}'**
  String updateError(String error);

  /// No description provided for @subscriptionPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful: subscription activated.'**
  String get subscriptionPaymentSuccess;

  /// No description provided for @subscriptionPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment or activation failed.'**
  String get subscriptionPaymentFailed;

  /// No description provided for @deliveryAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delivery accepted successfully!'**
  String get deliveryAcceptedSuccess;

  /// No description provided for @tricycleLoginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'You must sign in to continue.'**
  String get tricycleLoginRequiredTitle;

  /// No description provided for @tricycleLoginRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to order a tricycle.'**
  String get tricycleLoginRequiredSubtitle;

  /// No description provided for @tricycleRequestSentToDriver.
  ///
  /// In en, this message translates to:
  /// **'Request sent to the driver.'**
  String get tricycleRequestSentToDriver;

  /// No description provided for @tricycleRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your request was cancelled.'**
  String get tricycleRequestCancelled;

  /// No description provided for @tricycleCannotCancel.
  ///
  /// In en, this message translates to:
  /// **'Request can no longer be cancelled.'**
  String get tricycleCannotCancel;

  /// No description provided for @tricycleDriverAlreadyAccepted.
  ///
  /// In en, this message translates to:
  /// **'The driver has already accepted the request.'**
  String get tricycleDriverAlreadyAccepted;

  /// No description provided for @tricycleCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to cancel request.'**
  String get tricycleCancelFailed;

  /// No description provided for @tricycleCancelErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}. Please try again.'**
  String tricycleCancelErrorCode(String code);

  /// No description provided for @tricycleCancelError.
  ///
  /// In en, this message translates to:
  /// **'Error during cancellation.'**
  String get tricycleCancelError;

  /// No description provided for @tricycleRequestAcceptedChat.
  ///
  /// In en, this message translates to:
  /// **'Request accepted. You can now chat.'**
  String get tricycleRequestAcceptedChat;

  /// No description provided for @tricycleRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get tricycleRequestRejected;

  /// No description provided for @checkConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get checkConnectionRetry;

  /// No description provided for @pageNotAvailableForRole.
  ///
  /// In en, this message translates to:
  /// **'Page not available for this role'**
  String get pageNotAvailableForRole;

  /// No description provided for @errorDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed error: {error}'**
  String errorDetailed(String error);

  /// No description provided for @videoUploadErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Error uploading video. Please try again.'**
  String get videoUploadErrorRetry;

  /// No description provided for @maxMediaSlots.
  ///
  /// In en, this message translates to:
  /// **'You can select at most {count} media.'**
  String maxMediaSlots(int count);

  /// No description provided for @driverRegistrationFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration form'**
  String get driverRegistrationFormTitle;

  /// No description provided for @imagesNotAllAddedWarning.
  ///
  /// In en, this message translates to:
  /// **'Some images could not be added:'**
  String get imagesNotAllAddedWarning;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart'**
  String get addedToCart;

  /// No description provided for @payOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get payOnline;

  /// No description provided for @orderCommandTotal.
  ///
  /// In en, this message translates to:
  /// **'Order • {total} F'**
  String orderCommandTotal(String total);

  /// No description provided for @registrationSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String registrationSaveError(String error);

  /// No description provided for @purchaseHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase history'**
  String get purchaseHistoryTitle;

  /// No description provided for @purchaseHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle journeys and forwarders'**
  String get purchaseHistorySubtitle;

  /// No description provided for @purchaseHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No purchases in progress yet.'**
  String get purchaseHistoryEmpty;

  /// No description provided for @purchaseHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load purchase history.'**
  String get purchaseHistoryLoadError;

  /// No description provided for @purchaseHistoryChangeForwarder.
  ///
  /// In en, this message translates to:
  /// **'Change forwarder'**
  String get purchaseHistoryChangeForwarder;

  /// No description provided for @purchaseHistoryViewVehicle.
  ///
  /// In en, this message translates to:
  /// **'View vehicle'**
  String get purchaseHistoryViewVehicle;

  /// No description provided for @purchaseHistoryDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase details'**
  String get purchaseHistoryDetailsTitle;

  /// No description provided for @purchaseHistoryForwarderLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected forwarder'**
  String get purchaseHistoryForwarderLabel;

  /// No description provided for @purchaseHistoryNoForwarder.
  ///
  /// In en, this message translates to:
  /// **'No forwarder'**
  String get purchaseHistoryNoForwarder;

  /// No description provided for @purchaseHistoryDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get purchaseHistoryDestinationLabel;

  /// No description provided for @purchaseHistoryModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery mode'**
  String get purchaseHistoryModeLabel;

  /// No description provided for @purchaseHistoryDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get purchaseHistoryDetailsLabel;

  /// No description provided for @purchaseHistoryStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started on {date}'**
  String purchaseHistoryStartedAt(String date);

  /// No description provided for @purchaseStatusParcours.
  ///
  /// In en, this message translates to:
  /// **'In progress — choose forwarder'**
  String get purchaseStatusParcours;

  /// No description provided for @purchaseStatusEnCours.
  ///
  /// In en, this message translates to:
  /// **'Forwarder selected'**
  String get purchaseStatusEnCours;

  /// No description provided for @purchaseStatusTransferer.
  ///
  /// In en, this message translates to:
  /// **'Verification approved'**
  String get purchaseStatusTransferer;

  /// No description provided for @purchaseStatusTraite.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get purchaseStatusTraite;

  /// No description provided for @purchaseStatusAnnule.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled'**
  String get purchaseStatusAnnule;

  /// No description provided for @purchaseModeTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get purchaseModeTransit;

  /// No description provided for @purchaseModeConsommation.
  ///
  /// In en, this message translates to:
  /// **'Local consumption'**
  String get purchaseModeConsommation;

  /// No description provided for @errorTransitaireActif.
  ///
  /// In en, this message translates to:
  /// **'A forwarder is already active for this purchase.'**
  String get errorTransitaireActif;

  /// No description provided for @errorAchatAnnule.
  ///
  /// In en, this message translates to:
  /// **'This purchase was cancelled.'**
  String get errorAchatAnnule;

  /// No description provided for @errorCaptchaInvalid.
  ///
  /// In en, this message translates to:
  /// **'Security check failed. Try again.'**
  String get errorCaptchaInvalid;

  /// No description provided for @errorCaptchaRequired.
  ///
  /// In en, this message translates to:
  /// **'Security check required.'**
  String get errorCaptchaRequired;

  /// No description provided for @errorTransitaireOnly.
  ///
  /// In en, this message translates to:
  /// **'Reserved for forwarders.'**
  String get errorTransitaireOnly;

  /// No description provided for @errorTransitaireVerifAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Your account is already verified.'**
  String get errorTransitaireVerifAlreadyVerified;

  /// No description provided for @errorTransitaireVerifPending.
  ///
  /// In en, this message translates to:
  /// **'A request is already under review (24h processing time).'**
  String get errorTransitaireVerifPending;

  /// No description provided for @errorTransitaireVerifCardsRequired.
  ///
  /// In en, this message translates to:
  /// **'Front and back photos of the forwarder card are required.'**
  String get errorTransitaireVerifCardsRequired;

  /// No description provided for @errorTransitaireVerifCompanyRequired.
  ///
  /// In en, this message translates to:
  /// **'Origin company name and reference phone are required.'**
  String get errorTransitaireVerifCompanyRequired;

  /// No description provided for @errorTransitaireVerifReferencePhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Reference must be a valid phone number.'**
  String get errorTransitaireVerifReferencePhoneInvalid;

  /// No description provided for @errorTransitaireVerifSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification request sent. Review within 24h.'**
  String get errorTransitaireVerifSubmitSuccess;

  /// No description provided for @errorTransitaireVerifSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit verification request.'**
  String get errorTransitaireVerifSubmitFailed;

  /// No description provided for @purchaseForwarderSelected.
  ///
  /// In en, this message translates to:
  /// **'Forwarder updated for this purchase.'**
  String get purchaseForwarderSelected;

  /// No description provided for @viewLess.
  ///
  /// In en, this message translates to:
  /// **'View less'**
  String get viewLess;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
