// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get validate => 'Confirm';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get services => 'Services';

  @override
  String get service_sales_cars => 'Sales (Cars)';

  @override
  String get service_delivery_parts => 'Delivery (Parts)';

  @override
  String get service_tricycle => 'Tricycle';

  @override
  String get tricycle_location_required =>
      'Please enable location to use the Tricycle service.';

  @override
  String get tricycle_permission_denied => 'Location permission denied.';

  @override
  String get tricycle_permission_denied_forever =>
      'Location permission blocked. Enable it in settings.';

  @override
  String get tricycle_position_active_title => 'Location active';

  @override
  String get tricycle_position_active_subtitle =>
      'Location is running… Nearby tricycles will refresh automatically.';

  @override
  String get tricycle_none_nearby => 'No nearby tricycles at the moment.';

  @override
  String get tricycle_out_of_range => 'Out of range';

  @override
  String get retry => 'Retry';

  @override
  String get enable_location => 'Enable location';

  @override
  String get open_settings => 'Open settings';

  @override
  String get refresh => 'Refresh';

  @override
  String get call => 'Call';

  @override
  String get callShort => 'Call';

  @override
  String get message => 'Message';

  @override
  String get tricycle_auth_required => 'Authentication required';

  @override
  String get tricycle_connect_to_see => 'Connect to see';

  @override
  String get tricycle_connect_description =>
      'Please connect your account to view this content';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get understood => 'Got it';

  @override
  String get later => 'Later';

  @override
  String get agree => 'OK';

  @override
  String get submit => 'Submit';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get account => 'Account';

  @override
  String get myAccount => 'My account';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get currency => 'Currency';

  @override
  String get chooseCurrency => 'Choose a currency';

  @override
  String get currencyXof => 'XOF';

  @override
  String get currencyEuro => 'Euro';

  @override
  String get currencyDollars => 'Dollars';

  @override
  String get password => 'Password';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get fullName => 'Full name';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get security => 'Security';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get location => 'Location';

  @override
  String get pieces => 'Parts';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get cars => 'Cars';

  @override
  String get noResults => 'No results';

  @override
  String get fillAllFields => 'Please fill in all fields.';

  @override
  String get networkOrServerError => 'Network or server error.';

  @override
  String get invalidSessionReconnect =>
      'Invalid session. Please sign in again.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get noUserData => 'No user data';

  @override
  String get pleaseSignIn => 'Please sign in';

  @override
  String get addImages => 'Add images';

  @override
  String get filterByBudget => 'Filter by budget';

  @override
  String get minLabel => 'Min.';

  @override
  String get maxLabel => 'Max.';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get deletionError => 'Error during deletion.';

  @override
  String get sendAlert => 'Send alert';

  @override
  String get alertSent => 'Alert sent';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String errorOpening(String error) {
    return 'Error opening: $error';
  }

  @override
  String errorDeletion(String error) {
    return 'Deletion error: $error';
  }

  @override
  String errorPayment(String error) {
    return 'Payment error: $error';
  }

  @override
  String errorNetwork(String error) {
    return 'Network error: $error';
  }

  @override
  String vehiclesAvailableCount(int count) {
    return '$count vehicle(s) available';
  }

  @override
  String partsAvailableCount(int count) {
    return '$count part(s) available';
  }

  @override
  String get signInTitle => 'Sign in';

  @override
  String get welcomeTranoo => 'Welcome to Tranoo';

  @override
  String get welcomeTranooPro => 'Welcome to Tranoo Pro';

  @override
  String get phoneTab => 'Phone number';

  @override
  String get legacyEmailTab => 'Email (legacy account)';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailExample => 'example@mail.com';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get invalidEmailTitle => 'Invalid email';

  @override
  String get legacyEmailSubtitle =>
      'Select « Email » and enter your old address.';

  @override
  String get invalidPhoneTitle => 'Invalid number';

  @override
  String invalidPhoneSubtitle(String hint, String country) {
    return 'Enter $hint for $country.';
  }

  @override
  String get loginSuccessTitle => 'Login successful. Welcome!';

  @override
  String get cannotLoginTitle => 'Unable to sign in with these credentials.';

  @override
  String get noBuyerAccount => 'No buyer account linked to this number.';

  @override
  String get checkCountryCode =>
      'Create an account or verify the country code.';

  @override
  String get wrongPassword => 'Incorrect password.';

  @override
  String get verifyAndRetry => 'Check your information and try again.';

  @override
  String get wrongCredentials => 'Incorrect number, email or password.';

  @override
  String get accountBlocked => 'Your account is temporarily blocked.';

  @override
  String get contactSupport => 'Contact support.';

  @override
  String get tooManyAttempts => 'Too many login attempts.';

  @override
  String get retryInMinutes => 'Try again in a few minutes.';

  @override
  String get cannotReachServer => 'Unable to connect to the server.';

  @override
  String get checkInternet => 'Check your internet connection.';

  @override
  String get serviceTemporaryIssue =>
      'Our service is experiencing a temporary issue.';

  @override
  String get tryAgainLater => 'Please try again later.';

  @override
  String get sessionInitFailed =>
      'Session could not be initialized. Try again.';

  @override
  String get searchCountryOrCode => 'Search a country or code';

  @override
  String get buyerBlockedTitle => 'This app is for buyers only';

  @override
  String get buyerBlockedSubtitle =>
      'Use Tranoo Pro for seller, driver or delivery accounts.';

  @override
  String get noSellerAccount => 'No seller account linked to this number.';

  @override
  String get useTranooForBuyer => 'Use the Tranoo app for buyer accounts.';

  @override
  String get findDreamCar => 'Find your dream car!';

  @override
  String get referralCodeOptional => 'Referral code (optional)';

  @override
  String get referralPlaceholder => 'Ex: TRN-ABCD1234';

  @override
  String get searchCountryCode => 'Search a country code (country or +code)';

  @override
  String get whatsappNumber => 'WhatsApp number';

  @override
  String whatsappHint(String hint) {
    return 'WhatsApp · $hint';
  }

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get retypePassword => 'Retype password';

  @override
  String get passwordMin8 => 'Min. 8 characters';

  @override
  String get missingFieldsTitle => 'Some fields are missing.';

  @override
  String get completeRequiredInfo =>
      'Please complete the required information.';

  @override
  String get passwordMin8Title => 'Password must be at least 8 characters.';

  @override
  String get accountCreatedTitle => 'Your account was created successfully.';

  @override
  String get welcomeTranooExclaim => 'Welcome to Tranoo!';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordMedium => 'Medium';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordVeryStrong => 'Very strong';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get nextStep => 'Next';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get searchCountry => 'Search a country';

  @override
  String get incompleteServerResponse => 'Incomplete server response.';

  @override
  String get retryShortly => 'Try again in a few moments.';

  @override
  String get codeSent => 'Code sent';

  @override
  String get sendCode => 'Send code';

  @override
  String get verifyCodeTitle => 'Verify code';

  @override
  String get missingInfoTitle => 'Missing information.';

  @override
  String get restartFromForgotPassword =>
      'Please start over from the forgot-password page.';

  @override
  String get errorOccurredTitle => 'An error occurred.';

  @override
  String get checkConnectionAndRetry => 'Check your connection and try again.';

  @override
  String get passwordTooShortTitle => 'Password too short.';

  @override
  String passwordMinLength(int count) {
    return 'Minimum $count characters.';
  }

  @override
  String get newPassword => 'New password';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get whatsappNumberWarning =>
      'Use a WhatsApp-reachable number: it will be used for OTP and communication between our team and users.';

  @override
  String phoneDigitsExact(int count) {
    return '$count digits';
  }

  @override
  String phoneDigitsRange(int min, int max) {
    return '$min to $max digits';
  }

  @override
  String passwordStrengthLabel(String label) {
    return 'Password strength: $label';
  }

  @override
  String get stepInfo => 'Information';

  @override
  String get placeholderFirstName => 'John';

  @override
  String get placeholderLastName => 'Doe';

  @override
  String get accountAlreadyExistsTitle =>
      'An account already exists with this number.';

  @override
  String get accountAlreadyExistsSubtitle => 'Sign in or use another number.';

  @override
  String referralCodeRegistered(String status) {
    return 'Referral code saved (status: $status)';
  }

  @override
  String get accountCreatedAgentReferral =>
      'Account created successfully. Agent referral validated.';

  @override
  String get forgotPasswordInstructions =>
      'Choose your country, then enter the national number\n(without repeating the +229 code).\nThe code is sent to the WhatsApp registered on the account.';

  @override
  String get enterYourPhone => 'Enter your number';

  @override
  String invalidPhoneWithHint(String hint) {
    return 'Invalid number ($hint)';
  }

  @override
  String get forgotPasswordBeninHint =>
      'E.g. for +229: enter 593XXXXXXX (8 digits), not 01593XXXXXXX or +229 prefix.';

  @override
  String forgotPasswordNationalHint(String code) {
    return 'Enter only the national number; country code $code is already selected.';
  }

  @override
  String get accountNotFoundForNumber => 'No account found for this number.';

  @override
  String get useSameWhatsappAsSignup =>
      'Use the same WhatsApp number as at sign-up (without 0 after +229).';

  @override
  String get errorTokenMissing => 'Missing or invalid token.';

  @override
  String get errorTokenInvalid => 'Invalid token.';

  @override
  String get errorUserNotFound => 'User not found. Please sign in again.';

  @override
  String get errorAccountBlocked =>
      'Your account has been blocked. Contact support.';

  @override
  String get errorSessionRequired =>
      'Web session required. Please sign in again.';

  @override
  String get errorSessionRevoked =>
      'Your session was opened elsewhere. Sign in again.';

  @override
  String get errorSessionInactive =>
      'Session expired due to inactivity. Please sign in again.';

  @override
  String get errorInvalidPhone =>
      'Invalid number. Check country code and number.';

  @override
  String get errorAppRequired => 'App required (tranoo or tranoo_pro).';

  @override
  String get errorAccountAmbiguous =>
      'Multiple accounts share this number. Contact support.';

  @override
  String get errorAccountNotFound => 'No account found for this number.';

  @override
  String get errorOtpSendFailed =>
      'Unable to send code. Check the number or try again.';

  @override
  String get errorMissingFields => 'Required fields missing.';

  @override
  String get errorOtpInvalidOrExpired => 'Invalid or expired code.';

  @override
  String get errorDeviceMismatch => 'This phone does not match the request.';

  @override
  String get errorRequestInvalid => 'Invalid request.';

  @override
  String get errorOtpExpired => 'Code expired. Request a new code.';

  @override
  String get errorOtpLocked => 'Too many attempts. Request a new code.';

  @override
  String get errorOtpIncorrect => 'Incorrect code.';

  @override
  String get errorVerifyFirst => 'Please verify the code first.';

  @override
  String get errorPasswordTooShort => 'Password too short.';

  @override
  String get errorPasswordUpdateFailed =>
      'Unable to update password. Contact support.';

  @override
  String get errorInternalError => 'Error. Please try again.';

  @override
  String get errorValidationError => 'Invalid data.';

  @override
  String get errorConnectionFailed => 'Connection error.';

  @override
  String get errorEnterPhoneNumber => 'Please enter your number.';

  @override
  String get codeSentWhatsappDefault =>
      'Code sent via WhatsApp to your account number.';

  @override
  String get enterCodePlease => 'Please enter the code';

  @override
  String get otpMustBe6Digits => 'The code must be 6 digits';

  @override
  String get invalidCode => 'Invalid code.';

  @override
  String verifyCodeBanner(int minutes) {
    return 'Enter the 6-digit code.\nValid for $minutes min. Check the Tranoo notification or WhatsApp on the account number.';
  }

  @override
  String get save => 'Save';

  @override
  String get passwordChangedSuccess => 'Password changed successfully.';

  @override
  String get connectSupport => 'Contact support';

  @override
  String get cannotOpenWhatsApp => 'Unable to open WhatsApp.';

  @override
  String get installWhatsAppRetry => 'Install WhatsApp and try again.';

  @override
  String get preferences => 'Preferences';

  @override
  String get geolocation => 'Geolocation';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get pushNotificationsSubtitle => 'Receive push notifications';

  @override
  String get locationTracking => 'Location tracking';

  @override
  String get shareRealtimeLocation => 'Share your real-time location';

  @override
  String get cfaFranc => 'CFA Franc';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get createAccountToContinue => 'Create an account to continue.';

  @override
  String get actionRequired => 'Action required';

  @override
  String get uploadProfilePhotoRequired =>
      'Please upload your profile photo to continue.';

  @override
  String get proBuyerBlockedTitle => 'Buyer account not allowed on Tranoo Pro';

  @override
  String get proBuyerBlockedSubtitle => 'Buyers use the Tranoo app.';

  @override
  String get thisCountry => 'this country';

  @override
  String get passwordDotsHint => '••••••••';

  @override
  String get continueButton => 'Continue';

  @override
  String get locationRequired => 'Location required';

  @override
  String get authorizationRequired => 'Authorization required';

  @override
  String get whatWeUse => 'What we use:';

  @override
  String get locationBackgroundWarning =>
      'Location is used even when the app is in the background for continuous tracking.';

  @override
  String get backgroundLocationTitle => 'Background location';

  @override
  String get backgroundLocationMessage =>
      'To ensure continuous tracking of your missions, we need access to your location even when the app is in the background.\n\nYou can enable this permission in your device settings.';

  @override
  String get deviceSettings => 'Settings';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String locationRequiredForRole(String role) {
    return 'Location is required to use $role features. Some features may be limited.';
  }

  @override
  String permissionRequestError(String error) {
    return 'An error occurred while requesting permission: $error';
  }

  @override
  String get welcomeTranooProExclaim => 'Welcome to Tranoo Pro!';

  @override
  String get locationAuthorization => 'Location authorization';

  @override
  String get locationUsageIntro =>
      'For proper operation, Tranoo Pro uses your location to:';

  @override
  String get locationBackgroundServicesWarning =>
      'Location may be used even when the app is in the background to ensure continuous service tracking.';

  @override
  String get changeDecisionLaterInSettings =>
      'You can change this decision later in settings';

  @override
  String get authorizeLocationInSettings => 'Allow location in settings.';

  @override
  String get cannotGetPosition => 'Unable to get position.';

  @override
  String get yourCurrentPosition => 'Your current position';

  @override
  String get positionUsageForListings =>
      'Used for your listings and supplier location. You can update it in your profile.';

  @override
  String get saveCurrentPosition => 'Save my current position';

  @override
  String get refreshPosition => 'Refresh position';

  @override
  String get positionSavedGps => 'Position saved (GPS coordinates)';

  @override
  String get profilePositionUpdated => 'Profile position updated';

  @override
  String get savePositionToContinue =>
      'Save your current position to continue.';

  @override
  String get saveYourCurrentPosition => 'Save your current position.';

  @override
  String get sellerUpdateTitle => 'Seller update';

  @override
  String get sellerTypeChoiceIntro =>
      'Tranoo Pro now lets you choose your seller type: vehicles, spare parts or mixed.';

  @override
  String get sellerTypeChoiceHint =>
      'Make your choice on the dedicated page to adapt your menus and listings.';

  @override
  String get makeChoice => 'Make a choice';

  @override
  String get professionalAccess => 'Professional access';

  @override
  String useAlternativeAppForProfessionalRole(String app) {
    return 'Use $app instead for your professional role';
  }

  @override
  String subscriptionExpiresIn(int days) {
    return 'Your subscription expires in $days day(s).';
  }

  @override
  String freeTrialEndsIn(int days) {
    return 'Your free trial ends in $days day(s).';
  }

  @override
  String currentPlanLabel(String plan) {
    return 'Current plan: $plan';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get manageSubscription => 'Manage my subscription';

  @override
  String get historyLast10 => 'History (last 10)';

  @override
  String get noSubscriptionPayments => 'No subscription payments yet.';

  @override
  String get serverTimeout =>
      'The server is taking too long to respond. Try again shortly.';

  @override
  String get cannotReachServerDetailed =>
      'Unable to reach the server. Check your connection and backend URL.';

  @override
  String get accountDeletionFailed =>
      'Account deletion failed. Try again later.';

  @override
  String get unexpectedDeletionError =>
      'An unexpected error occurred during deletion.';

  @override
  String get myPurchases => 'My purchases';

  @override
  String get myPurchasesSubtitle => 'View your order history';

  @override
  String get myReviews => 'My reviews';

  @override
  String get myReviewsSubtitle => 'View or edit your comments';

  @override
  String get myInvoices => 'My invoices';

  @override
  String get myInvoicesSubtitle => 'Download your purchase receipts';

  @override
  String get accountCreatedSuccess => 'Account created successfully.';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get address => 'Address';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get addDeliveryNote => 'Add a delivery note';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get packageLabel => 'Package';

  @override
  String get packagesToDeliver => 'Packages to deliver';

  @override
  String get orderLabel => 'Order';

  @override
  String get qrContent => 'QR content';

  @override
  String get carDescription => 'Car description';

  @override
  String get becomeCertifiedDriver => 'Become a certified driver';

  @override
  String get adDuration => 'Ad duration';

  @override
  String get inDelivery => 'In delivery';

  @override
  String get inTransit => 'In transit';

  @override
  String get enterCompanyName => 'Enter company name';

  @override
  String get enterVehicleName => 'Enter vehicle name';

  @override
  String get enterCarDescriptionOptional =>
      'Enter a description of your car (optional)';

  @override
  String get enterClientDestination => 'Enter client destination';

  @override
  String get enterBrand => 'Enter brand';

  @override
  String get enterModel => 'Enter model';

  @override
  String get enterCustomModel => 'Enter custom model';

  @override
  String get enterDestinationDetails =>
      'Enter your destination details here...';

  @override
  String get engineDisplacementExample => 'E.g. 1600 or 1.6';

  @override
  String get requirements => 'Requirements';

  @override
  String get supplier => 'Supplier';

  @override
  String get supplierToBuyer => 'Supplier -> Buyer';

  @override
  String get deliveryEarnings => 'Delivery earnings';

  @override
  String get vehicleInfoRequired =>
      'Registration, type, brand and model are required.';

  @override
  String get vehicleInfoMissing => 'Vehicle information missing.';

  @override
  String get mileageHint => 'Mileage (km), e.g. 12500 or 12.5';

  @override
  String get externalLinkOptional => 'External link (optional)';

  @override
  String get partOrCarName => 'Part/car name';

  @override
  String get nameOnCard => 'Name on card';

  @override
  String get seatCount => 'Number of seats';

  @override
  String get notProvided => 'Not provided';

  @override
  String get notificationDefault => 'Notification';

  @override
  String get orderNumber => 'Order number';

  @override
  String get cashPayment => 'Cash payment';

  @override
  String get positionRequired => 'Position required';

  @override
  String get priceFcfa => 'Price (FCFA)';

  @override
  String get priceFcfaExample => 'Price in FCFA (e.g. 1500000 or 1,500,000.5)';

  @override
  String get offerDeliveryServices => 'Offer delivery services';

  @override
  String get specifyModel => 'Specify model';

  @override
  String get searchCarHint => 'Search for a car (brand, model, title)...';

  @override
  String get summary => 'Summary';

  @override
  String get roleLabel => 'Role';

  @override
  String get titleLabel => 'Title';

  @override
  String get typeLabel => 'Type';

  @override
  String get engineType => 'Engine type';

  @override
  String get adType => 'Ad type';

  @override
  String get engineTypeShort => 'Engine';

  @override
  String get toBuyer => 'To buyer';

  @override
  String get toSupplier => 'To supplier';

  @override
  String get pleaseEnterCompany => 'Please enter your company.';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get conditionLabel => 'Condition';

  @override
  String get buyer => 'Buyer';

  @override
  String get positionGpsSaved => 'GPS position saved';

  @override
  String get enterLink => 'Enter link';

  @override
  String get passwordSuperStrong => 'Super strong';

  @override
  String get onboardingTagline1 =>
      'Tranoo\nFind your parts and\nvehicles quickly';

  @override
  String get onboardingTagline2 =>
      'Discover your\nideal vehicle in\na few clicks';

  @override
  String get accountDeletion => 'Account deletion';

  @override
  String get accountDeletionIrreversible => 'This action is irreversible.';

  @override
  String get accountDeletionDataWarning =>
      'Your account, app access and related data will be deleted.';

  @override
  String get accountDeletionConfirmWarning =>
      'Make sure you no longer need this account before confirming.';

  @override
  String get editAccountSubtitle => 'Make changes to your account';

  @override
  String get referral => 'Referral';

  @override
  String get referralSubtitle => 'Earn by referring friends';

  @override
  String get sellMyCar => 'Sell my car';

  @override
  String get sellMyPart => 'Sell my part';

  @override
  String get becomeSellerSubtitle => 'Become a seller and sell with us';

  @override
  String get sellerAccessOnly => 'Access reserved for sellers.';

  @override
  String get transitaireAccessOnly => 'Access reserved for freight forwarders.';

  @override
  String get transitHistory => 'Transit history';

  @override
  String get user => 'User';

  @override
  String get userNotConnected => 'User not signed in';

  @override
  String get newAlertDefault => 'New alert';

  @override
  String get buyerSearchingPart => 'A buyer is looking for a part.';

  @override
  String get buyerSearchingVehicle => 'A buyer is looking for a vehicle.';

  @override
  String get characteristics => 'Characteristics:';

  @override
  String get noCharacteristicsProvided => '- No characteristics provided';

  @override
  String get proposeOffer => 'Propose an offer';

  @override
  String get myCart => 'My Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Add items to start shopping';

  @override
  String get checkout => 'Place order';

  @override
  String get carsOnline => 'Cars online';

  @override
  String get carDeletedSuccess => 'Car deleted successfully!';

  @override
  String get newCondition => 'New';

  @override
  String get usedCondition => 'Used';

  @override
  String get budgetFcfa => 'Budget (FCFA)';

  @override
  String get spareParts => 'Spare parts';

  @override
  String get confirmDeletePart => 'Do you really want to delete this part?';

  @override
  String get partDeletedSuccess => 'Part deleted successfully!';

  @override
  String get searchPartHint => 'Search for a part...';

  @override
  String get searchVehiclesPartsHint => 'Search vehicles, parts...';

  @override
  String get deliveries => 'Deliveries';

  @override
  String get tricycles => 'Tricycles';

  @override
  String get fillMiniForm => 'Fill mini form';

  @override
  String get discussions => 'Discussions';

  @override
  String get noDiscussions => 'No discussions';

  @override
  String get startDiscussionWithSeller => 'Start a discussion with a seller';

  @override
  String get typeMessageHint => 'Type your message...';

  @override
  String get messageSendError => 'Error sending message';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get notificationDetails => 'Notification details';

  @override
  String get myOrders => 'My orders';

  @override
  String get noOrders => 'No orders';

  @override
  String get orderDetails => 'Order details';

  @override
  String get orderTracking => 'Order tracking';

  @override
  String get filterAll => 'All';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get myWallet => 'My wallet';

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String get transactions => 'Transactions';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get paymentSuccessful => 'Payment successful!';

  @override
  String get paymentFailed => 'Payment failed';

  @override
  String get pay => 'Pay';

  @override
  String get payNow => 'Pay now';

  @override
  String get returnToApp => 'Return to app';

  @override
  String get wooHoo => 'Woo hoo!!';

  @override
  String get goToHome => 'Go to home';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get publishedOnline => 'Published online!';

  @override
  String get returnHome => 'Return home';

  @override
  String get referralTitle => 'Referral';

  @override
  String get referralLinkCopied => 'Referral link copied!';

  @override
  String get copyLink => 'Copy link';

  @override
  String get yourStats => 'Your statistics';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get chooseLocation => 'Choose location';

  @override
  String get navigate => 'Navigate';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get livreurHome => 'Delivery home';

  @override
  String get chauffeurHome => 'Driver home';

  @override
  String get myDeliveries => 'My deliveries';

  @override
  String get sellerSubscription => 'Seller subscription';

  @override
  String get premiumSubscription => 'Premium subscription';

  @override
  String get subscribeNow => 'Subscribe now';

  @override
  String get sellerWallet => 'Seller wallet';

  @override
  String get more => 'More';

  @override
  String get signInForProfile => 'Sign in to access your profile';

  @override
  String get profileLoadError =>
      'Unable to load profile. Check your connection or permissions.';

  @override
  String get profileSaveError => 'Error saving profile';

  @override
  String get company => 'Company';

  @override
  String get country => 'Country';

  @override
  String get gender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get saving => 'Saving...';

  @override
  String get updateProfile => 'Update profile';

  @override
  String get profileUpdateError => 'Error during update';

  @override
  String get restrictedAccess => 'Restricted access';

  @override
  String roleNotAllowedOnApp(String role, String app) {
    return 'Your role ($role) is not allowed on $app';
  }

  @override
  String useAlternativeAppForRole(String app) {
    return 'Use $app instead for your role';
  }

  @override
  String get googlePlay => 'Google Play';

  @override
  String get appStore => 'App Store';

  @override
  String get alertNotificationsTitle => 'Alert notifications';

  @override
  String get alertNotificationsDescription =>
      'Allow notifications to be alerted when a seller responds to your alert, even when the app is in the background.';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get referralLinkTitle => 'Your referral link';

  @override
  String get referralShareTitle => 'Share your referral link';

  @override
  String get others => 'Others';

  @override
  String get total => 'Total';

  @override
  String get yourReferrals => 'Your referrals';

  @override
  String get noReferralsYet => 'No referrals yet';

  @override
  String get shareReferralHint =>
      'Share your code with friends to get started!';

  @override
  String referralShareMessage(String link) {
    return '🚗 Join me on Tranoo!\n\nDownload the app via my referral link: $link\n\nTogether, let\'s find the best cars and spare parts! 🚙✨';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String serverError(String status, String message) {
    return 'Server error: $status - $message';
  }

  @override
  String alertLabelBrand(String value) {
    return 'Brand: $value';
  }

  @override
  String alertLabelModel(String value) {
    return 'Model: $value';
  }

  @override
  String alertLabelCondition(String value) {
    return 'Condition: $value';
  }

  @override
  String alertLabelYear(String value) {
    return 'Year: $value';
  }

  @override
  String alertLabelYearMin(String value) {
    return 'Min year: $value';
  }

  @override
  String alertLabelYearMax(String value) {
    return 'Max year: $value';
  }

  @override
  String alertLabelBudgetMax(String value) {
    return 'Max budget: $value FCFA';
  }

  @override
  String alertLabelPart(String value) {
    return 'Part: $value';
  }

  @override
  String alertLabelUrgency(String value) {
    return 'Urgency: $value';
  }

  @override
  String alertLabelLocation(String value) {
    return 'Location: $value';
  }

  @override
  String alertLabelDetails(String value) {
    return 'Details: $value';
  }

  @override
  String get confirmDeleteCar => 'Do you really want to delete this car?';

  @override
  String get vehicleBrandLabel => 'Vehicle brand';

  @override
  String get partNameLabel => 'Part name';

  @override
  String get urgencyLow => 'Low';

  @override
  String get urgencyNormal => 'Normal';

  @override
  String get urgencyHigh => 'Urgent';

  @override
  String alertSendError(String error) {
    return 'Alert send error: $error';
  }

  @override
  String get searchTypeTitle => 'Search type';

  @override
  String get whatDoYouWantToSearch => 'What do you want to search?';

  @override
  String get noArticleLinkedToAd => 'No item linked to this ad.';

  @override
  String get sellerPhoneUnavailable => 'Seller phone number unavailable';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get requestValidatedWhatsApp => 'Request approved — opening WhatsApp';

  @override
  String get requestRejected => 'Request rejected';

  @override
  String errorActionStatus(int status) {
    return 'Action error: $status';
  }

  @override
  String get notificationsLoadError => 'Error loading notifications';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get markedAsUnread => 'Marked as unread';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get confirmDeleteNotification => 'Delete this notification?';

  @override
  String get orderSummary => 'Summary';

  @override
  String get selectAddress => 'Select an address';

  @override
  String get direction => 'Directions';

  @override
  String get track => 'Track';

  @override
  String get orderPayment => 'Order payment';

  @override
  String get preparingPayment => 'Preparing payment...';

  @override
  String get noActiveOrderToTrack => 'No active order to track';

  @override
  String get ordersLoadError => 'Error loading orders';

  @override
  String get orderRegisteredDeliverySoon =>
      'Your order is registered. A driver will take charge of delivery soon.';

  @override
  String get driverAssignedTrackRealtime =>
      'Driver assigned. Track their position in real time.';

  @override
  String get returnPackage => 'Return package';

  @override
  String get pickupMyOrder => 'Pick up my order';

  @override
  String get deliveryNotFound => 'Delivery not found.';

  @override
  String get orderPickedUpSuccess => 'Order picked up successfully.';

  @override
  String pickupError(String error) {
    return 'Pickup error: $error';
  }

  @override
  String get returnReasonHint => 'E.g. wrong part, defect, model error…';

  @override
  String get send => 'Send';

  @override
  String get reasonRequired => 'Reason required.';

  @override
  String get returnReportedPaymentRequired =>
      'Return reported. Delivery fee payment required.';

  @override
  String returnError(String error) {
    return 'Return error: $error';
  }

  @override
  String get paymentInterrupted => 'Payment interrupted';

  @override
  String get paymentInterruptedMessage =>
      'You left the payment screen or the transaction was not completed.';

  @override
  String get paymentInterruptedSubtitle =>
      'No charge recorded. You can try again anytime.';

  @override
  String get paymentErrorMessage => 'An error occurred during the transaction.';

  @override
  String get paymentErrorRetrySupport => 'Please try again or contact support.';

  @override
  String get transactionSuccessMessage =>
      'Your transaction was completed successfully.';

  @override
  String get closePageReturnToApp =>
      'You can now close this page and return to the app.';

  @override
  String get selectToChoose => 'Select';

  @override
  String get bankPayment => 'Bank payment';

  @override
  String get mobileMoney => 'Mobile Money';

  @override
  String get paymentSuccessUpdatingStatus =>
      'Payment successful! Updating status...';

  @override
  String get adPaidSuccess => 'Ad paid successfully!';

  @override
  String get subscriptionActivatedSuccess =>
      'Subscription activated successfully!';

  @override
  String get redirecting => 'Redirecting...';

  @override
  String get verifyPayment => 'Verify payment';

  @override
  String get finalizePayment => 'Finalize payment';

  @override
  String get purchaseSuccessMessage =>
      'Dear customer, your purchase was successful. ';

  @override
  String get purchaseSuccessDelivery =>
      'Your product will be delivered within 5 days at most. Thank you for your trust!';

  @override
  String get articleCreatedPendingValidation =>
      'Well done! You created your listing. It is pending validation.';

  @override
  String get almostThere => 'Almost there';

  @override
  String get spotlightCostPrefix => 'Your spotlight will cost about ';

  @override
  String get spotlightCostSuffix =>
      ' for this vehicle. Continue and complete payment to see your vehicle at the top of our listings.';

  @override
  String get saleSuccessTitle => 'Sale successful!';

  @override
  String get publishedSuccessMessage => 'Your listing is now online!';

  @override
  String get yourBalanceIs => 'Your balance is:';

  @override
  String get entry => 'Credit';

  @override
  String get makeWithdrawal => 'Make a withdrawal';

  @override
  String get transferAccount => 'Transfer account';

  @override
  String get cardNumber => 'Card number';

  @override
  String get month => 'Month';

  @override
  String get securityCode => 'Card security code';

  @override
  String get codeHint => 'Code';

  @override
  String get requestWithdrawal => 'Request withdrawal';

  @override
  String get myWithdrawals => 'My withdrawals';

  @override
  String get withdrawalRequest => 'Withdrawal request';

  @override
  String get noMessage => 'No message';

  @override
  String get articleDefault => 'Item';

  @override
  String get justNow => 'Just now';

  @override
  String get recent => 'Recent';

  @override
  String get errorSendingImage => 'Error sending image';

  @override
  String get errorSendingDocument => 'Error sending document';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get openingDocument => 'Opening document...';

  @override
  String get myTransits => 'My transits';

  @override
  String get noArticlesInCategory => 'No items in this category';

  @override
  String get discussionCreationError => 'Error creating discussion';

  @override
  String get articleWithoutId => 'Item without ID';

  @override
  String get contactTransitaire => 'Contact forwarder';

  @override
  String get finalizePurchase => 'Complete purchase';

  @override
  String get chosenForwarderRate => 'Selected forwarder rate';

  @override
  String get additionalFees => 'Additional fees';

  @override
  String get totalPrice => 'Total price';

  @override
  String get downloadInvoice => 'Download invoice';

  @override
  String get chooseFormat => 'Choose format:';

  @override
  String get imageFormat => 'Image';

  @override
  String get documentFormat => 'Document';

  @override
  String get imageGallery => 'Image (Gallery)';

  @override
  String get chooseDownloadFormat => 'Choose download format:';

  @override
  String get preparingShare => 'Preparing share...';

  @override
  String get invoiceReadyToShare => 'Invoice ready to share!';

  @override
  String shareError(String error) {
    return 'Share error: $error';
  }

  @override
  String get maxImagesReached => 'Maximum of 12 images reached';

  @override
  String get videoUploadedSuccess => 'Video uploaded successfully!';

  @override
  String get waitUploadFinish => 'Please wait for upload to finish.';

  @override
  String get addAtLeastOneMedia => 'Please add at least one image or video.';

  @override
  String get fillRequiredFields => 'Please fill in all required fields.';

  @override
  String get enterTitle => 'Enter title';

  @override
  String get enterYear => 'Enter year (e.g. 2020)';

  @override
  String get enterCylinder => 'Enter cylinder (e.g. 1600)';

  @override
  String get enterDistance => 'Enter distance (km)';

  @override
  String get enterSeats => 'Enter number of seats';

  @override
  String get enterPrice => 'Enter price';

  @override
  String get enterCarDescription => 'Enter a description of your car';

  @override
  String get uploadInProgress => 'Upload in progress...';

  @override
  String get publishListing => 'Publish listing';

  @override
  String get uploadImageFailed => 'Image upload failed.';

  @override
  String get noImageSelected => 'No image selected.';

  @override
  String get newOffer => 'New offer';

  @override
  String get selectAtLeastOneImage => 'Please select at least one image.';

  @override
  String get fillCarFields => 'Please fill in all car fields.';

  @override
  String get requestCreationError => 'Error creating request.';

  @override
  String get statusUpdateError => 'Error updating status.';

  @override
  String get clickableLinkOptional => 'Clickable link (optional)';

  @override
  String get itemName => 'Part/car name';

  @override
  String get companyName => 'Company name';

  @override
  String get locationServicesDisabled => 'Location services are disabled';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission permanently denied';

  @override
  String get confirmThisLocation => 'Confirm this location';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get drivingLicense => 'Driving license';

  @override
  String get yourMessage => 'Your message';

  @override
  String get submitApplication => 'Submit application';

  @override
  String get applicationSubmitted => 'Application submitted successfully!';

  @override
  String get applicationSubmitError => 'Error submitting application.';

  @override
  String get vendreTitle => 'Sell';

  @override
  String get quantity => 'Quantity';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get buyNow => 'Buy now';

  @override
  String get contactSeller => 'Contact seller';

  @override
  String get views => 'Views';

  @override
  String get status => 'Status';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get details => 'Details';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get seeAll => 'See all';

  @override
  String get noData => 'No data';

  @override
  String get errorLoading => 'Loading error';

  @override
  String get continueAction => 'Continue';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get orderStatus => 'Order status';

  @override
  String get orderDate => 'Order date';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get processing => 'Processing...';

  @override
  String get errorUserNotConnected => 'Error: User not signed in';

  @override
  String get adPaymentSuccessMessage =>
      'Your payment was completed successfully! ';

  @override
  String get adPaymentSuccessHighlight =>
      'Your listing will be featured once validated by our team. You will receive a confirmation notification.';

  @override
  String get preparing => 'Preparing...';

  @override
  String get listingPublishedVisiblePrefix =>
      'Your listing is published and visible ';

  @override
  String get immediately => 'immediately';

  @override
  String get listingPublishedVisibleSuffix =>
      ' on the app.\n\nYou can already find it in the listings.';

  @override
  String get listingAlreadyOnline => 'Your listing is already online.';

  @override
  String get noVehicleSearchResultHint =>
      'No car matches your search.\nCreate a mini alert to be contacted quickly.';

  @override
  String get noPartSearchResultHint =>
      'No part matches your search.\nCreate a mini alert to be contacted quickly.';

  @override
  String get priceFcfaLabel => 'Price (FCFA)';

  @override
  String get vehicleAlert => 'Vehicle alert';

  @override
  String get partAlert => 'Part alert';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get vehicleCondition => 'Vehicle condition';

  @override
  String get brandRequired => 'Brand required';

  @override
  String get modelRequired => 'Model required';

  @override
  String get yearRequired => 'Year required';

  @override
  String get budgetRequired => 'Budget required';

  @override
  String get alertRegisteredFeedback =>
      'Your request has been registered. You will hear back from sellers very soon.';

  @override
  String get whatsappOpenDetailed =>
      'Unable to open WhatsApp. Check that the app or a browser is installed on your phone.';

  @override
  String get noVideoAvailable => 'No video available';

  @override
  String get cannotMakeCall => 'Unable to make a call';

  @override
  String get cylinder => 'Cylinder';

  @override
  String get fuel => 'Fuel';

  @override
  String get airConditioner => 'Air conditioning';

  @override
  String get distanceKm => 'Distance';

  @override
  String get seats => 'Seats';

  @override
  String get doors => 'Doors';

  @override
  String get gearbox => 'Gearbox';

  @override
  String get customsClearance => 'Customs clearance';

  @override
  String get inConsumption => 'For consumption';

  @override
  String get chooseCountry => 'Choose a country';

  @override
  String get additionalDetails => 'Additional details';

  @override
  String get signInForVerification => 'Sign in to request verification';

  @override
  String get signInForDelivery => 'Sign in to order with delivery';

  @override
  String get signInToBuyThisCar => 'Sign in to buy this car';

  @override
  String get chooseDeliveryMode =>
      'Please choose a delivery mode (For consumption or In transit).';

  @override
  String get selectLocationPlease => 'Please select a location.';

  @override
  String get verificationInProgress => 'Verification in progress';

  @override
  String get verificationChecksPrefix =>
      'Checks will be performed and sent to you within ';

  @override
  String get tenBusinessDays => '10 days';

  @override
  String get verificationChecksMiddle => '. To start, please pay the ';

  @override
  String get verificationFeesLabel => 'verification fees';

  @override
  String get payVerificationFees => 'Pay verification fees';

  @override
  String get requestVerification => 'Request verification';

  @override
  String get buyThisCar => 'Buy this car';

  @override
  String get sampleCarDescription =>
      'The Tesla Model 3 is a mid-size electric sedan known for impressive performance, acceleration and range.';

  @override
  String get chooseCondition => 'Choose condition';

  @override
  String get chooseBrand => 'Choose brand';

  @override
  String get chooseModel => 'Choose model';

  @override
  String get chooseDoorCount => 'Choose number of doors';

  @override
  String get chooseGearbox => 'Choose gearbox';

  @override
  String get chooseFuel => 'Choose fuel';

  @override
  String get chooseAirConditioner => 'Choose air conditioning';

  @override
  String get brandsLabel => 'Brands';

  @override
  String get doorSingular => 'Door';

  @override
  String get seatSingular => 'Seat';

  @override
  String selectedColorLabel(String color) {
    return 'Selected color: $color';
  }

  @override
  String get companyBlOwner => 'Company name on bill of lading';

  @override
  String get imagesOptionalMax12 => 'Images (optional, max 12)';

  @override
  String get videoOptionalMax500 => 'Video (optional, max 500 MB)';

  @override
  String get addImagesButton => 'Add images';

  @override
  String get videoReady => 'Video ready';

  @override
  String mediaSlot(int index) {
    return 'Slot $index';
  }

  @override
  String get tapToAddVideo => 'Tap to add';

  @override
  String get sending => 'Sending...';

  @override
  String videoTooHeavy(String size) {
    return 'Video is too large ($size MB). Limit: 500 MB.';
  }

  @override
  String get videoUploadError => 'Error uploading video. Please try again.';

  @override
  String maxMediaCount(int count) {
    return 'You can select at most $count media items.';
  }

  @override
  String get manualTransmission => 'Manual';

  @override
  String get automaticTransmission => 'Automatic';

  @override
  String get petrol => 'Petrol';

  @override
  String get diesel => 'Diesel';

  @override
  String get electric => 'Electric';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get otherOption => 'Other';

  @override
  String get pieceName => 'Part name';

  @override
  String get enterYearShort => 'Enter year';

  @override
  String get placement => 'Location';

  @override
  String get enterPartDescription => 'Enter a description of your part';

  @override
  String get verificationAction => 'Verification';

  @override
  String uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String videoUploadFailed(String error) {
    return 'Video upload failed: $error';
  }

  @override
  String selectedModelLabel(String model) {
    return 'Selected model: $model';
  }

  @override
  String customModelLabel(String model) {
    return 'Custom model: $model';
  }

  @override
  String get enterEngineType => 'Enter engine type';

  @override
  String get noEngine => 'None';

  @override
  String get gazoil => 'Gas oil';

  @override
  String get addVideo => 'Add a video';

  @override
  String get videoUploadedLabel => 'Video uploaded';

  @override
  String get beforeContactSeller => 'Before contacting the seller';

  @override
  String get contactSellerTips =>
      '• Confirm price and any fees\n• Check location and availability\n• Discuss item condition clearly\n• Prefer a safe place for the transaction';

  @override
  String get orderWithDelivery => 'Order with delivery';

  @override
  String get buyViaApp => 'Buy via the app';

  @override
  String get secureOrderViaCart =>
      'Secure order via Tranoo cart (delivery available).';

  @override
  String get partTypeLabel => 'Part type';

  @override
  String get ratingOutOf5 => '0 / 5';

  @override
  String get mastervacSampleDescription =>
      'Essential braking component, the brake booster amplifies pedal force to make braking easier.';

  @override
  String get rare => 'Rare';

  @override
  String get sellYourPart => 'Sell your part';

  @override
  String get newBadge => 'New';

  @override
  String get createAd => 'Create an ad';

  @override
  String get adRequest => 'Ad request';

  @override
  String get standaloneAd => 'Standalone ad';

  @override
  String get existingArticleAd => 'Existing item ad';

  @override
  String get standaloneAdDesc =>
      'Standalone featured ad. Upload a flyer (1080 x 1350 px recommended) and add an optional link to your site or catalog.';

  @override
  String get nonExistingPubDesc =>
      'Non-existing listing. You are creating a new offer. Users can tap to see your offer details.';

  @override
  String get existingArticlePubDesc =>
      'You are creating an ad for an existing item. Users can tap to see the full item.';

  @override
  String get loadingArticleInfo => 'Loading item information...';

  @override
  String get articleLoadedSuccess =>
      'Item loaded successfully! You can now advertise this item.';

  @override
  String get linkExampleHint =>
      'E.g. https://wa.me/2250700000000 or https://my-site.com';

  @override
  String get linkHelperText =>
      'Let users open your site, catalog or payment form.';

  @override
  String get selectAdType => 'Please select a type';

  @override
  String get selectDuration => 'Please select a duration';

  @override
  String get sponsoredType => 'Sponsored';

  @override
  String get featuredType => 'Featured';

  @override
  String get oneWeek => '1 week';

  @override
  String get twoWeeks => '2 weeks';

  @override
  String get oneMonth => '1 month';

  @override
  String get twoMonths => '2 months';

  @override
  String get threeMonths => '3 months';

  @override
  String pricePerDayLabel(String price) {
    return '$price/day';
  }

  @override
  String get carInfoSection => 'Vehicle information';

  @override
  String get enterName => 'Please enter the name';

  @override
  String get enterYearValidator => 'Please enter the year';

  @override
  String get enterLocationValidator => 'Please enter the location';

  @override
  String get enterPriceValidator => 'Please enter the price';

  @override
  String get enterDescriptionValidator => 'Please enter a description';

  @override
  String get enterCompanyValidator => 'Please enter the company name';

  @override
  String get selectEngineTypeValidator => 'Please select engine type';

  @override
  String get selectModelValidator => 'Please select the model';

  @override
  String get selectTypeValidator => 'Please select the type';

  @override
  String get mainFlyerImage => 'Main image (flyer)';

  @override
  String get recommendedDimensions =>
      'Recommended dimensions: 1080 x 1350 px (PNG/JPG)';

  @override
  String get addMainImage => 'Add main image';

  @override
  String get dimensions1080x1350 => '1080 x 1350 px';

  @override
  String get additionalImagesOptional => 'Additional images (optional)';

  @override
  String get standaloneFeaturedTitle => 'Featured ad';

  @override
  String get standaloneFeaturedDesc =>
      'Dedicated flyer, no existing item needed. Just add your visual and (optionally) an external link.';

  @override
  String get addMainImageForFeatured =>
      'Please add a main image for \"Featured\".';

  @override
  String get articleCreateError => 'Error creating item.';

  @override
  String articleCreateNetworkError(String error) {
    return 'Network error while creating item: $error';
  }

  @override
  String get articleLoadError => 'Error loading item';

  @override
  String get articleLoadNetworkError => 'Network error while loading item';

  @override
  String mediaUploadError(String error) {
    return 'Error uploading media: $error';
  }

  @override
  String get fillAllFieldsShort => 'Please fill in all fields.';

  @override
  String get articleNotExistCreateFirst =>
      'This item does not exist. Please create it and after admin validation you can feature it.';

  @override
  String get articleNotExistFeaturedFirst =>
      'This item does not exist. For \"Featured\" ads, create the item first and after admin validation you can feature it.';

  @override
  String get articleCreateRetryError =>
      'Error creating item. Please try again.';

  @override
  String get paymentSuccessPendingValidation =>
      'Payment successful, pending admin validation. You will receive a notification once approved.';

  @override
  String pubForTitle(String title) {
    return 'Ad for $title';
  }

  @override
  String get noDescriptionAd => 'Ad without description';

  @override
  String get defaultCarName => 'Car name';

  @override
  String get defaultLocation => 'Location';

  @override
  String get defaultPrice => 'Price';

  @override
  String get defaultCarDescription => 'Car description';

  @override
  String get defaultCompanyName => 'Company name';

  @override
  String get defaultBrand => 'Brand';

  @override
  String get standaloneFeaturedDescriptionDefault =>
      'Featured ad (Tranoo storefront flyer)';

  @override
  String get perMonth => 'per month';

  @override
  String get boostVisibilitySubtitle => 'Boost your visibility with clients';

  @override
  String get premiumBenefits => 'Premium benefits';

  @override
  String get prioritySpotlight => 'Priority spotlight';

  @override
  String get prioritySpotlightDesc => 'Appear first in search results';

  @override
  String get premiumBadge => 'Premium badge';

  @override
  String get premiumBadgeDesc => 'Gold badge visible on your profile';

  @override
  String get boostedVisibility => 'Boosted visibility';

  @override
  String get boostedVisibilityDesc => 'More clients contact you';

  @override
  String get prioritySupport => 'Priority support';

  @override
  String get prioritySupportDesc => 'Dedicated assistance 24/7';

  @override
  String get monthlySubscription => 'Monthly subscription';

  @override
  String get subscriptionAutoRenewNote =>
      'Your subscription renews automatically each month. You can cancel anytime.';

  @override
  String subscribeNowPrice(String price) {
    return 'Subscribe now - $price FCFA';
  }

  @override
  String get userNotLoggedIn => 'User not signed in';

  @override
  String get feexpayConfigMissing => 'FeexPay configuration missing';

  @override
  String get feexpayConfigMissingDetailed =>
      'FeexPay configuration missing (FP_TOKEN_FEEXPAY / ID_USER_FEEXPAY)';

  @override
  String get verificationFeesTitle => 'Verification fees';

  @override
  String get documentVerification => 'Document verification';

  @override
  String get verifyDocumentsAuthenticity =>
      'Verify the authenticity of your documents';

  @override
  String get includedServices => 'Included services';

  @override
  String get fullVerification => 'Full verification';

  @override
  String get fullVerificationDesc => 'Review of all your official documents';

  @override
  String get fastProcessing => 'Fast processing';

  @override
  String get fastProcessingDesc => 'Results within 10 business days';

  @override
  String get oneTimePayment => 'one-time payment';

  @override
  String get verificationPaymentNote =>
      'After payment, you will receive a summary and checks will be completed within 10 business days.';

  @override
  String proceedToPayment(String price) {
    return 'Proceed to payment - $price FCFA';
  }

  @override
  String get paymentReceivedIncompleteRecord =>
      'Payment received but server record incomplete. Retry or contact support.';

  @override
  String get paymentReceivedVerificationProcessing =>
      'Payment received. Your verification request is being processed.';

  @override
  String get paymentCancelledNotConfirmed =>
      'Payment cancelled or not confirmed. Try again if needed.';

  @override
  String get cannotLoadData => 'Unable to load data';

  @override
  String get recommendedForwarders => 'Recommended forwarders';

  @override
  String get seeMoreForwarders => 'See more forwarders';

  @override
  String get forwarderPremiumBadge => 'Premium subscriber';

  @override
  String get forwarderVerifiedBadge => 'Verified';

  @override
  String get forwarderStandardBadge => 'Forwarder';

  @override
  String get internationalTransit => 'International transit';

  @override
  String get noForwardersAvailable => 'No forwarders available';

  @override
  String get forwarderSubscribedShort => 'Subscribed';

  @override
  String get forwarderStandardShort => 'Standard';

  @override
  String get forwardersTitle => 'Forwarders';

  @override
  String get forwarderTabStarred => 'Starred';

  @override
  String get forwarderTabAll => 'All';

  @override
  String get viewProfile => 'View profile';

  @override
  String galleryMediaCount(int count) {
    return '$count media';
  }

  @override
  String subscribedSince(String date) {
    return 'Subscribed since $date';
  }

  @override
  String get noStarredForwarders => 'No starred forwarders.';

  @override
  String get transitaireProfileTabGallery => 'Gallery';

  @override
  String get transitaireGalleryEmpty => 'No photos or videos at the moment.';

  @override
  String get transitaireGalleryEmptyOwner => 'Tap + to add photos or videos.';

  @override
  String get transitaireGalleryAddTitle => 'Add to gallery';

  @override
  String get transitaireGalleryPhotosMulti => 'Photos (one or more)';

  @override
  String get transitaireGalleryVideo => 'Video';

  @override
  String get transitaireGalleryUploadingPhotos => 'Sending photos…';

  @override
  String get transitaireGalleryUploadingVideo => 'Sending video…';

  @override
  String get transitaireGalleryUploadFailed => 'Upload failed. Try again.';

  @override
  String get transitaireGallerySaveError => 'Error saving gallery.';

  @override
  String get transitaireGalleryUploadError => 'Upload error.';

  @override
  String get transitaireGalleryDeleteTitle => 'Delete?';

  @override
  String get transitaireGalleryDeleteConfirm =>
      'Remove this item from the gallery?';

  @override
  String get transitaireGalleryDeleteFailed => 'Unable to delete.';

  @override
  String transitaireGalleryMaxItems(int count) {
    return 'Limit of $count items reached.';
  }

  @override
  String get videoPlaybackError => 'Unable to play video';

  @override
  String get contactPhoneUnavailable => 'Contact number unavailable.';

  @override
  String get transitaireDefaultName => 'Forwarder';

  @override
  String get transitaireServicesSubtitle => 'International transit services';

  @override
  String get transitaireDescriptionLabel => 'Description (optional)';

  @override
  String get transitaireDescriptionHint => 'Describe your transit services…';

  @override
  String get transitaireBadgeLabel => 'Forwarder';

  @override
  String get westAfricaDefault => 'West Africa';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get myProfile => 'My profile';

  @override
  String get actions => 'Actions';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get filterTypeTab => 'Type';

  @override
  String get filterBrandTab => 'Brand';

  @override
  String get filterLocationTab => 'Location';

  @override
  String get pieceTypeSpareParts => 'Spare parts';

  @override
  String get pieceTypeTires => 'Tires';

  @override
  String get pieceTypeOils => 'Oils and lubricants';

  @override
  String get pieceTypeBatteries => 'Batteries';

  @override
  String get pieceTypeAccessories => 'Accessories';

  @override
  String get forwarderSubscription => 'Forwarder subscription';

  @override
  String get activateMonthlySubscription =>
      'Activate a monthly subscription to be featured to buyers.';

  @override
  String pricePerMonth(String price) {
    return '$price FCFA / month';
  }

  @override
  String activatedOn(String date) {
    return 'Activated on: $date';
  }

  @override
  String expiresOn(String date) {
    return 'Expires on: $date';
  }

  @override
  String get manage => 'Manage';

  @override
  String get visibility => 'Visibility';

  @override
  String get boosted => 'Boosted';

  @override
  String get spotlight => 'Spotlight';

  @override
  String get subscriptionStatus => 'Subscription status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get noActiveSubscription => 'No active subscription';

  @override
  String get performances => 'Performance';

  @override
  String get ordersDeliveredPerMonth => 'Orders delivered / month';

  @override
  String get clientDistribution => 'Client distribution';

  @override
  String get chartBuyers => 'Buyers';

  @override
  String get chartDrivers => 'Drivers';

  @override
  String get chartOthers => 'Others';

  @override
  String get discuss => 'Discuss';

  @override
  String priceWithValue(String price) {
    return 'Price: $price';
  }

  @override
  String get priceNotSpecified => 'Not specified';

  @override
  String get sellerInfoError => 'Error: Unable to retrieve seller information';

  @override
  String get transitHistoryTitle => 'Transit history';

  @override
  String clientLabel(String name) {
    return 'Client: $name';
  }

  @override
  String departurePortLabel(String port) {
    return 'Departure port: $port';
  }

  @override
  String arrivalPortLabel(String port) {
    return 'Arrival port: $port';
  }

  @override
  String transitDateLabel(String date) {
    return 'Transit date: $date';
  }

  @override
  String statusWithValue(String status) {
    return 'Status: $status';
  }

  @override
  String get deliveredSuccessfully => 'Delivered successfully';

  @override
  String get atCustoms => 'At customs';

  @override
  String get billOfLading => 'Bill of lading';

  @override
  String get proformaInvoice => 'Pro forma invoice';

  @override
  String get transitCertificate => 'Transit certificate';

  @override
  String get partialCustomsCertificate =>
      'Partial customs clearance certificate';

  @override
  String get inspectionCertificate => 'Inspection certificate';

  @override
  String get transitFormTitle => 'Transit forms';

  @override
  String get carNameLabel => 'Car name';

  @override
  String get clientField => 'Client';

  @override
  String get departurePort => 'Departure port';

  @override
  String get arrivalPort => 'Arrival port';

  @override
  String get transitDate => 'Transit date';

  @override
  String get uploadDocuments => 'Upload documents';

  @override
  String get registrationForm => 'Registration form';

  @override
  String get familyName => 'Last name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get enterYourFirstName => 'Enter your first name';

  @override
  String get typeYourPhone => 'Enter your phone number';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get licenseNumber => 'License number';

  @override
  String get enterLicenseNumber => 'Enter your license number';

  @override
  String get messages => 'Messages';

  @override
  String get writeYourMessage => 'Write your message';

  @override
  String get uploadImagesLabel => 'Upload images';

  @override
  String get myLicensePdf => 'My license PDF';

  @override
  String get fillFieldsAndUploadLicense =>
      'Please fill in all required fields and upload your license.';

  @override
  String get requestSentSuccess => 'Request sent successfully!';

  @override
  String sendErrorWithBody(String body) {
    return 'Error sending: $body';
  }

  @override
  String timeAgoDays(int count) {
    return '$count day(s) ago';
  }

  @override
  String timeAgoHours(int count) {
    return '${count}h ago';
  }

  @override
  String timeAgoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String get checkingPermissions => 'Checking permissions...';

  @override
  String get redirectingIfNeeded => 'Redirecting if necessary';

  @override
  String get unauthorizedAccess => 'Unauthorized access';

  @override
  String get tricycle_home_title => 'Tricycles';

  @override
  String get tricycle_request_accepted => 'Request accepted';

  @override
  String get tricycle_request_sent => 'Request sent';

  @override
  String get tricycle_order_command => 'Order · Tricycle';

  @override
  String get feexpayPaymentTitle => 'FeexPay payment';

  @override
  String get feexpayInitSuccess => 'FeexPay service initialized successfully';

  @override
  String feexpayInitError(String error) {
    return 'Initialization error: $error';
  }

  @override
  String get paymentInitSuccess => 'Payment initialized successfully!';

  @override
  String get cannotOpenPaymentPage => 'Unable to open payment page';

  @override
  String get transactionDetailsTitle => 'Transaction details';

  @override
  String get labelTransactionId => 'Transaction ID';

  @override
  String valueAmountFcfa(String amount) {
    return '$amount FCFA';
  }

  @override
  String get enterAmount => 'Please enter the amount';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get amountMustBePositive => 'Amount must be greater than 0';

  @override
  String get enterDescriptionRequired => 'Please enter a description';

  @override
  String get enterOrderId => 'Please enter an order ID';

  @override
  String get commandIdLabel => 'Order ID';

  @override
  String get paymentTypeLabel => 'Payment type';

  @override
  String get mobileMoneyProviders => 'Mobile Money (MTN, Moov, Orange)';

  @override
  String get bankCardPayment => 'Bank card (VISA, Mastercard)';

  @override
  String get feexpayWallet => 'FeexPay wallet';

  @override
  String get initializeFeexpay => 'Initialize FeexPay';

  @override
  String get aboutFeexpay => 'About FeexPay';

  @override
  String get feexpayAboutDescription =>
      'FeexPay is a secure payment aggregator that accepts:';

  @override
  String get feexpayAcceptedMethods =>
      '• MTN Mobile Money, Moov Money, Orange Money\n• VISA and Mastercard cards\n• Digital wallets';

  @override
  String get feexpayTransactionsTitle => 'FeexPay transactions';

  @override
  String transactionsLoadError(String error) {
    return 'Error loading: $error';
  }

  @override
  String get processRefundTitle => 'Process a refund';

  @override
  String transactionWithId(String id) {
    return 'Transaction: $id';
  }

  @override
  String get refundAmountFcfa => 'Refund amount (FCFA)';

  @override
  String get refundReason => 'Refund reason';

  @override
  String get refundAction => 'Refund';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get refundSuccess => 'Refund completed successfully';

  @override
  String get transactionHistory => 'Transaction history';

  @override
  String transactionCount(int count) {
    return '$count transaction(s)';
  }

  @override
  String get accountBalanceLabel => 'Account balance';

  @override
  String currencyWithValue(String currency) {
    return 'Currency: $currency';
  }

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get transactionsEmptyHint =>
      'Transactions will appear here after your first payments';

  @override
  String get transactionNoDescription => 'Transaction without description';

  @override
  String idWithValue(String id) {
    return 'ID: $id';
  }

  @override
  String dateWithValue(String date) {
    return 'Date: $date';
  }

  @override
  String methodWithValue(String method) {
    return 'Method: $method';
  }

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get customerEmailLabel => 'Customer email';

  @override
  String get accountBlockedTitle => 'Account blocked';

  @override
  String get accountBlockedDialogMessage =>
      'You cannot access the app because an administrator has temporarily blocked you.';

  @override
  String get contactSupportTeam =>
      'Contact the support team for more information.';

  @override
  String get driverArrivedTitle => 'Your delivery driver has arrived';

  @override
  String get chooseAnAction => 'Choose an action.';

  @override
  String get orderTotalLabel => 'Order total';

  @override
  String get deliveryFeesLabel => 'Delivery fee';

  @override
  String get payMyOrder => 'Pay my order';

  @override
  String get returnReasonRequiredTitle => 'Return reason (required)';

  @override
  String get partsOrderPaymentLabel => 'Parts order payment';

  @override
  String get deliveryFeePaymentLabel => 'Delivery fee payment';

  @override
  String get fileDownloadFailed => 'Unable to download the file';

  @override
  String get tranooDocumentShare => 'Tranoo document';

  @override
  String refWithId(String id) {
    return 'Ref. $id';
  }

  @override
  String get attachedImages => 'Attached images';

  @override
  String get attachedDocuments => 'Attached documents';

  @override
  String get stampAndSignature => 'Stamp and signature';

  @override
  String get reject => 'Reject';

  @override
  String get downloadReportPdf => 'Download PDF report';

  @override
  String imageWithIndex(int index) {
    return 'Image $index';
  }

  @override
  String documentWithIndex(int index) {
    return 'Document $index';
  }

  @override
  String get buyerAlert => 'Buyer alert';

  @override
  String get swipeUpOrTap => 'Swipe up or tap';

  @override
  String get decline => 'Decline';

  @override
  String get answer => 'Answer';

  @override
  String get newAlertTitle => 'New alert';

  @override
  String get sellerRespondedToAlert => 'A seller responded to your alert';

  @override
  String get videoAvailable => 'Video available';

  @override
  String get withdrawalProcessingMessage =>
      'Your request is being processed and you will receive confirmation once the withdrawal is complete. If you have questions or wish to modify your request, contact us. Thank you for your trust.';

  @override
  String get departurePortField => 'Departure port';

  @override
  String get arrivalPortField => 'Arrival port';

  @override
  String get transitDateField => 'Transit date';

  @override
  String get carNameExample => 'Toyota Corolla 2018';

  @override
  String get clientExample => 'Marcel T';

  @override
  String get departurePortExample => 'Antwerp, Belgium';

  @override
  String get arrivalPortExample => 'Cotonou, Benin';

  @override
  String get transitDateExample => 'April 10, 2025';

  @override
  String timeAgoMinutesLong(int count) {
    return '$count minutes ago';
  }

  @override
  String notificationsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String confirmDeleteNotificationsCount(int count) {
    return 'Delete $count notification(s)?';
  }

  @override
  String get newRequest => 'New request';

  @override
  String budgetAmountFcfa(String amount) {
    return 'Budget $amount FCFA';
  }

  @override
  String get alertProposalForYourAlert => 'Offer for your alert';

  @override
  String whatsappInterestWithRef(String title, String articleId) {
    return 'Hello Tranoo, I confirm my interest in purchasing: $title (ref. $articleId).';
  }

  @override
  String whatsappInterestNoRef(String title) {
    return 'Hello Tranoo, I confirm my interest in purchasing: $title.';
  }

  @override
  String get defaultVehicleTitle => 'vehicle';

  @override
  String get cannotLoadOrders => 'Unable to load your orders';

  @override
  String get noOrdersYetHint => 'You haven\'t placed any orders yet';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get filterTracking => 'Tracking';

  @override
  String get finishedOrdersHiddenHint =>
      'Completed or cancelled orders do not appear here';

  @override
  String orderCmdNumber(String id) {
    return 'CMD #$id';
  }

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusDelivering => 'Delivering';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusDriverAssigned => 'Driver assigned';

  @override
  String get tranooDelivery => 'Tranoo Delivery';

  @override
  String get driverLabel => 'Driver';

  @override
  String get addressNotSpecified => 'Address not specified';

  @override
  String quantityLabel(int qty) {
    return 'Qty: x$qty';
  }

  @override
  String get deliveryDetails => 'Delivery details';

  @override
  String get driverAssignmentPending => 'Assignment in progress';

  @override
  String get defaultLocationCotonou => 'Cotonou, Benin';

  @override
  String apiErrorWithDetails(String status, String details) {
    return 'API error ($status): $details';
  }

  @override
  String get monthJan => 'JAN';

  @override
  String get monthFeb => 'FEB';

  @override
  String get monthMar => 'MAR';

  @override
  String get monthApr => 'APR';

  @override
  String get monthMay => 'MAY';

  @override
  String get monthJun => 'JUN';

  @override
  String get monthJul => 'JUL';

  @override
  String get monthAug => 'AUG';

  @override
  String get monthSep => 'SEP';

  @override
  String get monthOct => 'OCT';

  @override
  String get monthNov => 'NOV';

  @override
  String get monthDec => 'DEC';

  @override
  String get fetchingLocation => 'Fetching...';

  @override
  String get fetchMyLocation => 'Use my location';

  @override
  String get chooseOnMap => 'Choose on map';

  @override
  String get currentPositionLabel => 'Current position';

  @override
  String get selectedPositionLabel => 'Selected position';

  @override
  String coordinatesLabel(String lat, String lng) {
    return 'Lat: $lat\nLon: $lng';
  }

  @override
  String get availability => 'Availability';

  @override
  String get deliveryFeeLabel => 'Delivery fee';

  @override
  String get processingOrder => 'Processing...';

  @override
  String get supplierCoordsUnavailable =>
      'Supplier coordinates unavailable to calculate delivery.';

  @override
  String get invalidCoordinates => 'Invalid coordinates';

  @override
  String get selectionCancelled => 'Selection cancelled';

  @override
  String mapSelectionError(String error) {
    return 'Map selection error: $error';
  }

  @override
  String get locationRetrievedSuccess =>
      'Current position retrieved successfully!';

  @override
  String get deliveryAddressSelectedOnMap =>
      'Delivery address selected on the map!';

  @override
  String get enableLocationInSettingsMsg => 'Enable location in settings';

  @override
  String locationError(String error) {
    return 'Location error: $error';
  }

  @override
  String get invalidDeliveryAddress => 'Invalid delivery address';

  @override
  String get selectDeliveryAddressPlease => 'Please select a delivery address';

  @override
  String get confirmYourOrder => 'Confirm your order';

  @override
  String totalToPay(String amount) {
    return 'Total to pay: $amount F';
  }

  @override
  String get transactionFailedNotSaved =>
      'Transaction failed/cancelled. Order not saved.';

  @override
  String get orderConfirmedTitle => 'Order confirmed!';

  @override
  String get orderSavedSuccess => 'Your order was saved successfully.';

  @override
  String get deliveryExpected => 'Expected delivery';

  @override
  String get deliveryBetween3And7Days => 'Within 3 to 7 business days';

  @override
  String get youWillReceiveNotification => 'You will receive a notification';

  @override
  String get availAvailable => 'Available';

  @override
  String get avail15to30min => 'In 15-30 min';

  @override
  String get avail1to2h => 'In 1-2h';

  @override
  String get availBefore12 => 'Before 12pm';

  @override
  String get availBefore18 => 'Before 6pm';

  @override
  String get availBefore20 => 'Before 8pm';

  @override
  String get availFlexible => 'Flexible';

  @override
  String get supplierDefault => 'Supplier';

  @override
  String get supplierAddressDefault => 'Supplier address';

  @override
  String orderSaveError(String error) {
    return 'Error saving order: $error';
  }

  @override
  String positionCoords(String lat, String lng) {
    return 'Position: $lat, $lng';
  }

  @override
  String get orderPaymentTranooDescription => 'Tranoo order payment';

  @override
  String get mobileMoneyPayment => 'Mobile Money payment';

  @override
  String get adDetailsTitle => 'Your ad details';

  @override
  String get amountToPay => 'Amount to pay';

  @override
  String get viaMobileMoney => 'via Mobile Money';

  @override
  String get supportedOperators => 'Supported operators';

  @override
  String get afterPaymentAdValidationNote =>
      'After payment, your ad will be submitted for admin validation before publication.';

  @override
  String payAmountFcfa(String amount) {
    return 'Pay $amount FCFA';
  }

  @override
  String get adForYourListing => 'Ad for your listing';

  @override
  String adPaymentMobileDescription(String pubId) {
    return 'Ad payment (mobile money) $pubId';
  }

  @override
  String get durationLabel => 'Duration';

  @override
  String get invoicesLoadError => 'Unable to load invoices';

  @override
  String get signInForInvoices => 'Sign in to access your invoices';

  @override
  String get noInvoicesYet => 'You have no invoices yet.';

  @override
  String get unreadLabel => 'Unread';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get filterAllDates => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisWeek => 'This week';

  @override
  String get filterThisMonth => 'This month';

  @override
  String get filterCustom => 'Custom';

  @override
  String selectedDateLabel(String date) {
    return 'Selected date: $date';
  }

  @override
  String get invoicePreview => 'Invoice preview';

  @override
  String get transactionSuccessTitle => 'Transaction success';

  @override
  String transactionNumber(String ref) {
    return 'Transaction number $ref';
  }

  @override
  String get dateTimeLabel => 'Date & time';

  @override
  String get productLabel => 'Product';

  @override
  String get sellerLabel => 'Seller';

  @override
  String get shopLabel => 'Shop';

  @override
  String get fundsSourceLabel => 'Funding source';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get referenceLabel => 'Reference';

  @override
  String get productDetails => 'Product details:';

  @override
  String get productPriceLabel => 'Product price';

  @override
  String get deliveryPriceLabel => 'Delivery price';

  @override
  String get vatLabel => 'VAT';

  @override
  String get totalTransaction => 'Total transaction';

  @override
  String get tranooSupport => 'Tranoo support';

  @override
  String get thankYouForTrust => 'Thank you for your trust ';

  @override
  String get officialInvoiceDisclaimer =>
      'This invoice is an official document. In case of dispute, please contact our support.';

  @override
  String get saveInvoiceImage => 'Save invoice (image)';

  @override
  String get saveInvoiceDocument => 'Save invoice (document)';

  @override
  String get imageSavedSuccess => 'Image saved successfully';

  @override
  String get imageSaveFailed => 'Failed to save image';

  @override
  String get documentSavedSuccess => 'PDF document saved successfully';

  @override
  String get documentSaveFailed => 'Failed to save PDF document';

  @override
  String get captureUnavailable => 'Capture unavailable';

  @override
  String get imageGenerationFailed => 'Unable to generate image';

  @override
  String get paidStatus => 'Paid';

  @override
  String get pendingPaymentStatus => 'Pending';

  @override
  String get sellerDefault => 'Seller';

  @override
  String get shopDefault => 'Shop';

  @override
  String invoiceTitle(String number) {
    return 'INVOICE $number';
  }

  @override
  String get purchasesLoadError => 'Error loading purchases';

  @override
  String purchaseStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String deliveryDateLabel(String date) {
    return 'Delivery date: $date';
  }

  @override
  String deliveryLocationLabel(String location) {
    return 'Delivery location: $location';
  }

  @override
  String fuelTypeLabel(String type) {
    return 'Fuel type: $type';
  }

  @override
  String colorLabel(String color) {
    return 'Color: $color';
  }

  @override
  String publishedOn(String date) {
    return 'Published on $date';
  }

  @override
  String ratingOutOf(int rating) {
    return '$rating/5';
  }

  @override
  String get minutesAgo2 => '2 min ago';

  @override
  String get inProgressStatus => 'In progress';

  @override
  String get yearDropdown => 'Year';

  @override
  String get cardPlaceholderName => 'John Doe';

  @override
  String get cardNumberPlaceholder => '0000 0000 0000 0000';

  @override
  String paymentFormFor(String name) {
    return 'Payment form for $name';
  }

  @override
  String partNameLabelShort(String name) {
    return 'Part name: $name';
  }

  @override
  String get untitled => 'Untitled';

  @override
  String get unknownCompany => 'Unknown company';

  @override
  String get piecesLoadError => 'Error loading parts';

  @override
  String get carsLoadError => 'Error loading cars';

  @override
  String get adsLoadError => 'Error loading ads';

  @override
  String get dataFormatError => 'Data format error';

  @override
  String get filterModelsTab => 'Models';

  @override
  String get filterBudgetTab => 'Budget';

  @override
  String get noCarsAvailable => 'No cars available at the moment.';

  @override
  String get noPartsAvailableOnline => 'No parts online at the moment';

  @override
  String get noCarsOnlineSeller => 'You have no cars online';

  @override
  String get noPartsOnlineSeller => 'You have no parts online at the moment';

  @override
  String doorsCountLabel(String count) {
    return '$count doors';
  }

  @override
  String get sponsoredLabel => 'Sponsored';

  @override
  String get chooseTypeTitle => 'Choose type';

  @override
  String youTyped(String text) {
    return 'You typed: \"$text\"';
  }

  @override
  String get whatArticleTypeSearch => 'What type of item are you looking for?';

  @override
  String get vehicleSingular => 'Vehicle';

  @override
  String get partSingular => 'Part';

  @override
  String get unknownArticleType => 'Unknown item type.';

  @override
  String get urgencyLevel => 'Urgency level';

  @override
  String get partNameRequired => 'Part name required';

  @override
  String showVehiclesCount(int count) {
    return 'Show $count vehicle(s)';
  }

  @override
  String get buyerSearchingPartShort => 'A buyer is looking for a part';

  @override
  String get buyerSearchingVehicleShort => 'A buyer is looking for a vehicle';

  @override
  String get validateLocation => 'Confirm';

  @override
  String get colorField => 'Color';

  @override
  String get pubRequestCreateError => 'Error creating request.';

  @override
  String get videoOptional => 'Video (optional)';

  @override
  String get viewListing => 'View listing';

  @override
  String get enlarge => 'Enlarge';

  @override
  String get networkError => 'Network error';

  @override
  String get cannotGenerateImage => 'Unable to generate image';

  @override
  String get errorLoadingArticle => 'Error loading item.';

  @override
  String get conditionNew => 'New';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get budgetMinHint => 'Min budget';

  @override
  String get budgetMaxHint => 'Max budget';

  @override
  String get addressLabel => 'Address';

  @override
  String get tvaLabel => 'VAT';

  @override
  String get deliveryLabelShort => 'Delivery';

  @override
  String get totalLabelShort => 'Total';

  @override
  String get articleLabel => 'Item';

  @override
  String get urgencyLabel => 'Urgency';

  @override
  String invoicesLoadErrorDetail(String status, String message) {
    return 'Unable to load invoices ($status): $message';
  }

  @override
  String get verifyProPermissions => 'Verifying professional permissions...';

  @override
  String get advertisingLabel => 'Advertising';

  @override
  String get sellerTypeLabel => 'Seller type';

  @override
  String get deliveryToLabel => 'Deliver to';

  @override
  String get cashLabel => 'Cash';

  @override
  String get onlineLabel => 'Online';

  @override
  String placeOrderButton(String total) {
    return 'Order • $total F';
  }

  @override
  String get cashOnDeliveryTitle => 'Cash on delivery';

  @override
  String get cashOnDeliveryChosen => 'You chose cash on delivery.';

  @override
  String get cashOnDeliveryBilled =>
      'You will be charged when you receive your order.';

  @override
  String get previewLabel => 'Preview';

  @override
  String get changesSaved => 'Changes saved.';

  @override
  String saveErrorStatus(String status) {
    return 'Save error: $status';
  }

  @override
  String saveErrorGeneric(String error) {
    return 'Save error: $error';
  }

  @override
  String get itemAddedToCart => 'Item added to cart';

  @override
  String get modifyPart => 'Edit part';

  @override
  String get someImagesNotAdded => 'Some images could not be added:';

  @override
  String imagesAddedSuccess(int count) {
    return '$count image(s) added successfully';
  }

  @override
  String unsupportedFormat(String formats) {
    return 'Unsupported format. Accepted: $formats';
  }

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String phoneWithNumber(String number) {
    return 'Phone $number';
  }

  @override
  String get phoneNotProvided => 'Phone not provided — complete your profile';

  @override
  String get locationMissingProfile =>
      'Location missing — update your position in profile.';

  @override
  String get profileContactLocationHint =>
      'Phone and location from sign-up. Update your profile if needed.';

  @override
  String get vehicleLocationLabel => 'Vehicle location';

  @override
  String get profileLocationReuse =>
      'Uses your registered sign-up position (profile).';

  @override
  String get noProfileLocation =>
      'No profile location — update your position in Profile.';

  @override
  String get descriptionNotProvided => 'Description not provided';

  @override
  String get mileageLabel => 'Mileage';

  @override
  String get maxImages12 => 'Maximum of 12 images reached';

  @override
  String get maxImages10 => 'Maximum of 10 images reached';

  @override
  String cameraError(String error) {
    return 'Camera error: $error';
  }

  @override
  String selectionError(String error) {
    return 'Selection error: $error';
  }

  @override
  String imageAdded(String name) {
    return 'Image added: $name';
  }

  @override
  String imageUploaded(String name) {
    return 'Image uploaded: $name';
  }

  @override
  String uploadError(String error) {
    return 'Upload error: $error';
  }

  @override
  String errorDetail(String error) {
    return 'Detailed error: $error';
  }

  @override
  String get verificationDetailTitle => 'Verification details';

  @override
  String get recipientLabel => 'Recipient';

  @override
  String get cannotOpenDocument => 'Unable to open document';

  @override
  String get featureNoLongerAvailable => 'This feature is no longer available';

  @override
  String get articleNotFound => 'Item not found';

  @override
  String get sessionExpiredReconnect => 'Session expired. Sign in again.';

  @override
  String get cannotLoadProposal => 'Unable to load proposal.';

  @override
  String get searchDetails => 'Search details';

  @override
  String get proposeOfferButton => 'Propose an offer';

  @override
  String get specialPromotion => 'Special promotion';

  @override
  String get viewProposal => 'View proposal';

  @override
  String get partSearched => 'Part searched';

  @override
  String get articleNotFoundVerification => 'Item not found for verification';

  @override
  String get noUserForNotifications =>
      'No signed-in user. Cannot load notifications.';

  @override
  String get verifySubscriptionPlan => 'Unable to verify subscription plan.';

  @override
  String get viewSubscription => 'View subscription';

  @override
  String get addPartTitle => 'Add a part';

  @override
  String get myCarsTitle => 'My cars';

  @override
  String get noCarsPublished => 'You have no cars published';

  @override
  String get myPartsTitle => 'My parts';

  @override
  String get recommendedLabel => 'Recommended';

  @override
  String get priceNotCommunicated => 'Price not disclosed';

  @override
  String get noSponsoredCars => 'No sponsored cars.';

  @override
  String get linkedArticleNotFound => 'Linked item not found for this ad.';

  @override
  String get cannotLoadAdDetails => 'Unable to load ad details.';

  @override
  String get verifiedLabel => 'Verified';

  @override
  String get vehiclesPending => 'Pending vehicles';

  @override
  String get noVehiclesPending => 'No vehicles pending validation.';

  @override
  String get statsForSellersOnly =>
      'Detailed statistics are reserved for sellers.';

  @override
  String saleCreditsRegistered(int count) {
    return '$count sale credit(s) recorded';
  }

  @override
  String get vehiclesOnlineStat => 'Vehicles online';

  @override
  String get partsOnlineStat => 'Parts online';

  @override
  String get vehiclesSoldStat => 'Vehicles sold';

  @override
  String get partsSoldStat => 'Parts sold';

  @override
  String get articlesMarkedSold => 'Items marked sold';

  @override
  String get viewsRecorded => 'Recorded views';

  @override
  String get topVehiclesViews => 'Top vehicles (views)';

  @override
  String get globalViewsHint =>
      'Global views will appear here when your vehicles are viewed.';

  @override
  String get activities => 'Activities';

  @override
  String get inTransitStatus => 'In transit';

  @override
  String get placeLabel => 'Place';

  @override
  String get packageDelivered => 'Package delivered';

  @override
  String get arrivalNotified => 'Arrival notified to buyer';

  @override
  String arrivalError(String error) {
    return 'Arrival error: $error';
  }

  @override
  String get validateOnSiteFirst =>
      'Confirm \"On site\" at supplier before buyer step.';

  @override
  String get doorToDoor => 'Door to door';

  @override
  String get geolocateSupplier => 'Geolocate supplier';

  @override
  String get geolocateBuyer => 'Geolocate buyer';

  @override
  String get contactButton => 'Contact';

  @override
  String get cashOnDeliveryShort => 'Cash on delivery';

  @override
  String get onSite => 'On site';

  @override
  String get finishedLabel => 'Finished';

  @override
  String get rejectedTabLabel => 'Rejected';

  @override
  String get addMultipleImages => 'Add multiple images';

  @override
  String imageTooLarge(String size) {
    return 'Image too large: ${size}MB (max: 5MB)';
  }

  @override
  String formatNotSupportedExt(String ext, String formats) {
    return 'Unsupported format: $ext. Formats: $formats';
  }

  @override
  String articleNetworkCreateError(String error) {
    return 'Network error creating item: $error';
  }

  @override
  String get searchingAddress => 'Searching address...';

  @override
  String get saveProfileError => 'Error updating profile.';

  @override
  String get backToSettings => 'Back to settings';

  @override
  String get sellerTypeUpdatedSuccess => 'Seller type updated successfully!';

  @override
  String updateError(String error) {
    return 'Update error: $error';
  }

  @override
  String get subscriptionPaymentSuccess =>
      'Payment successful: subscription activated.';

  @override
  String get subscriptionPaymentFailed => 'Payment or activation failed.';

  @override
  String get deliveryAcceptedSuccess => 'Delivery accepted successfully!';

  @override
  String get tricycleLoginRequiredTitle => 'You must sign in to continue.';

  @override
  String get tricycleLoginRequiredSubtitle => 'Sign in to order a tricycle.';

  @override
  String get tricycleRequestSentToDriver => 'Request sent to the driver.';

  @override
  String get tricycleRequestCancelled => 'Your request was cancelled.';

  @override
  String get tricycleCannotCancel => 'Request can no longer be cancelled.';

  @override
  String get tricycleDriverAlreadyAccepted =>
      'The driver has already accepted the request.';

  @override
  String get tricycleCancelFailed => 'Unable to cancel request.';

  @override
  String tricycleCancelErrorCode(String code) {
    return 'Code: $code. Please try again.';
  }

  @override
  String get tricycleCancelError => 'Error during cancellation.';

  @override
  String get tricycleRequestAcceptedChat =>
      'Request accepted. You can now chat.';

  @override
  String get tricycleRequestRejected => 'Request rejected.';

  @override
  String get checkConnectionRetry =>
      'Check your internet connection and try again.';

  @override
  String get pageNotAvailableForRole => 'Page not available for this role';

  @override
  String errorDetailed(String error) {
    return 'Detailed error: $error';
  }

  @override
  String get videoUploadErrorRetry =>
      'Error uploading video. Please try again.';

  @override
  String maxMediaSlots(int count) {
    return 'You can select at most $count media.';
  }

  @override
  String get driverRegistrationFormTitle => 'Registration form';

  @override
  String get imagesNotAllAddedWarning => 'Some images could not be added:';

  @override
  String get addedToCart => 'Item added to cart';

  @override
  String get payOnline => 'Online';

  @override
  String orderCommandTotal(String total) {
    return 'Order • $total F';
  }

  @override
  String registrationSaveError(String error) {
    return 'Save error: $error';
  }
}
