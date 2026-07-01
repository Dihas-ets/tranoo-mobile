// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get language => 'Langue';

  @override
  String get validate => 'Valider';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get arabic => 'Arabe';

  @override
  String get services => 'Services';

  @override
  String get service_sales_cars => 'Vente (Voitures)';

  @override
  String get service_delivery_parts => 'Livraison (Pièces)';

  @override
  String get service_tricycle => 'Tricycle';

  @override
  String get tricycle_location_required =>
      'Veuillez activer la localisation pour utiliser le service Tricycle.';

  @override
  String get tricycle_permission_denied =>
      'Autorisation de localisation refusée.';

  @override
  String get tricycle_permission_denied_forever =>
      'Autorisation de localisation bloquée. Activez-la dans les réglages.';

  @override
  String get tricycle_position_active_title => 'Position active';

  @override
  String get tricycle_position_active_subtitle =>
      'Localisation en cours… Les tricycles proches seront mis à jour automatiquement.';

  @override
  String get tricycle_none_nearby =>
      'Aucun tricycle à proximité pour le moment.';

  @override
  String get tricycle_out_of_range => 'Hors de portée';

  @override
  String get retry => 'Réessayer';

  @override
  String get enable_location => 'Activer la localisation';

  @override
  String get open_settings => 'Ouvrir les réglages';

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get call => 'Appeler';

  @override
  String get callShort => 'Appel';

  @override
  String get message => 'Message';

  @override
  String get tricycle_auth_required => 'Authentification requise';

  @override
  String get tricycle_connect_to_see => 'Connectez-vous pour voir';

  @override
  String get tricycle_connect_description =>
      'Veuillez connecter votre compte pour voir ce contenu';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirmer';

  @override
  String get back => 'Retour';

  @override
  String get close => 'Fermer';

  @override
  String get apply => 'Appliquer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get loading => 'Chargement...';

  @override
  String get understood => 'Compris';

  @override
  String get later => 'Plus tard';

  @override
  String get agree => 'D\'accord';

  @override
  String get submit => 'Soumettre';

  @override
  String get share => 'Partager';

  @override
  String get download => 'Télécharger';

  @override
  String get home => 'Accueil';

  @override
  String get profile => 'Profil';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Déconnexion';

  @override
  String get account => 'Compte';

  @override
  String get myAccount => 'Mon compte';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get currency => 'Devise';

  @override
  String get chooseCurrency => 'Choisir une devise';

  @override
  String get currencyXof => 'XOF';

  @override
  String get currencyEuro => 'Euro';

  @override
  String get currencyDollars => 'Dollars';

  @override
  String get password => 'Mot de passe';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Téléphone';

  @override
  String get fullName => 'Nom complet';

  @override
  String get firstName => 'Prénom(s)';

  @override
  String get lastName => 'Nom';

  @override
  String get security => 'Sécurité';

  @override
  String get description => 'Description';

  @override
  String get price => 'Prix';

  @override
  String get brand => 'Marque';

  @override
  String get model => 'Modèle';

  @override
  String get year => 'Année';

  @override
  String get location => 'Localisation';

  @override
  String get pieces => 'Pièces';

  @override
  String get vehicles => 'Véhicules';

  @override
  String get cars => 'Voitures';

  @override
  String get noResults => 'Aucun resultat';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get networkOrServerError => 'Erreur réseau ou serveur.';

  @override
  String get invalidSessionReconnect => 'Session invalide. Reconnectez-vous.';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get noUserData => 'Aucune donnée utilisateur';

  @override
  String get pleaseSignIn => 'Veuillez vous connecter';

  @override
  String get addImages => 'Ajouter des images';

  @override
  String get filterByBudget => 'Filtrer par budget';

  @override
  String get minLabel => 'Min.';

  @override
  String get maxLabel => 'Max.';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get deletionError => 'Erreur lors de la suppression.';

  @override
  String get sendAlert => 'Envoyer l\'alerte';

  @override
  String get alertSent => 'Alerte envoyée';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String errorGeneric(String error) {
    return 'Erreur: $error';
  }

  @override
  String errorOpening(String error) {
    return 'Erreur lors de l\'ouverture: $error';
  }

  @override
  String errorDeletion(String error) {
    return 'Erreur suppression: $error';
  }

  @override
  String errorPayment(String error) {
    return 'Erreur de paiement: $error';
  }

  @override
  String errorNetwork(String error) {
    return 'Erreur réseau : $error';
  }

  @override
  String vehiclesAvailableCount(int count) {
    return '$count véhicule(s) disponible(s)';
  }

  @override
  String partsAvailableCount(int count) {
    return '$count pièce(s) disponible(s)';
  }

  @override
  String get signInTitle => 'Se connecter';

  @override
  String get welcomeTranoo => 'Bienvenue sur Tranoo';

  @override
  String get welcomeTranooPro => 'Bienvenue sur Tranoo Pro';

  @override
  String get phoneTab => 'Numéro';

  @override
  String get legacyEmailTab => 'Email (ancien compte)';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get emailExample => 'exemple@mail.com';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get invalidEmailTitle => 'Email invalide';

  @override
  String get legacyEmailSubtitle =>
      'Sélectionnez « Email » et saisissez votre ancienne adresse.';

  @override
  String get invalidPhoneTitle => 'Numéro invalide';

  @override
  String invalidPhoneSubtitle(String hint, String country) {
    return 'Entrez $hint pour $country.';
  }

  @override
  String get loginSuccessTitle => 'Connexion réussie. Bienvenue !';

  @override
  String get cannotLoginTitle =>
      'Impossible de se connecter avec ces informations.';

  @override
  String get noBuyerAccount =>
      'Aucun compte acheteur n\'est associé à ce numéro.';

  @override
  String get checkCountryCode =>
      'Créez un compte ou vérifiez l\'indicatif pays.';

  @override
  String get wrongPassword => 'Mot de passe incorrect.';

  @override
  String get verifyAndRetry => 'Vérifiez vos informations et réessayez.';

  @override
  String get wrongCredentials => 'Numéro, email ou mot de passe incorrect.';

  @override
  String get accountBlocked => 'Votre compte est temporairement bloqué.';

  @override
  String get contactSupport => 'Contactez l\'assistance.';

  @override
  String get tooManyAttempts => 'Trop de tentatives de connexion.';

  @override
  String get retryInMinutes => 'Réessayez dans quelques minutes.';

  @override
  String get cannotReachServer => 'Impossible de se connecter au serveur.';

  @override
  String get checkInternet => 'Vérifiez votre connexion internet.';

  @override
  String get serviceTemporaryIssue =>
      'Notre service rencontre un problème temporaire.';

  @override
  String get tryAgainLater => 'Veuillez réessayer plus tard.';

  @override
  String get sessionInitFailed =>
      'La session n\'a pas pu être initialisée. Réessayez.';

  @override
  String get searchCountryOrCode => 'Rechercher un pays ou indicatif';

  @override
  String get buyerBlockedTitle =>
      'Cette application est réservée aux acheteurs';

  @override
  String get buyerBlockedSubtitle =>
      'Utilisez Tranoo Pro pour les comptes vendeur, chauffeur ou livreur.';

  @override
  String get noSellerAccount =>
      'Aucun compte vendeur n\'est associé à ce numéro.';

  @override
  String get useTranooForBuyer =>
      'Utilisez l\'application Tranoo pour les comptes acheteur.';

  @override
  String get findDreamCar => 'Trouvez votre voiture de rêve!';

  @override
  String get referralCodeOptional => 'Code de parrainage (optionnel)';

  @override
  String get referralPlaceholder => 'Ex: TRN-ABCD1234';

  @override
  String get searchCountryCode => 'Rechercher un indicatif (pays ou +code)';

  @override
  String get whatsappNumber => 'Numéro WhatsApp';

  @override
  String whatsappHint(String hint) {
    return 'WhatsApp · $hint';
  }

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get retypePassword => 'Retapez le mot de passe';

  @override
  String get passwordMin8 => 'Min. 8 caractères';

  @override
  String get missingFieldsTitle => 'Certains champs sont manquants.';

  @override
  String get completeRequiredInfo =>
      'Veuillez compléter les informations requises.';

  @override
  String get passwordMin8Title =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get accountCreatedTitle => 'Votre compte a été créé avec succès.';

  @override
  String get welcomeTranooExclaim => 'Bienvenue sur Tranoo !';

  @override
  String get passwordWeak => 'Faible';

  @override
  String get passwordMedium => 'Moyen';

  @override
  String get passwordStrong => 'Fort';

  @override
  String get passwordVeryStrong => 'Très fort';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get nextStep => 'Suivant';

  @override
  String get createAccount => 'Créer le compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get searchCountry => 'Rechercher un pays';

  @override
  String get incompleteServerResponse => 'Réponse serveur incomplète.';

  @override
  String get retryShortly => 'Réessayez dans quelques instants.';

  @override
  String get codeSent => 'Code envoyé';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get verifyCodeTitle => 'Vérifier le code';

  @override
  String get missingInfoTitle => 'Informations manquantes.';

  @override
  String get restartFromForgotPassword =>
      'Veuillez recommencer depuis la page mot de passe oublié.';

  @override
  String get errorOccurredTitle => 'Une erreur est survenue.';

  @override
  String get checkConnectionAndRetry =>
      'Vérifiez votre connexion et réessayez.';

  @override
  String get passwordTooShortTitle => 'Mot de passe trop court.';

  @override
  String passwordMinLength(int count) {
    return 'Minimum $count caractères.';
  }

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get whatsappNumberWarning =>
      'Utilisez un numéro joignable sur WhatsApp : il servira aux OTP et aux échanges entre notre équipe et les utilistaeurs.';

  @override
  String phoneDigitsExact(int count) {
    return '$count chiffres';
  }

  @override
  String phoneDigitsRange(int min, int max) {
    return '$min à $max chiffres';
  }

  @override
  String passwordStrengthLabel(String label) {
    return 'Force du mot de passe: $label';
  }

  @override
  String get stepInfo => 'Informations';

  @override
  String get placeholderFirstName => 'Jean';

  @override
  String get placeholderLastName => 'Dupont';

  @override
  String get accountAlreadyExistsTitle =>
      'Un compte existe déjà avec ce numéro.';

  @override
  String get accountAlreadyExistsSubtitle =>
      'Connectez-vous ou utilisez un autre numéro.';

  @override
  String referralCodeRegistered(String status) {
    return 'Code de parrainage enregistré (statut: $status)';
  }

  @override
  String get accountCreatedAgentReferral =>
      'Compte crée avec succès, Parrainage agent validé';

  @override
  String get forgotPasswordInstructions =>
      'Choisissez votre pays, puis entrez le numéro national\n(sans répéter l\'indicatif +229).\nLe code part sur le WhatsApp enregistré sur le compte.';

  @override
  String get enterYourPhone => 'Entrez votre numéro';

  @override
  String invalidPhoneWithHint(String hint) {
    return 'Numéro invalide ($hint)';
  }

  @override
  String get forgotPasswordBeninHint =>
      'Ex. pour +229 : saisissez 593XXXXXXX (8 chiffres), pas 01593XXXXXXX ni +229 devant.';

  @override
  String forgotPasswordNationalHint(String code) {
    return 'Saisissez uniquement le numéro national ; l\'indicatif $code est déjà choisi.';
  }

  @override
  String get accountNotFoundForNumber => 'Aucun compte trouvé pour ce numéro.';

  @override
  String get useSameWhatsappAsSignup =>
      'Utilisez le même numéro WhatsApp qu\'à l\'inscription (sans 0 après +229).';

  @override
  String get errorTokenMissing => 'Token manquant ou invalide.';

  @override
  String get errorTokenInvalid => 'Token invalide.';

  @override
  String get errorUserNotFound =>
      'Utilisateur non trouvé. Veuillez vous reconnecter.';

  @override
  String get errorAccountBlocked =>
      'Votre compte a été bloqué. Contactez l\'administration.';

  @override
  String get errorSessionRequired =>
      'Session web requise. Veuillez vous reconnecter.';

  @override
  String get errorSessionRevoked =>
      'Votre session a été ouverte ailleurs. Reconnexion requise.';

  @override
  String get errorSessionInactive =>
      'Session expirée après inactivité. Veuillez vous reconnecter.';

  @override
  String get errorInvalidPhone =>
      'Numéro invalide. Vérifiez l\'indicatif pays et le numéro saisi.';

  @override
  String get errorAppRequired => 'Application requise (tranoo ou tranoo_pro).';

  @override
  String get errorAccountAmbiguous =>
      'Plusieurs comptes partagent ce numéro. Contactez le support.';

  @override
  String get errorAccountNotFound => 'Aucun compte trouvé pour ce numéro.';

  @override
  String get errorOtpSendFailed =>
      'Impossible d\'envoyer le code. Vérifiez le numéro ou réessayez.';

  @override
  String get errorMissingFields => 'Champs requis manquants.';

  @override
  String get errorOtpInvalidOrExpired => 'Code invalide ou expiré.';

  @override
  String get errorDeviceMismatch =>
      'Ce téléphone ne correspond pas à la demande.';

  @override
  String get errorRequestInvalid => 'Demande invalide.';

  @override
  String get errorOtpExpired => 'Code expiré. Redemandez un code.';

  @override
  String get errorOtpLocked => 'Trop de tentatives. Redemandez un code.';

  @override
  String get errorOtpIncorrect => 'Code incorrect.';

  @override
  String get errorVerifyFirst => 'Veuillez d\'abord vérifier le code.';

  @override
  String get errorPasswordTooShort => 'Mot de passe trop court.';

  @override
  String get errorPasswordUpdateFailed =>
      'Impossible de mettre à jour le mot de passe. Contactez le support.';

  @override
  String get errorInternalError => 'Erreur. Réessayez.';

  @override
  String get errorValidationError => 'Données invalides.';

  @override
  String get errorNotAuthenticated => 'Utilisateur non authentifié.';

  @override
  String get errorForbidden => 'Accès refusé.';

  @override
  String get errorAccessDenied => 'Accès refusé.';

  @override
  String get errorNotFound => 'Ressource introuvable.';

  @override
  String get errorNoUpdateData => 'Aucune donnée à mettre à jour.';

  @override
  String get errorDescriptionTooLong =>
      'Description trop longue (500 caractères max).';

  @override
  String get errorGalleryTransitaireOnly =>
      'La galerie est réservée aux transitaires.';

  @override
  String get errorGalleryMustBeArray => 'La galerie doit être une liste.';

  @override
  String get errorGalleryMaxItems => 'Maximum 20 éléments dans la galerie.';

  @override
  String get errorGalleryInvalidItem => 'Élément de galerie invalide.';

  @override
  String get errorGalleryItemTypeUrl =>
      'Chaque élément doit avoir un type (image ou vidéo) et une URL.';

  @override
  String get errorVendeurTypeSellersOnly =>
      'Ce paramètre est réservé aux vendeurs.';

  @override
  String get errorVendeurTypeInvalid => 'Type de vendeur invalide.';

  @override
  String get errorPhoneAlreadyUsed =>
      'Ce numéro est déjà utilisé pour cette application.';

  @override
  String get errorPhoneAmbiguous =>
      'Ce numéro est associé à plusieurs comptes. Contactez le support.';

  @override
  String get errorUserIncomplete => 'Informations utilisateur incomplètes.';

  @override
  String get errorProfileUpdateFailed =>
      'Erreur lors de la mise à jour du profil.';

  @override
  String get errorFirebaseEmailSyncFailed =>
      'Email mis à jour localement mais pas sur le compte.';

  @override
  String get errorFcmTokenRequired => 'Token de notification requis.';

  @override
  String get errorArticleIdRequired => 'Identifiant d\'article requis.';

  @override
  String get errorFileRequired => 'Aucun fichier envoyé.';

  @override
  String get errorConnectionFailed => 'Erreur de connexion.';

  @override
  String get errorEnterPhoneNumber => 'Veuillez entrer votre numéro.';

  @override
  String get codeSentWhatsappDefault =>
      'Code envoyé sur WhatsApp au numéro de votre compte.';

  @override
  String get enterCodePlease => 'Veuillez entrer le code';

  @override
  String get otpMustBe6Digits => 'Le code doit contenir 6 chiffres';

  @override
  String get invalidCode => 'Code invalide.';

  @override
  String verifyCodeBanner(int minutes) {
    return 'Saisissez le code à 6 chiffres.\nValide $minutes min. Vérifiez la notification Tranoo ou WhatsApp au numéro du compte.';
  }

  @override
  String get save => 'Enregistrer';

  @override
  String get passwordChangedSuccess => 'Mot de passe modifié avec succès.';

  @override
  String get connectSupport => 'Connecter l\'assistance';

  @override
  String get cannotOpenWhatsApp => 'Impossible d\'ouvrir WhatsApp.';

  @override
  String get installWhatsAppRetry => 'Installez WhatsApp puis réessayez.';

  @override
  String get preferences => 'Préférences';

  @override
  String get geolocation => 'Géolocalisation';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get pushNotificationsSubtitle => 'Recevoir des notifications push';

  @override
  String get locationTracking => 'Suivi de localisation';

  @override
  String get shareRealtimeLocation => 'Partager votre position en temps réel';

  @override
  String get cfaFranc => 'Franc CFA';

  @override
  String get usDollar => 'Dollar US';

  @override
  String get createAccountToContinue => 'Créez un compte pour continuer.';

  @override
  String get actionRequired => 'Action requise';

  @override
  String get uploadProfilePhotoRequired =>
      'Veuillez uploader votre photo de profil pour continuer.';

  @override
  String get proBuyerBlockedTitle =>
      'Compte acheteur non autorisé sur Tranoo Pro';

  @override
  String get proBuyerBlockedSubtitle =>
      'Les acheteurs utilisent l\'application Tranoo.';

  @override
  String get thisCountry => 'ce pays';

  @override
  String get passwordDotsHint => '••••••••';

  @override
  String get continueButton => 'Continuer';

  @override
  String get locationRequired => 'Localisation requise';

  @override
  String get authorizationRequired => 'Autorisation nécessaire';

  @override
  String get whatWeUse => 'Ce que nous utilisons :';

  @override
  String get locationBackgroundWarning =>
      'La localisation est utilisée même lorsque l\'application est en arrière-plan pour assurer un suivi continu.';

  @override
  String get backgroundLocationTitle => 'Localisation en arrière-plan';

  @override
  String get backgroundLocationMessage =>
      'Pour assurer un suivi continu de vos missions, nous avons besoin d\'accéder à votre localisation même lorsque l\'application est en arrière-plan.\n\nVous pouvez activer cette permission dans les paramètres de votre appareil.';

  @override
  String get deviceSettings => 'Paramètres';

  @override
  String get permissionDenied => 'Permission refusée';

  @override
  String locationRequiredForRole(String role) {
    return 'La localisation est nécessaire pour utiliser les fonctionnalités de $role. Certaines fonctionnalités pourraient être limitées.';
  }

  @override
  String permissionRequestError(String error) {
    return 'Une erreur est survenue lors de la demande de permission: $error';
  }

  @override
  String get welcomeTranooProExclaim => 'Bienvenue sur Tranoo Pro !';

  @override
  String get locationAuthorization => 'Autorisation de localisation';

  @override
  String get locationUsageIntro =>
      'Pour fonctionner correctement, Tranoo Pro utilise votre localisation pour :';

  @override
  String get locationBackgroundServicesWarning =>
      'La localisation peut être utilisée même lorsque l\'application est en arrière-plan pour assurer un suivi continu des services.';

  @override
  String get changeDecisionLaterInSettings =>
      'Vous pourrez modifier cette décision plus tard dans les paramètres';

  @override
  String get authorizeLocationInSettings =>
      'Autorisez la localisation dans les paramètres.';

  @override
  String get cannotGetPosition => 'Impossible d\'obtenir la position.';

  @override
  String get yourCurrentPosition => 'Votre position actuelle';

  @override
  String get positionUsageForListings =>
      'Utilisée pour vos annonces et la localisation fournisseur. Vous pourrez la mettre à jour dans votre profil.';

  @override
  String get saveCurrentPosition => 'Enregistrer ma position actuelle';

  @override
  String get refreshPosition => 'Actualiser la position';

  @override
  String get positionSavedGps => 'Position enregistrée (coordonnées GPS)';

  @override
  String get profilePositionUpdated => 'Position du profil mise à jour';

  @override
  String get savePositionToContinue =>
      'Enregistrez votre position actuelle pour continuer.';

  @override
  String get saveYourCurrentPosition => 'Enregistrez votre position actuelle.';

  @override
  String get sellerUpdateTitle => 'Mise a jour vendeur';

  @override
  String get sellerTypeChoiceIntro =>
      'Tranoo Pro vous permet maintenant de choisir votre type de vendeur: vehicules, pieces detachees ou mixte.';

  @override
  String get sellerTypeChoiceHint =>
      'Faites votre choix dans la page dediee pour adapter vos menus et vos publications.';

  @override
  String get makeChoice => 'Faire un choix';

  @override
  String get professionalAccess => 'Accès Professionnel';

  @override
  String useAlternativeAppForProfessionalRole(String app) {
    return 'Utilisez plutôt $app pour votre rôle professionnel';
  }

  @override
  String subscriptionExpiresIn(int days) {
    return 'Votre abonnement expire dans $days jour(s).';
  }

  @override
  String freeTrialEndsIn(int days) {
    return 'Votre periode gratuite se termine dans $days jour(s).';
  }

  @override
  String currentPlanLabel(String plan) {
    return 'Plan actuel: $plan';
  }

  @override
  String get unknown => 'Inconnu';

  @override
  String get manageSubscription => 'Gerer mon abonnement';

  @override
  String get historyLast10 => 'Historique (10 derniers)';

  @override
  String get noSubscriptionPayments =>
      'Aucun paiement d\'abonnement pour le moment.';

  @override
  String get serverTimeout =>
      'Le serveur met trop de temps a repondre. Reessaie dans un instant.';

  @override
  String get cannotReachServerDetailed =>
      'Impossible de joindre le serveur. Verifie ta connexion et l\'URL du backend.';

  @override
  String get accountDeletionFailed =>
      'La suppression du compte a echoue. Reessaie plus tard.';

  @override
  String get unexpectedDeletionError =>
      'Une erreur inattendue est survenue pendant la suppression.';

  @override
  String get myPurchases => 'Mes achats';

  @override
  String get myPurchasesSubtitle => 'Voir l\'historique de vos commandes';

  @override
  String get myReviews => 'Mes avis';

  @override
  String get myReviewsSubtitle => 'Consulter ou modifier vos commentaires';

  @override
  String get myInvoices => 'Mes factures';

  @override
  String get myInvoicesSubtitle => 'Télécharger vos justificatifs d\'achats';

  @override
  String get accountCreatedSuccess => 'Compte créé avec succès.';

  @override
  String get fieldRequired => 'Ce champ est obligatoire.';

  @override
  String get address => 'Adresse';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get addDeliveryNote => 'Ajouter une note de livraison';

  @override
  String get chooseDate => 'Choisir la date d\'expédition';

  @override
  String get packageLabel => 'Colis';

  @override
  String get packagesToDeliver => 'Colis à livrer';

  @override
  String get orderLabel => 'Commande';

  @override
  String get qrContent => 'Contenu QR';

  @override
  String get carDescription => 'Description de la voiture';

  @override
  String get becomeCertifiedDriver => 'Devenir chauffeur certifié';

  @override
  String get adDuration => 'Durée de la publicité';

  @override
  String get inDelivery => 'En livraison';

  @override
  String get inTransit => 'En transit';

  @override
  String get enterCompanyName => 'Entrer le nom de l\'entreprise';

  @override
  String get enterVehicleName => 'Entrer le nom du véhicule';

  @override
  String get enterCarDescriptionOptional =>
      'Entrer une description de votre voiture (optionnel)';

  @override
  String get enterClientDestination => 'Entrez la destination du client';

  @override
  String get enterBrand => 'Entrez la marque';

  @override
  String get enterModel => 'Entrez le modèle';

  @override
  String get enterCustomModel => 'Entrez le modèle personnalisé';

  @override
  String get enterDestinationDetails =>
      'Entrez vos détails concernant la destination ici...';

  @override
  String get engineDisplacementExample => 'Ex: 1600 ou 1,6';

  @override
  String get requirements => 'Exigences';

  @override
  String get supplier => 'Fournisseur';

  @override
  String get supplierToBuyer => 'Fournisseur -> Acheteur';

  @override
  String get deliveryEarnings => 'Gain livraison';

  @override
  String get vehicleInfoRequired =>
      'Immatriculation, type, marque et modèle sont requis.';

  @override
  String get vehicleInfoMissing => 'Informations véhicule manquantes.';

  @override
  String get mileageHint => 'Kilométrage (km), ex: 12500 ou 12,5';

  @override
  String get externalLinkOptional => 'Lien externe (optionnel)';

  @override
  String get partOrCarName => 'Nom de la pièce/voiture';

  @override
  String get nameOnCard => 'Nom sur la carte';

  @override
  String get seatCount => 'Nombre de places';

  @override
  String get notProvided => 'Non renseigné';

  @override
  String get notificationDefault => 'Notification';

  @override
  String get orderNumber => 'Numéro de commande';

  @override
  String get cashPayment => 'Paiement en espèces';

  @override
  String get positionRequired => 'Position requise';

  @override
  String get priceFcfa => 'Prix (FCFA)';

  @override
  String get priceFcfaExample => 'Prix en FCFA (ex: 1500000 ou 1.500.000,5)';

  @override
  String get offerDeliveryServices => 'Proposer des services de livraison';

  @override
  String get specifyModel => 'Précisez le modèle';

  @override
  String get searchCarHint =>
      'Rechercher une voiture (marque, modèle, titre)...';

  @override
  String get summary => 'Résumé';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get titleLabel => 'Titre';

  @override
  String get typeLabel => 'Type';

  @override
  String get engineType => 'Type de moteur';

  @override
  String get adType => 'Type de publicité';

  @override
  String get engineTypeShort => 'Type moteur';

  @override
  String get toBuyer => 'Vers acheteur';

  @override
  String get toSupplier => 'Vers fournisseur';

  @override
  String get pleaseEnterCompany => 'Veuillez renseigner votre entreprise.';

  @override
  String get deliverTo => 'À livrer à';

  @override
  String get conditionLabel => 'État';

  @override
  String get buyer => 'Acheteur';

  @override
  String get positionGpsSaved => 'Position GPS enregistrée';

  @override
  String get enterLink => 'Entrer l\'URL';

  @override
  String get passwordSuperStrong => 'Super fort';

  @override
  String get onboardingTagline1 =>
      'Tranoo \nTrouvez vos pièces et\nvéhicules rapidement';

  @override
  String get onboardingTagline2 =>
      'Découvrez votre\nvéhicule idéal en\nquelques clics';

  @override
  String get accountDeletion => 'Suppression de compte';

  @override
  String get accountDeletionIrreversible => 'Cette action est irreversible.';

  @override
  String get accountDeletionDataWarning =>
      'Votre compte, votre acces a l\'application et vos donnees liees seront supprimes.';

  @override
  String get accountDeletionConfirmWarning =>
      'Assurez-vous de ne plus avoir besoin de ce compte avant de confirmer.';

  @override
  String get editAccountSubtitle => 'Apporter des modifications à votre compte';

  @override
  String get referral => 'Parrainage';

  @override
  String get referralSubtitle => 'Gagnez en parrainant vos amis';

  @override
  String get sellMyCar => 'Vendre ma voiture';

  @override
  String get sellMyPart => 'Vendre ma pièce';

  @override
  String get becomeSellerSubtitle => 'Devenir titulaire et vendez avec nous';

  @override
  String get sellerAccessOnly => 'Accès réservé aux vendeurs.';

  @override
  String get transitaireAccessOnly => 'Accès réservé aux transitaires.';

  @override
  String get transitHistory => 'Historique des transits';

  @override
  String get user => 'Utilisateur';

  @override
  String get userNotConnected => 'Utilisateur non connecté';

  @override
  String get newAlertDefault => 'Nouvelle alerte';

  @override
  String get buyerSearchingPart =>
      'Un acheteur est a la recherche d\'une piece.';

  @override
  String get buyerSearchingVehicle =>
      'Un acheteur est a la recherche d\'un vehicule.';

  @override
  String get characteristics => 'Caracteristiques:';

  @override
  String get noCharacteristicsProvided => '- Aucune caracteristique fournie';

  @override
  String get proposeOffer => 'Proposez une offre';

  @override
  String get myCart => 'Mon Panier';

  @override
  String get cartEmpty => 'Votre panier est vide';

  @override
  String get cartEmptyHint => 'Ajoutez des articles pour commencer vos achats';

  @override
  String get checkout => 'Passer la commande';

  @override
  String get carsOnline => 'Voitures en ligne';

  @override
  String get motosOnline => 'Motos en ligne';

  @override
  String get buyThisMoto => 'Acheter cette moto';

  @override
  String get signInToBuyThisMoto => 'Connectez-vous pour acheter cette moto';

  @override
  String get carDeletedSuccess => 'Voiture supprimée avec succès !';

  @override
  String get newCondition => 'Neuf';

  @override
  String get usedCondition => 'Occasion';

  @override
  String get budgetFcfa => 'Budget (FCFA)';

  @override
  String get spareParts => 'Pièces détachées';

  @override
  String get confirmDeletePart =>
      'Voulez-vous vraiment supprimer cette pièce ?';

  @override
  String get partDeletedSuccess => 'Pièce supprimée avec succès !';

  @override
  String get searchPartHint => 'Rechercher une pièce...';

  @override
  String get searchVehiclesPartsHint => 'Rechercher véhicules, pièces...';

  @override
  String get deliveries => 'Livraisons';

  @override
  String get tricycles => 'Tricycles';

  @override
  String get fillMiniForm => 'Remplir mini form';

  @override
  String get discussions => 'Discussions';

  @override
  String get noDiscussions => 'Aucune discussion';

  @override
  String get startDiscussionWithSeller =>
      'Commencez une discussion avec un vendeur';

  @override
  String get typeMessageHint => 'Tapez votre message...';

  @override
  String get messageSendError => 'Erreur lors de l\'envoi du message';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get markAllRead => 'Tout marquer lu';

  @override
  String get notificationDetails => 'Détails notification';

  @override
  String get myOrders => 'Mes commandes';

  @override
  String get noOrders => 'Aucune commande';

  @override
  String get orderDetails => 'Détails de commande';

  @override
  String get orderTracking => 'Suivi de commande';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterInProgress => 'En cours';

  @override
  String get filterCompleted => 'Terminée';

  @override
  String get myWallet => 'Mon portefeuille';

  @override
  String get withdrawal => 'Retrait';

  @override
  String get transactions => 'Transactions';

  @override
  String get paymentMethod => 'Moyen de paiement';

  @override
  String get paymentSuccessful => 'Paiement Réussi !';

  @override
  String get paymentFailed => 'Paiement échoué';

  @override
  String get pay => 'Payer';

  @override
  String get payNow => 'Payer maintenant';

  @override
  String get returnToApp => 'Retourner à l\'app';

  @override
  String get wooHoo => 'Woo hoo !!';

  @override
  String get goToHome => 'Accéder à l\'accueil';

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get publishedOnline => 'Publication en ligne !';

  @override
  String get returnHome => 'Retour à l\'accueil';

  @override
  String get referralTitle => 'Parrainage';

  @override
  String get referralLinkCopied => 'Lien de parrainage copié !';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get yourStats => 'Vos Statistiques';

  @override
  String get pending => 'En attente';

  @override
  String get completed => 'Complété';

  @override
  String get chooseLocation => 'Choisir la localisation';

  @override
  String get navigate => 'Naviguer';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get livreurHome => 'Accueil livreur';

  @override
  String get chauffeurHome => 'Accueil chauffeur';

  @override
  String get myDeliveries => 'Mes livraisons';

  @override
  String get sellerSubscription => 'Abonnement vendeur';

  @override
  String get premiumSubscription => 'Abonnement Premium';

  @override
  String get subscribeNow => 'Souscrire maintenant';

  @override
  String get sellerWallet => 'Portefeuille vendeur';

  @override
  String get more => 'Plus';

  @override
  String get signInForProfile => 'Connectez-vous pour accéder à votre profil';

  @override
  String get profileLoadError =>
      'Impossible de charger le profil. Vérifiez votre connexion ou vos droits.';

  @override
  String get profileSaveError => 'Erreur lors de la sauvegarde du profil';

  @override
  String get company => 'Entreprise';

  @override
  String get country => 'Pays';

  @override
  String get gender => 'Genre';

  @override
  String get genderMale => 'Mâle';

  @override
  String get genderFemale => 'Femelle';

  @override
  String get genderOther => 'Autre';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get profileUpdateError => 'Erreur lors de la mise à jour';

  @override
  String get restrictedAccess => 'Accès Restreint';

  @override
  String roleNotAllowedOnApp(String role, String app) {
    return 'Votre rôle ($role) n\'est pas autorisé sur $app';
  }

  @override
  String useAlternativeAppForRole(String app) {
    return 'Utilisez plutôt $app pour votre rôle';
  }

  @override
  String get googlePlay => 'Google Play';

  @override
  String get appStore => 'App Store';

  @override
  String get alertNotificationsTitle => 'Notifications d\'alertes';

  @override
  String get alertNotificationsDescription =>
      'Autorisez les notifications pour être alerté quand un vendeur répond à votre alerte, même lorsque l\'application est en arrière-plan.';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get referralLinkTitle => 'Votre Lien de Parrainage';

  @override
  String get referralShareTitle => 'Partager votre lien de parrainage';

  @override
  String get others => 'Autres';

  @override
  String get total => 'Total';

  @override
  String get yourReferrals => 'Vos Parrainages';

  @override
  String get noReferralsYet => 'Aucun parrainage pour le moment';

  @override
  String get shareReferralHint =>
      'Partagez votre code avec vos amis pour commencer !';

  @override
  String referralShareMessage(String link) {
    return '🚗 Rejoins-moi sur Tranoo !\n\nTélécharge l\'app via mon lien de parrainage : $link\n\nEnsemble, trouvons les meilleures voitures et pièces détachées ! 🚙✨';
  }

  @override
  String unexpectedError(String error) {
    return 'Erreur inattendue : $error';
  }

  @override
  String serverError(String status, String message) {
    return 'Erreur serveur : $status - $message';
  }

  @override
  String alertLabelBrand(String value) {
    return 'Marque : $value';
  }

  @override
  String alertLabelModel(String value) {
    return 'Modèle : $value';
  }

  @override
  String alertLabelCondition(String value) {
    return 'État : $value';
  }

  @override
  String alertLabelYear(String value) {
    return 'Année : $value';
  }

  @override
  String alertLabelYearMin(String value) {
    return 'Année min : $value';
  }

  @override
  String alertLabelYearMax(String value) {
    return 'Année max : $value';
  }

  @override
  String alertLabelBudgetMax(String value) {
    return 'Budget max : $value FCFA';
  }

  @override
  String alertLabelPart(String value) {
    return 'Pièce : $value';
  }

  @override
  String alertLabelUrgency(String value) {
    return 'Urgence : $value';
  }

  @override
  String alertLabelLocation(String value) {
    return 'Localisation : $value';
  }

  @override
  String alertLabelDetails(String value) {
    return 'Détails : $value';
  }

  @override
  String get confirmDeleteCar =>
      'Voulez-vous vraiment supprimer cette voiture ?';

  @override
  String get vehicleBrandLabel => 'Marque du vehicule';

  @override
  String get partNameLabel => 'Nom de la piece';

  @override
  String get urgencyLow => 'Faible';

  @override
  String get urgencyNormal => 'Normale';

  @override
  String get urgencyHigh => 'Urgente';

  @override
  String alertSendError(String error) {
    return 'Erreur envoi alerte: $error';
  }

  @override
  String get searchTypeTitle => 'Type de recherche';

  @override
  String get whatDoYouWantToSearch => 'Que voulez-vous rechercher ?';

  @override
  String get noArticleLinkedToAd => 'Aucun article lié à cette pub.';

  @override
  String get sellerPhoneUnavailable => 'Numéro du vendeur indisponible';

  @override
  String get imageNotAvailable => 'Image non disponible';

  @override
  String get requestValidatedWhatsApp => 'Demande validée — ouverture WhatsApp';

  @override
  String get requestRejected => 'Demande rejetée';

  @override
  String errorActionStatus(int status) {
    return 'Erreur action: $status';
  }

  @override
  String get notificationsLoadError =>
      'Erreur lors du chargement des notifications';

  @override
  String get notificationDeleted => 'Notification supprimée';

  @override
  String get markedAsUnread => 'Marquée comme non lue';

  @override
  String get markAsUnread => 'Marquer comme non lue';

  @override
  String get confirmDeleteNotification => 'Supprimer cette notification ?';

  @override
  String get orderSummary => 'Résumé';

  @override
  String get selectAddress => 'Sélectionner une adresse';

  @override
  String get direction => 'Direction';

  @override
  String get track => 'Traquer';

  @override
  String get orderPayment => 'Paiement commande';

  @override
  String get preparingPayment => 'Préparation du paiement...';

  @override
  String get noActiveOrderToTrack => 'Aucune commande active à tracker';

  @override
  String get ordersLoadError => 'Erreur lors du chargement des commandes';

  @override
  String get orderRegisteredDeliverySoon =>
      'Votre commande est enregistrée. Un livreur prendra bientôt en charge la livraison.';

  @override
  String get driverAssignedTrackRealtime =>
      'Livreur assigné. Suivez sa position en temps réel.';

  @override
  String get returnPackage => 'Retourner le colis';

  @override
  String get pickupMyOrder => 'Récupérer ma commande';

  @override
  String get deliveryNotFound => 'Livraison introuvable.';

  @override
  String get orderPickedUpSuccess => 'Commande récupérée avec succès.';

  @override
  String pickupError(String error) {
    return 'Erreur récupération: $error';
  }

  @override
  String get returnReasonHint =>
      'Ex: pièce non conforme, défaut, erreur de modèle…';

  @override
  String get send => 'Envoyer';

  @override
  String get reasonRequired => 'Motif requis.';

  @override
  String get returnReportedPaymentRequired =>
      'Retour signalé. Paiement des frais de livraison requis.';

  @override
  String returnError(String error) {
    return 'Erreur retour: $error';
  }

  @override
  String get paymentInterrupted => 'Paiement interrompu';

  @override
  String get paymentInterruptedMessage =>
      'Vous avez quitté l\'écran de paiement ou la transaction n\'a pas été finalisée.';

  @override
  String get paymentInterruptedSubtitle =>
      'Aucun prélèvement n\'est enregistré. Vous pouvez réessayer quand vous voulez.';

  @override
  String get paymentErrorMessage =>
      'Une erreur s\'est produite lors de la transaction.';

  @override
  String get paymentErrorRetrySupport =>
      'Veuillez réessayer ou contacter le support.';

  @override
  String get transactionSuccessMessage =>
      'Votre transaction a été effectuée avec succès.';

  @override
  String get closePageReturnToApp =>
      'Vous pouvez maintenant fermer cette page et retourner à l\'application.';

  @override
  String get selectToChoose => 'À sélectionner';

  @override
  String get bankPayment => 'Paiement bancaire';

  @override
  String get mobileMoney => 'Mobile Money';

  @override
  String get paymentSuccessUpdatingStatus =>
      'Paiement réussi ! Mise à jour du statut...';

  @override
  String get adPaidSuccess => 'Publicité payée avec succès !';

  @override
  String get subscriptionActivatedSuccess => 'Abonnement activé avec succès !';

  @override
  String get redirecting => 'Redirection en cours...';

  @override
  String get verifyPayment => 'Vérification du paiement';

  @override
  String get finalizePayment => 'Finaliser le paiement';

  @override
  String get purchaseSuccessMessage =>
      'Cher client vous avez réussi à faire votre achat avec succès. ';

  @override
  String get purchaseSuccessDelivery =>
      'Votre produit vous sera livré au plus dans 5 jrs. Merci pour votre confiance !';

  @override
  String get articleCreatedPendingValidation =>
      'Bravo! Vous avez réussi à créer votre article. C\'est en cours de validation.';

  @override
  String get almostThere => 'Vous y êtes presque';

  @override
  String get spotlightCostPrefix => 'Votre mise en lumière coûtera environ ';

  @override
  String get spotlightCostSuffix =>
      ' pour ce véhicule. Continuez et finalisez votre paiement pour voir votre véhicule en tête de liste de nos produits.';

  @override
  String get saleSuccessTitle => 'Vente réussie !';

  @override
  String get publishedSuccessMessage =>
      'Votre annonce est maintenant en ligne !';

  @override
  String get yourBalanceIs => 'Votre solde est de :';

  @override
  String get entry => 'Entrée';

  @override
  String get makeWithdrawal => 'Effectuer un retrait';

  @override
  String get transferAccount => 'Compte de virement';

  @override
  String get cardNumber => 'Numéro de carte';

  @override
  String get month => 'Mois';

  @override
  String get securityCode => 'Code de sécurité de la carte';

  @override
  String get codeHint => 'Code';

  @override
  String get requestWithdrawal => 'Demander un Retrait';

  @override
  String get myWithdrawals => 'Mes retraits';

  @override
  String get withdrawalRequest => 'Demande de Retrait';

  @override
  String get noMessage => 'Aucun message';

  @override
  String get articleDefault => 'Article';

  @override
  String get justNow => 'À l\'instant';

  @override
  String get recent => 'Récent';

  @override
  String get errorSendingImage => 'Erreur lors de l\'envoi de l\'image';

  @override
  String get errorSendingDocument => 'Erreur lors de l\'envoi du document';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get openingDocument => 'Ouverture du document...';

  @override
  String get myTransits => 'Mes Transits';

  @override
  String get noArticlesInCategory => 'Aucun article dans cette catégorie';

  @override
  String get discussionCreationError =>
      'Erreur lors de la création de la discussion';

  @override
  String get articleWithoutId => 'Article sans ID';

  @override
  String get contactTransitaire => 'Contacter le transitaire';

  @override
  String get finalizePurchase => 'Finalisation de l\'achat';

  @override
  String get chosenForwarderRate => 'Tarif transitaire choisi';

  @override
  String get additionalFees => 'Frais supplémentaires';

  @override
  String get totalPrice => 'Prix total';

  @override
  String get downloadInvoice => 'Télécharger la facture';

  @override
  String get chooseFormat => 'Choisissez le format :';

  @override
  String get imageFormat => 'Image';

  @override
  String get documentFormat => 'Document';

  @override
  String get imageGallery => 'Image (Galerie)';

  @override
  String get chooseDownloadFormat => 'Choisissez le format de téléchargement:';

  @override
  String get preparingShare => 'Préparation du partage...';

  @override
  String get invoiceReadyToShare => 'Facture prête à partager !';

  @override
  String shareError(String error) {
    return 'Erreur lors du partage: $error';
  }

  @override
  String get maxImagesReached => 'Maximum de 12 images atteint';

  @override
  String get videoUploadedSuccess => 'Vidéo uploadée avec succès !';

  @override
  String get waitUploadFinish => 'Veuillez attendre la fin de l\'upload.';

  @override
  String get addAtLeastOneMedia =>
      'Veuillez ajouter au moins une image ou une vidéo.';

  @override
  String get fillRequiredFields =>
      'Veuillez remplir tous les champs obligatoires.';

  @override
  String get enterTitle => 'Entrer le titre';

  @override
  String get enterYear => 'Entrer l\'année (ex: 2020)';

  @override
  String get enterCylinder => 'Entrer le cylindre (ex: 1600)';

  @override
  String get enterDistance => 'Entrer la distance (km)';

  @override
  String get enterSeats => 'Entrer le nombre de sièges';

  @override
  String get enterPrice => 'Saisir le Prix';

  @override
  String get enterCarDescription => 'Entrer une description de votre voiture';

  @override
  String get uploadInProgress => 'Upload en cours...';

  @override
  String get publishListing => 'Publier l\'annonce';

  @override
  String get uploadImageFailed => 'Échec de l\'upload de l\'image.';

  @override
  String get noImageSelected => 'Aucune image sélectionnée.';

  @override
  String get newOffer => 'Nouvelle offre';

  @override
  String get selectAtLeastOneImage =>
      'Veuillez sélectionner au moins une image.';

  @override
  String get fillCarFields => 'Veuillez remplir tous les champs de la voiture.';

  @override
  String get requestCreationError =>
      'Erreur lors de la création de la demande.';

  @override
  String get statusUpdateError => 'Erreur lors de la mise à jour du statut.';

  @override
  String get clickableLinkOptional => 'Lien cliquable (optionnel)';

  @override
  String get itemName => 'Nom de la pièce/voiture';

  @override
  String get companyName => 'Nom de l\'entreprise';

  @override
  String get locationServicesDisabled =>
      'Les services de localisation sont désactivés';

  @override
  String get locationPermissionDenied => 'Permission de localisation refusée';

  @override
  String get locationPermissionDeniedForever =>
      'Permission de localisation refusée définitivement';

  @override
  String get confirmThisLocation => 'Confirmer cette position';

  @override
  String get useMyLocation => 'Utiliser ma position';

  @override
  String get drivingLicense => 'Permis de conduire';

  @override
  String get yourMessage => 'Votre message';

  @override
  String get submitApplication => 'Soumettre la candidature';

  @override
  String get applicationSubmitted => 'Candidature soumise avec succès !';

  @override
  String get applicationSubmitError => 'Erreur lors de la soumission.';

  @override
  String get vendreTitle => 'Vendre';

  @override
  String get quantity => 'Quantité';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get buyNow => 'Acheter maintenant';

  @override
  String get contactSeller => 'Contacter le vendeur';

  @override
  String get views => 'Vues';

  @override
  String get status => 'Statut';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Montant';

  @override
  String get details => 'Détails';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get errorLoading => 'Erreur de chargement';

  @override
  String get continueAction => 'Continuer';

  @override
  String get edit => 'Modifier';

  @override
  String get remove => 'Retirer';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get shipping => 'Livraison';

  @override
  String get orderStatus => 'Statut de commande';

  @override
  String get orderDate => 'Date de commande';

  @override
  String get delivered => 'Livrée';

  @override
  String get cancelled => 'Annulée';

  @override
  String get processing => 'Traitement...';

  @override
  String get errorUserNotConnected => 'Erreur: Utilisateur non connecté';

  @override
  String get adPaymentSuccessMessage =>
      'Votre paiement a été effectué avec succès ! ';

  @override
  String get adPaymentSuccessHighlight =>
      'Votre article sera mis en avant dès validation par notre équipe. Vous recevrez une notification de confirmation.';

  @override
  String get preparing => 'Préparation...';

  @override
  String get listingPublishedVisiblePrefix =>
      'Votre article est publié et visible ';

  @override
  String get immediately => 'immédiatement';

  @override
  String get listingPublishedVisibleSuffix =>
      ' sur l\'application.\n\nVous pouvez déjà le retrouver dans les listes.';

  @override
  String get listingAlreadyOnline => 'Votre annonce est déjà en ligne.';

  @override
  String get noVehicleSearchResultHint =>
      'Aucune voiture ne correspond a votre recherche.\nCreez une mini alerte pour etre contacte rapidement.';

  @override
  String get noPartSearchResultHint =>
      'Aucune piece ne correspond a votre recherche.\nCreez une mini alerte pour etre contacte rapidement.';

  @override
  String get priceFcfaLabel => 'Prix (FCFA)';

  @override
  String get vehicleAlert => 'Alerte vehicule';

  @override
  String get partAlert => 'Alerte piece';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get vehicleCondition => 'Etat du vehicule';

  @override
  String get brandRequired => 'Marque requise';

  @override
  String get modelRequired => 'Modele requis';

  @override
  String get yearRequired => 'Annee requise';

  @override
  String get budgetRequired => 'Budget requis';

  @override
  String get alertRegisteredFeedback =>
      'Votre demande a bien ete enregistree. Vous recevrez les retours des vendeurs tres bientot.';

  @override
  String get whatsappOpenDetailed =>
      'Impossible d\'ouvrir WhatsApp. Vérifiez que l\'application ou un navigateur est installé sur votre téléphone.';

  @override
  String get noVideoAvailable => 'Aucune vidéo disponible';

  @override
  String get cannotMakeCall => 'Impossible de passer un appel';

  @override
  String get cylinder => 'Cylindre';

  @override
  String get fuel => 'Carburant';

  @override
  String get airConditioner => 'Climatiseur';

  @override
  String get distanceKm => 'Distance';

  @override
  String get seats => 'Sièges';

  @override
  String get doors => 'Portes';

  @override
  String get gearbox => 'Boîte à vitesse';

  @override
  String get customsClearance => 'Dédouanement';

  @override
  String get inConsumption => 'En Consommation';

  @override
  String get chooseCountry => 'Choisissez un pays';

  @override
  String get additionalDetails => 'Détails supplémentaires';

  @override
  String get signInForVerification =>
      'Connectez-vous pour demander une vérification';

  @override
  String get signInForDelivery =>
      'Connectez-vous pour commander avec livraison';

  @override
  String get signInToBuyThisCar => 'Connectez-vous pour acheter cette voiture';

  @override
  String get chooseDeliveryMode =>
      'Veuillez choisir un mode de livraison (En Consommation ou En Transit).';

  @override
  String get selectLocationPlease => 'Veuillez sélectionner un lieu.';

  @override
  String get verificationInProgress => 'Contrôle en cours';

  @override
  String get verificationChecksPrefix =>
      'Les vérifications seront effectuées et vous seront envoyées sous ';

  @override
  String get tenBusinessDays => '10 jours';

  @override
  String get verificationChecksMiddle => '. Pour démarrer, veuillez payer les ';

  @override
  String get verificationFeesLabel => 'frais de vérification';

  @override
  String get payVerificationFees => 'Payer les frais de vérification';

  @override
  String get requestVerification => 'Demander une vérification';

  @override
  String get buyThisCar => 'Acheter cette voiture';

  @override
  String get sampleCarDescription =>
      'La Tesla Model 3 est une berline électrique de taille moyenne, reconnue pour ses performances impressionnantes, son accélération et son autonomie.';

  @override
  String get chooseCondition => 'Choisissez la condition';

  @override
  String get chooseBrand => 'Choisissez la marque';

  @override
  String get chooseModel => 'Choisissez le modèle';

  @override
  String get chooseDoorCount => 'Choisissez le nombre de portes';

  @override
  String get chooseGearbox => 'Choisissez la vitesse';

  @override
  String get chooseFuel => 'Choisissez le carburant';

  @override
  String get chooseAirConditioner => 'Choisissez le climatiseur';

  @override
  String get brandsLabel => 'Marques';

  @override
  String get doorSingular => 'Porte';

  @override
  String get seatSingular => 'Siège';

  @override
  String selectedColorLabel(String color) {
    return 'Couleur sélectionnée: $color';
  }

  @override
  String get companyBlOwner => 'Nom de l\'entreprise possédant le BL';

  @override
  String get imagesOptionalMax12 => 'Images (optionnel, max 12)';

  @override
  String get videoOptionalMax500 => 'Vidéo (optionnelle, max 500 Mo)';

  @override
  String get addImagesButton => 'Ajouter des images';

  @override
  String get videoReady => 'Vidéo prête';

  @override
  String mediaSlot(int index) {
    return 'Emplacement $index';
  }

  @override
  String get tapToAddVideo => 'Appuyer pour ajouter';

  @override
  String get sending => 'Envoi...';

  @override
  String videoTooHeavy(String size) {
    return 'La vidéo est trop lourde ($size Mo). Limite: 500 Mo.';
  }

  @override
  String get videoUploadError =>
      'Erreur lors de l\'upload de la vidéo. Veuillez réessayer.';

  @override
  String maxMediaCount(int count) {
    return 'Vous pouvez sélectionner au maximum $count médias.';
  }

  @override
  String get manualTransmission => 'Manuelle';

  @override
  String get automaticTransmission => 'Automatique';

  @override
  String get petrol => 'Essence';

  @override
  String get diesel => 'Diesel';

  @override
  String get electric => 'Électrique';

  @override
  String get hybrid => 'Hybride';

  @override
  String get otherOption => 'Autre';

  @override
  String get pieceName => 'Nom de la pièce';

  @override
  String get enterYearShort => 'Entrer l\'année';

  @override
  String get placement => 'Emplacement';

  @override
  String get enterPartDescription => 'Entrer une description de votre pièce';

  @override
  String get verificationAction => 'Vérification';

  @override
  String uploadFailed(String error) {
    return 'Upload échoué: $error';
  }

  @override
  String videoUploadFailed(String error) {
    return 'Upload vidéo échoué: $error';
  }

  @override
  String selectedModelLabel(String model) {
    return 'Modèle sélectionné : $model';
  }

  @override
  String customModelLabel(String model) {
    return 'Modèle personnalisé : $model';
  }

  @override
  String get enterEngineType => 'Entrez le type de moteur';

  @override
  String get noEngine => 'Aucun';

  @override
  String get gazoil => 'Gazoil';

  @override
  String get addVideo => 'Ajouter une vidéo';

  @override
  String get videoUploadedLabel => 'Vidéo uploadée';

  @override
  String get beforeContactSeller => 'Avant de contacter le vendeur';

  @override
  String get contactSellerTips =>
      '• Confirmez le prix et les frais éventuels\n• Vérifiez la localisation et la disponibilité\n• Échangez clairement sur l\'état du bien\n• Privilégiez un lieu sûr pour la transaction';

  @override
  String get orderWithDelivery => 'Commander avec livraison';

  @override
  String get buyViaApp => 'Acheter via l\'application';

  @override
  String get secureOrderViaCart =>
      'Commande sécurisée via le panier Tranoo (livraison disponible).';

  @override
  String get partTypeLabel => 'Type de pièce';

  @override
  String get ratingOutOf5 => '0 / 5';

  @override
  String get mastervacSampleDescription =>
      'Composant essentiel du système de freinage, le mastervac amplifie la force exercée sur la pédale de frein pour faciliter le freinage.';

  @override
  String get rare => 'Rare';

  @override
  String get sellYourPart => 'Vendez votre pièce';

  @override
  String get newBadge => 'New';

  @override
  String get createAd => 'Créer une publicité';

  @override
  String get adRequest => 'Demande de pub';

  @override
  String get standaloneAd => 'Publicité indépendante';

  @override
  String get existingArticleAd => 'Publicité d\'article existant';

  @override
  String get standaloneAdDesc =>
      'Publicité À la une indépendante. Téléchargez un flyer (1080 x 1350 px recommandé) et ajoutez un lien optionnel vers votre site ou votre catalogue.';

  @override
  String get nonExistingPubDesc =>
      'Publication non existante. Vous créez une publication non existante. Les utilisateurs pourront cliquer pour voir les détails de votre offre.';

  @override
  String get existingArticlePubDesc =>
      'Vous créez une publicité pour un article existant. Les utilisateurs pourront cliquer pour voir l\'article complet.';

  @override
  String get loadingArticleInfo =>
      'Chargement des informations de l\'article...';

  @override
  String get articleLoadedSuccess =>
      'Article chargé avec succès ! Vous pouvez maintenant faire une publicité pour cet article.';

  @override
  String get linkExampleHint =>
      'Ex: https://wa.me/2250700000000 ou https://mon-site.com';

  @override
  String get linkHelperText =>
      'Permettre aux utilisateurs d\'ouvrir votre site, catalogue ou formulaire de paiement.';

  @override
  String get selectAdType => 'Veuillez sélectionner un type';

  @override
  String get selectDuration => 'Veuillez sélectionner une durée';

  @override
  String get sponsoredType => 'Sponsorisée';

  @override
  String get featuredType => 'À la une';

  @override
  String get oneWeek => '1 semaine';

  @override
  String get twoWeeks => '2 semaines';

  @override
  String get oneMonth => '1 mois';

  @override
  String get twoMonths => '2 mois';

  @override
  String get threeMonths => '3 mois';

  @override
  String pricePerDayLabel(String price) {
    return '$price/jour';
  }

  @override
  String get carInfoSection => 'Informations concernant la voiture';

  @override
  String get enterName => 'Veuillez entrer le nom';

  @override
  String get enterYearValidator => 'Veuillez entrer l\'année';

  @override
  String get enterLocationValidator => 'Veuillez entrer la localisation';

  @override
  String get enterPriceValidator => 'Veuillez entrer le prix';

  @override
  String get enterDescriptionValidator => 'Veuillez entrer une description';

  @override
  String get enterCompanyValidator => 'Veuillez entrer le nom de l\'entreprise';

  @override
  String get selectEngineTypeValidator =>
      'Veuillez sélectionner le type de moteur';

  @override
  String get selectModelValidator => 'Veuillez sélectionner le modèle';

  @override
  String get selectTypeValidator => 'Veuillez sélectionner le type';

  @override
  String get mainFlyerImage => 'Image principale (flyer)';

  @override
  String get recommendedDimensions =>
      'Dimensions recommandées : 1080 x 1350 px (PNG/JPG)';

  @override
  String get addMainImage => 'Ajouter image principale';

  @override
  String get dimensions1080x1350 => '1080 x 1350 px';

  @override
  String get additionalImagesOptional => 'Images supplémentaires (optionnel)';

  @override
  String get standaloneFeaturedTitle => 'Publicité À la une';

  @override
  String get standaloneFeaturedDesc =>
      'Flyer dédié, pas besoin d\'article existant. Ajoutez simplement votre visuel et (optionnellement) un lien externe.';

  @override
  String get addMainImageForFeatured =>
      'Veuillez ajouter une image principale pour \"À la une\".';

  @override
  String get articleCreateError => 'Erreur lors de la création de l\'article.';

  @override
  String articleCreateNetworkError(String error) {
    return 'Erreur réseau lors de la création de l\'article: $error';
  }

  @override
  String get articleLoadError => 'Erreur lors du chargement de l\'article';

  @override
  String get articleLoadNetworkError =>
      'Erreur réseau lors du chargement de l\'article';

  @override
  String mediaUploadError(String error) {
    return 'Erreur lors de l\'upload des médias: $error';
  }

  @override
  String get fillAllFieldsShort => 'Veuillez remplir tous les champs.';

  @override
  String get articleNotExistCreateFirst =>
      'Cet article n\'existe pas, veuillez le créer et après validation par l\'admin vous pourrez le mettre en avant.';

  @override
  String get articleNotExistFeaturedFirst =>
      'Cet article n\'existe pas. Pour les pubs \"À la une\", veuillez d\'abord créer l\'article et après validation par l\'admin vous pourrez le mettre en avant.';

  @override
  String get articleCreateRetryError =>
      'Erreur lors de la création de l\'article. Veuillez réessayer.';

  @override
  String get paymentSuccessPendingValidation =>
      'Paiement réussi, en attente de validation admin. Vous recevrez une notification dès validation.';

  @override
  String pubForTitle(String title) {
    return 'Publicité pour $title';
  }

  @override
  String get noDescriptionAd => 'Publicité sans description';

  @override
  String get defaultCarName => 'Nom de la voiture';

  @override
  String get defaultLocation => 'Localisation';

  @override
  String get defaultPrice => 'Prix';

  @override
  String get defaultCarDescription => 'Description de la voiture';

  @override
  String get defaultCompanyName => 'Nom de l\'entreprise';

  @override
  String get defaultBrand => 'Marque';

  @override
  String get standaloneFeaturedDescriptionDefault =>
      'Publicité À la une (flyer vitrine Tranoo)';

  @override
  String get perMonth => 'par mois';

  @override
  String get boostVisibilitySubtitle =>
      'Boostez votre visibilité auprès des clients';

  @override
  String get premiumBenefits => 'Avantages Premium';

  @override
  String get prioritySpotlight => 'Mise en avant prioritaire';

  @override
  String get prioritySpotlightDesc =>
      'Apparaissez en premier dans les recherches';

  @override
  String get premiumBadge => 'Badge Premium';

  @override
  String get premiumBadgeDesc => 'Badge doré visible sur votre profil';

  @override
  String get boostedVisibility => 'Visibilité boostée';

  @override
  String get boostedVisibilityDesc => 'Plus de clients vous contactent';

  @override
  String get prioritySupport => 'Support prioritaire';

  @override
  String get prioritySupportDesc => 'Assistance dédiée 24h/7j';

  @override
  String get monthlySubscription => 'Abonnement Mensuel';

  @override
  String get subscriptionAutoRenewNote =>
      'Votre abonnement sera automatiquement renouvelé chaque mois. Vous pouvez l\'annuler à tout moment.';

  @override
  String subscribeNowPrice(String price) {
    return 'Souscrire maintenant - $price FCFA';
  }

  @override
  String get userNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get feexpayConfigMissing => 'Configuration FeexPay manquante';

  @override
  String get feexpayConfigMissingDetailed =>
      'Configuration FeexPay manquante (FP_TOKEN_FEEXPAY / ID_USER_FEEXPAY)';

  @override
  String get verificationFeesTitle => 'Frais de vérification';

  @override
  String get documentVerification => 'Vérification de documents';

  @override
  String get verifyDocumentsAuthenticity =>
      'Vérifiez l\'authenticité de vos documents';

  @override
  String get includedServices => 'Services inclus';

  @override
  String get fullVerification => 'Vérification complète';

  @override
  String get fullVerificationDesc => 'Contrôle de tous vos documents officiels';

  @override
  String get fastProcessing => 'Traitement rapide';

  @override
  String get fastProcessingDesc => 'Résultats sous 10 jours ouvrables';

  @override
  String get oneTimePayment => 'paiement unique';

  @override
  String get verificationPaymentNote =>
      'Après paiement, vous recevrez un récapitulatif et les vérifications seront effectuées sous 10 jours ouvrables.';

  @override
  String proceedToPayment(String price) {
    return 'Procéder au paiement - $price FCFA';
  }

  @override
  String get paymentReceivedIncompleteRecord =>
      'Paiement reçu mais enregistrement serveur incomplet. Réessayez ou contactez le support.';

  @override
  String get paymentReceivedVerificationProcessing =>
      'Paiement reçu. Votre demande de vérification est en cours de traitement.';

  @override
  String get paymentCancelledNotConfirmed =>
      'Paiement annulé ou non confirmé. Réessayez si besoin.';

  @override
  String get cannotLoadData => 'Impossible de charger les données';

  @override
  String get recommendedForwarders => 'Transitaires recommandés';

  @override
  String get seeMoreForwarders => 'Voir plus de transitaires';

  @override
  String get forwarderPremiumBadge => 'Abonné premium';

  @override
  String get forwarderVerifiedBadge => 'Vérifié';

  @override
  String get forwarderStandardBadge => 'Transitaire';

  @override
  String get internationalTransit => 'Transit international';

  @override
  String get noForwardersAvailable => 'Aucun transitaire disponible';

  @override
  String get forwarderSubscribedShort => 'Abonné';

  @override
  String get forwarderStandardShort => 'Standard';

  @override
  String get forwardersTitle => 'Transitaires';

  @override
  String get forwarderTabStarred => 'Étoilé';

  @override
  String get forwarderTabAll => 'Tout';

  @override
  String get viewProfile => 'Voir profil';

  @override
  String galleryMediaCount(int count) {
    return '$count médias';
  }

  @override
  String subscribedSince(String date) {
    return 'Abonné depuis le $date';
  }

  @override
  String get noStarredForwarders => 'Aucun transitaire étoilé.';

  @override
  String get transitaireProfileTabGallery => 'Galerie';

  @override
  String get transitaireGalleryEmpty => 'Aucune photo ou vidéo pour le moment.';

  @override
  String get transitaireGalleryEmptyOwner =>
      'Appuyez sur + pour ajouter des photos ou vidéos.';

  @override
  String get transitaireGalleryAddTitle => 'Ajouter à la galerie';

  @override
  String get transitaireGalleryPhotosMulti => 'Photos (une ou plusieurs)';

  @override
  String get transitaireGalleryVideo => 'Vidéo';

  @override
  String get transitaireGalleryUploadingPhotos => 'Envoi des photos…';

  @override
  String get transitaireGalleryUploadingVideo => 'Envoi de la vidéo…';

  @override
  String get transitaireGalleryUploadFailed => 'Échec de l\'upload. Réessayez.';

  @override
  String get transitaireGallerySaveError =>
      'Erreur lors de la sauvegarde de la galerie.';

  @override
  String get transitaireGalleryUploadError => 'Erreur lors de l\'upload.';

  @override
  String get transitaireGalleryDeleteTitle => 'Supprimer ?';

  @override
  String get transitaireGalleryDeleteConfirm =>
      'Retirer cet élément de la galerie ?';

  @override
  String get transitaireGalleryDeleteFailed => 'Suppression impossible.';

  @override
  String transitaireGalleryMaxItems(int count) {
    return 'Limite de $count éléments atteinte.';
  }

  @override
  String get videoPlaybackError => 'Impossible de lire la vidéo';

  @override
  String get contactPhoneUnavailable => 'Numéro de contact indisponible.';

  @override
  String get transitaireDefaultName => 'Transitaire';

  @override
  String get transitaireServicesSubtitle => 'Services de transit international';

  @override
  String get transitaireDescriptionLabel => 'Description (optionnelle)';

  @override
  String get transitaireDescriptionHint => 'Décrivez vos services de transit…';

  @override
  String get transitaireBadgeLabel => 'Transitaire';

  @override
  String get westAfricaDefault => 'Afrique de l\'Ouest';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get actions => 'Actions';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get filterTypeTab => 'Type';

  @override
  String get filterBrandTab => 'Marque';

  @override
  String get filterLocationTab => 'Localisation';

  @override
  String get pieceTypeSpareParts => 'Pièces détachées';

  @override
  String get pieceTypeTires => 'Pneus';

  @override
  String get pieceTypeOils => 'Huiles et lubrifiants';

  @override
  String get pieceTypeBatteries => 'Batteries';

  @override
  String get pieceTypeAccessories => 'Accessoires';

  @override
  String get forwarderSubscription => 'Abonnement Transitaire';

  @override
  String get activateMonthlySubscription =>
      'Activez un abonnement mensuel pour être mis en avant auprès des acheteurs.';

  @override
  String pricePerMonth(String price) {
    return '$price FCFA / mois';
  }

  @override
  String activatedOn(String date) {
    return 'Activé le: $date';
  }

  @override
  String expiresOn(String date) {
    return 'Expire le: $date';
  }

  @override
  String get manage => 'Gérer';

  @override
  String get visibility => 'Visibilité';

  @override
  String get boosted => 'Boostée';

  @override
  String get spotlight => 'Mises en avant';

  @override
  String get subscriptionStatus => 'Statut d\'abonnement';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get noActiveSubscription => 'Aucun abonnement actif';

  @override
  String get performances => 'Performances';

  @override
  String get ordersDeliveredPerMonth => 'Commandes livrées / mois';

  @override
  String get clientDistribution => 'Répartition des clients';

  @override
  String get chartBuyers => 'Acheteurs';

  @override
  String get chartDrivers => 'Chauffeurs';

  @override
  String get chartOthers => 'Autres';

  @override
  String get discuss => 'Discuter';

  @override
  String priceWithValue(String price) {
    return 'Prix: $price';
  }

  @override
  String get priceNotSpecified => 'Non spécifié';

  @override
  String get sellerInfoError =>
      'Erreur: Impossible de récupérer les informations du vendeur';

  @override
  String get transitHistoryTitle => 'Historiques des transits';

  @override
  String clientLabel(String name) {
    return 'Client : $name';
  }

  @override
  String departurePortLabel(String port) {
    return 'Port de départ : $port';
  }

  @override
  String arrivalPortLabel(String port) {
    return 'Port d\'arrivée : $port';
  }

  @override
  String transitDateLabel(String date) {
    return 'Date de transit : $date';
  }

  @override
  String statusWithValue(String status) {
    return 'Statut : $status';
  }

  @override
  String get deliveredSuccessfully => 'Livré avec succès';

  @override
  String get atCustoms => 'En douane';

  @override
  String get billOfLading => 'Connaissement';

  @override
  String get proformaInvoice => 'Facture Proforma';

  @override
  String get transitCertificate => 'Certificat de transit';

  @override
  String get partialCustomsCertificate => 'Attestation de dédouanement partiel';

  @override
  String get inspectionCertificate => 'Certificat d\'inspection';

  @override
  String get transitFormTitle => 'Formulaires de transit';

  @override
  String get carNameLabel => 'Nom de la voiture';

  @override
  String get clientField => 'Client';

  @override
  String get departurePort => 'Port de départ';

  @override
  String get arrivalPort => 'Port d\'arrivée';

  @override
  String get transitDate => 'Date de transit';

  @override
  String get uploadDocuments => 'Télécharger les documents';

  @override
  String get registrationForm => 'Formulaire d\'inscription';

  @override
  String get familyName => 'Nom de famille';

  @override
  String get enterYourName => 'Entrer votre nom';

  @override
  String get enterYourFirstName => 'Entrer votre prénom';

  @override
  String get typeYourPhone => 'Tapez votre numéro de Téléphone';

  @override
  String get enterYourEmail => 'Entrer votre mail';

  @override
  String get licenseNumber => 'Numéro de permit';

  @override
  String get enterLicenseNumber => 'Entrer votre numéro de permit';

  @override
  String get messages => 'Messages';

  @override
  String get writeYourMessage => 'Écrivez votre message';

  @override
  String get uploadImagesLabel => 'Télécharger des images';

  @override
  String get myLicensePdf => 'Mon permis pdf';

  @override
  String get fillFieldsAndUploadLicense =>
      'Veuillez remplir tous les champs obligatoires et uploader votre permis.';

  @override
  String get requestSentSuccess => 'Demande envoyée avec succès !';

  @override
  String sendErrorWithBody(String body) {
    return 'Erreur lors de l\'envoi : $body';
  }

  @override
  String timeAgoDays(int count) {
    return 'Il y a $count jour(s)';
  }

  @override
  String timeAgoHours(int count) {
    return 'Il y a ${count}h';
  }

  @override
  String timeAgoMinutes(int count) {
    return 'Il y a $count min';
  }

  @override
  String get checkingPermissions => 'Vérification des autorisations...';

  @override
  String get redirectingIfNeeded => 'Redirection en cours si nécessaire';

  @override
  String get unauthorizedAccess => 'Accès non autorisé';

  @override
  String get tricycle_home_title => 'Tricycles';

  @override
  String get tricycle_request_accepted => 'Demande acceptée';

  @override
  String get tricycle_request_sent => 'Demande envoyée';

  @override
  String get tricycle_order_command => 'Commander · Tricycle';

  @override
  String get feexpayPaymentTitle => 'Paiement FeexPay';

  @override
  String get feexpayInitSuccess => 'Service FeexPay initialisé avec succès';

  @override
  String feexpayInitError(String error) {
    return 'Erreur lors de l\'initialisation: $error';
  }

  @override
  String get paymentInitSuccess => 'Paiement initialisé avec succès!';

  @override
  String get cannotOpenPaymentPage =>
      'Impossible d\'ouvrir la page de paiement';

  @override
  String get transactionDetailsTitle => 'Détails de la transaction';

  @override
  String get labelTransactionId => 'ID Transaction';

  @override
  String valueAmountFcfa(String amount) {
    return '$amount FCFA';
  }

  @override
  String get enterAmount => 'Veuillez saisir le montant';

  @override
  String get enterValidAmount => 'Veuillez saisir un montant valide';

  @override
  String get amountMustBePositive => 'Le montant doit être supérieur à 0';

  @override
  String get enterDescriptionRequired => 'Veuillez saisir une description';

  @override
  String get enterOrderId => 'Veuillez saisir un ID de commande';

  @override
  String get commandIdLabel => 'ID de commande';

  @override
  String get paymentTypeLabel => 'Type de paiement';

  @override
  String get mobileMoneyProviders => 'Mobile Money (MTN, Moov, Orange)';

  @override
  String get bankCardPayment => 'Carte bancaire (VISA, Mastercard)';

  @override
  String get feexpayWallet => 'Portefeuille FeexPay';

  @override
  String get initializeFeexpay => 'Initialiser FeexPay';

  @override
  String get aboutFeexpay => 'À propos de FeexPay';

  @override
  String get feexpayAboutDescription =>
      'FeexPay est un agrégateur de paiement sécurisé qui accepte :';

  @override
  String get feexpayAcceptedMethods =>
      '• MTN Mobile Money, Moov Money, Orange Money\n• Cartes VISA et Mastercard\n• Portefeuilles numériques';

  @override
  String get feexpayTransactionsTitle => 'Transactions FeexPay';

  @override
  String transactionsLoadError(String error) {
    return 'Erreur lors du chargement: $error';
  }

  @override
  String get processRefundTitle => 'Effectuer un reversement';

  @override
  String transactionWithId(String id) {
    return 'Transaction: $id';
  }

  @override
  String get refundAmountFcfa => 'Montant à rembourser (FCFA)';

  @override
  String get refundReason => 'Raison du remboursement';

  @override
  String get refundAction => 'Rembourser';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get refundSuccess => 'Remboursement effectué avec succès';

  @override
  String get transactionHistory => 'Historique des transactions';

  @override
  String transactionCount(int count) {
    return '$count transaction(s)';
  }

  @override
  String get accountBalanceLabel => 'Solde du compte';

  @override
  String currencyWithValue(String currency) {
    return 'Devise: $currency';
  }

  @override
  String get noTransactionsFound => 'Aucune transaction trouvée';

  @override
  String get transactionsEmptyHint =>
      'Les transactions apparaîtront ici après vos premiers paiements';

  @override
  String get transactionNoDescription => 'Transaction sans description';

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
    return 'Méthode: $method';
  }

  @override
  String get unknownDate => 'Date inconnue';

  @override
  String get customerEmailLabel => 'Email client';

  @override
  String get accountBlockedTitle => 'Compte Bloqué';

  @override
  String get accountBlockedDialogMessage =>
      'Vous ne pouvez pas accéder à l\'application car l\'administrateur vous a temporairement bloqué.';

  @override
  String get contactSupportTeam =>
      'Contactez l\'équipe support pour plus d\'informations.';

  @override
  String get driverArrivedTitle => 'Votre livreur est arrivé';

  @override
  String get chooseAnAction => 'Choisissez une action.';

  @override
  String get orderTotalLabel => 'Total commande';

  @override
  String get deliveryFeesLabel => 'Frais livraison';

  @override
  String get payMyOrder => 'Payer ma commande';

  @override
  String get returnReasonRequiredTitle => 'Motif de retour (obligatoire)';

  @override
  String get partsOrderPaymentLabel => 'Paiement commande pièces';

  @override
  String get deliveryFeePaymentLabel => 'Paiement frais de livraison';

  @override
  String get fileDownloadFailed => 'Impossible de télécharger le fichier';

  @override
  String get tranooDocumentShare => 'Document Tranoo';

  @override
  String refWithId(String id) {
    return 'Réf. $id';
  }

  @override
  String get attachedImages => 'Images jointes';

  @override
  String get attachedDocuments => 'Documents joints';

  @override
  String get stampAndSignature => 'Cachet et signature';

  @override
  String get reject => 'Rejeter';

  @override
  String get downloadReportPdf => 'Télécharger le rapport PDF';

  @override
  String imageWithIndex(int index) {
    return 'Image $index';
  }

  @override
  String documentWithIndex(int index) {
    return 'Document $index';
  }

  @override
  String get buyerAlert => 'Alerte acheteur';

  @override
  String get swipeUpOrTap => 'Glissez vers le haut ou appuyez';

  @override
  String get decline => 'Refuser';

  @override
  String get answer => 'Répondre';

  @override
  String get newAlertTitle => 'Nouvelle alerte';

  @override
  String get sellerRespondedToAlert => 'Un vendeur a répondu à votre alerte';

  @override
  String get videoAvailable => 'Vidéo disponible';

  @override
  String get withdrawalProcessingMessage =>
      'Votre demande est en cours de traitement et vous recevez une confirmation une fois le retrait effectué. Si vous avez des questions ou si vous souhaitez apporter des modifications à votre demande, n\'hésitez pas à nous contacter. Merci pour votre confiance.';

  @override
  String get departurePortField => 'Port de départ';

  @override
  String get arrivalPortField => 'Port d\'arrivée';

  @override
  String get transitDateField => 'Date de transit';

  @override
  String get carNameExample => 'Toyota Corolla 2018';

  @override
  String get clientExample => 'Marcel T';

  @override
  String get departurePortExample => 'Anvers, Belgique';

  @override
  String get arrivalPortExample => 'Cotonou, Bénin';

  @override
  String get transitDateExample => '10 avril 2025';

  @override
  String timeAgoMinutesLong(int count) {
    return 'Il y a $count minutes';
  }

  @override
  String notificationsSelectedCount(int count) {
    return '$count sélectionnée(s)';
  }

  @override
  String confirmDeleteNotificationsCount(int count) {
    return 'Supprimer $count notification(s) ?';
  }

  @override
  String get newRequest => 'Nouvelle demande';

  @override
  String budgetAmountFcfa(String amount) {
    return 'Budget $amount FCFA';
  }

  @override
  String get alertProposalForYourAlert => 'Proposition pour votre alerte';

  @override
  String whatsappInterestWithRef(String title, String articleId) {
    return 'Bonjour Tranoo, je confirme mon intérêt pour l\'achat : $title (réf. $articleId).';
  }

  @override
  String whatsappInterestNoRef(String title) {
    return 'Bonjour Tranoo, je confirme mon intérêt pour l\'achat : $title.';
  }

  @override
  String get defaultVehicleTitle => 'véhicule';

  @override
  String get cannotLoadOrders => 'Impossible de charger vos commandes';

  @override
  String get noOrdersYetHint => 'Vous n\'avez pas encore passé de commande';

  @override
  String get filterRejected => 'Rejetée';

  @override
  String get filterTracking => 'Tracking';

  @override
  String get finishedOrdersHiddenHint =>
      'Vos commandes terminées ou annulées n\'apparaissent pas ici';

  @override
  String orderCmdNumber(String id) {
    return 'CMD #$id';
  }

  @override
  String get orderStatusPending => 'En attente';

  @override
  String get orderStatusConfirmed => 'Confirmée';

  @override
  String get orderStatusPreparing => 'En préparation';

  @override
  String get orderStatusReady => 'Prête';

  @override
  String get orderStatusDelivering => 'En livraison';

  @override
  String get orderStatusDelivered => 'Livrée';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get orderStatusDriverAssigned => 'Livreur assigné';

  @override
  String get tranooDelivery => 'Tranoo Delivery';

  @override
  String get driverLabel => 'Livreur';

  @override
  String get addressNotSpecified => 'Adresse non spécifiée';

  @override
  String quantityLabel(int qty) {
    return 'Qté: x$qty';
  }

  @override
  String get deliveryDetails => 'Détails de la livraison';

  @override
  String get driverAssignmentPending => 'Affectation en cours';

  @override
  String get defaultLocationCotonou => 'Cotonou, Bénin';

  @override
  String apiErrorWithDetails(String status, String details) {
    return 'Erreur API ($status) : $details';
  }

  @override
  String get monthJan => 'JAN';

  @override
  String get monthFeb => 'FEV';

  @override
  String get monthMar => 'MAR';

  @override
  String get monthApr => 'AVR';

  @override
  String get monthMay => 'MAI';

  @override
  String get monthJun => 'JUI';

  @override
  String get monthJul => 'JUL';

  @override
  String get monthAug => 'AOU';

  @override
  String get monthSep => 'SEP';

  @override
  String get monthOct => 'OCT';

  @override
  String get monthNov => 'NOV';

  @override
  String get monthDec => 'DEC';

  @override
  String get fetchingLocation => 'Récupération...';

  @override
  String get fetchMyLocation => 'Récupérer ma position';

  @override
  String get chooseOnMap => 'Choisir sur la carte';

  @override
  String get currentPositionLabel => 'Position actuelle';

  @override
  String get selectedPositionLabel => 'Position sélectionnée';

  @override
  String coordinatesLabel(String lat, String lng) {
    return 'Lat: $lat\nLon: $lng';
  }

  @override
  String get availability => 'Disponibilité';

  @override
  String get deliveryFeeLabel => 'Frais de livraison';

  @override
  String get processingOrder => 'Traitement en cours...';

  @override
  String get supplierCoordsUnavailable =>
      'Coordonnées fournisseur indisponibles pour calculer la livraison.';

  @override
  String get invalidCoordinates => 'Coordonnées invalides';

  @override
  String get selectionCancelled => 'Sélection annulée';

  @override
  String mapSelectionError(String error) {
    return 'Erreur lors de la sélection de la carte: $error';
  }

  @override
  String get locationRetrievedSuccess =>
      'Position actuelle récupérée avec succès !';

  @override
  String get deliveryAddressSelectedOnMap =>
      'Adresse de livraison sélectionnée sur la carte !';

  @override
  String get enableLocationInSettingsMsg =>
      'Activez la localisation dans les paramètres';

  @override
  String locationError(String error) {
    return 'Erreur de localisation: $error';
  }

  @override
  String get invalidDeliveryAddress => 'Adresse de livraison invalide';

  @override
  String get selectDeliveryAddressPlease =>
      'Veuillez sélectionner une adresse de livraison';

  @override
  String get confirmYourOrder => 'Confirmer votre commande';

  @override
  String totalToPay(String amount) {
    return 'Total à payer: $amount F';
  }

  @override
  String get transactionFailedNotSaved =>
      'Transaction échouée/annulée. Commande non enregistrée.';

  @override
  String get orderConfirmedTitle => 'Commande confirmée !';

  @override
  String get orderSavedSuccess =>
      'Votre commande a été enregistrée avec succès.';

  @override
  String get deliveryExpected => 'Livraison prévue';

  @override
  String get deliveryBetween3And7Days => 'Entre 3 et 7 jours ouvrables';

  @override
  String get youWillReceiveNotification => 'Vous recevrez une notification';

  @override
  String get availAvailable => 'Disponible';

  @override
  String get avail15to30min => 'Dans 15-30 min';

  @override
  String get avail1to2h => 'Dans 1h-2h';

  @override
  String get availBefore12 => 'Avant 12h';

  @override
  String get availBefore18 => 'Avant 18h';

  @override
  String get availBefore20 => 'Avant 20h';

  @override
  String get availFlexible => 'Flexible';

  @override
  String get supplierDefault => 'Fournisseur';

  @override
  String get supplierAddressDefault => 'Adresse fournisseur';

  @override
  String orderSaveError(String error) {
    return 'Erreur lors de la sauvegarde de la commande: $error';
  }

  @override
  String positionCoords(String lat, String lng) {
    return 'Position: $lat, $lng';
  }

  @override
  String get orderPaymentTranooDescription => 'Paiement commande Tranoo';

  @override
  String get mobileMoneyPayment => 'Paiement Mobile Money';

  @override
  String get adDetailsTitle => 'Détails de votre publicité';

  @override
  String get amountToPay => 'Montant à payer';

  @override
  String get viaMobileMoney => 'via Mobile Money';

  @override
  String get supportedOperators => 'Opérateurs supportés';

  @override
  String get afterPaymentAdValidationNote =>
      'Après paiement, votre publicité sera soumise à validation admin avant publication.';

  @override
  String payAmountFcfa(String amount) {
    return 'Payer $amount FCFA';
  }

  @override
  String get adForYourListing => 'Publicité pour votre article';

  @override
  String adPaymentMobileDescription(String pubId) {
    return 'Paiement publicité (mobile money) $pubId';
  }

  @override
  String get durationLabel => 'Durée';

  @override
  String get invoicesLoadError => 'Impossible de charger les factures';

  @override
  String get signInForInvoices => 'Connectez-vous pour accéder à vos factures';

  @override
  String get noInvoicesYet => 'Vous n\'avez aucune facture pour le moment.';

  @override
  String get unreadLabel => 'Non lue';

  @override
  String get filterByDate => 'Filtrer par date';

  @override
  String get filterAllDates => 'Toutes';

  @override
  String get filterToday => 'Aujourd\'hui';

  @override
  String get filterThisWeek => 'Cette semaine';

  @override
  String get filterThisMonth => 'Ce mois';

  @override
  String get filterCustom => 'Personnalisée';

  @override
  String selectedDateLabel(String date) {
    return 'Date sélectionnée: $date';
  }

  @override
  String get invoicePreview => 'Aperçu facture';

  @override
  String get transactionSuccessTitle => 'Transaction Success';

  @override
  String transactionNumber(String ref) {
    return 'Transaction number $ref';
  }

  @override
  String get dateTimeLabel => 'Date & time';

  @override
  String get productLabel => 'Produit';

  @override
  String get sellerLabel => 'Vendeur';

  @override
  String get shopLabel => 'Boutique';

  @override
  String get fundsSourceLabel => 'Source de fonds';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get referenceLabel => 'Référence';

  @override
  String get productDetails => 'Détails des produits:';

  @override
  String get productPriceLabel => 'Prix du produit';

  @override
  String get deliveryPriceLabel => 'Prix de livraison';

  @override
  String get vatLabel => 'TVA';

  @override
  String get totalTransaction => 'Total transaction';

  @override
  String get tranooSupport => 'Support Tranoo';

  @override
  String get thankYouForTrust => 'Merci pour votre confiance ';

  @override
  String get officialInvoiceDisclaimer =>
      'Cette facture est un document officiel. En cas de litige, veuillez contacter notre support.';

  @override
  String get saveInvoiceImage => 'Enregistrer la facture (image)';

  @override
  String get saveInvoiceDocument => 'Enregistrer la facture (document)';

  @override
  String get imageSavedSuccess => 'Image sauvegardée avec succès';

  @override
  String get imageSaveFailed => 'Échec de sauvegarde de l\'image';

  @override
  String get documentSavedSuccess => 'Document PDF sauvegardé avec succès';

  @override
  String get documentSaveFailed => 'Échec de sauvegarde du document PDF';

  @override
  String get captureUnavailable => 'Capture indisponible';

  @override
  String get imageGenerationFailed => 'Impossible de générer l\'image';

  @override
  String get paidStatus => 'Payée';

  @override
  String get pendingPaymentStatus => 'En attente';

  @override
  String get sellerDefault => 'Vendeur';

  @override
  String get shopDefault => 'Boutique';

  @override
  String invoiceTitle(String number) {
    return 'FACTURE $number';
  }

  @override
  String get purchasesLoadError => 'Erreur lors du chargement des achats';

  @override
  String purchaseStatusLabel(String status) {
    return 'Statut : $status';
  }

  @override
  String deliveryDateLabel(String date) {
    return 'Date de livraison : $date';
  }

  @override
  String deliveryLocationLabel(String location) {
    return 'Lieu de livraison : $location';
  }

  @override
  String fuelTypeLabel(String type) {
    return 'Type de carburant : $type';
  }

  @override
  String colorLabel(String color) {
    return 'Couleur : $color';
  }

  @override
  String publishedOn(String date) {
    return 'Publié le $date';
  }

  @override
  String ratingOutOf(int rating) {
    return '$rating/5';
  }

  @override
  String get minutesAgo2 => 'Il y a 2 min';

  @override
  String get inProgressStatus => 'En cours';

  @override
  String get yearDropdown => 'Année';

  @override
  String get cardPlaceholderName => 'Rencontrez Patel';

  @override
  String get cardNumberPlaceholder => '0000 0000 0000 0000';

  @override
  String paymentFormFor(String name) {
    return 'Formulaire de Paiement pour $name';
  }

  @override
  String partNameLabelShort(String name) {
    return 'Nom de la pièce: $name';
  }

  @override
  String get untitled => 'Sans titre';

  @override
  String get unknownCompany => 'Entreprise inconnue';

  @override
  String get piecesLoadError => 'Erreur lors du chargement des pièces';

  @override
  String get carsLoadError => 'Erreur lors du chargement des voitures';

  @override
  String get adsLoadError => 'Erreur lors du chargement des publicités';

  @override
  String get dataFormatError => 'Erreur de format de données';

  @override
  String get filterModelsTab => 'Modèles';

  @override
  String get filterBudgetTab => 'Budget';

  @override
  String get noCarsAvailable => 'Aucune voiture disponible pour le moment.';

  @override
  String get noPartsAvailableOnline => 'Aucune pièce en ligne actuellement';

  @override
  String get noCarsOnlineSeller => 'Vous n\'avez aucune voiture en ligne';

  @override
  String get noPartsOnlineSeller =>
      'Vous n\'avez aucune pièce en ligne actuellement';

  @override
  String doorsCountLabel(String count) {
    return '$count portes';
  }

  @override
  String get sponsoredLabel => 'Sponsorisé';

  @override
  String get chooseTypeTitle => 'Choisissez le type';

  @override
  String youTyped(String text) {
    return 'Vous avez tapé: \"$text\"';
  }

  @override
  String get whatArticleTypeSearch => 'Quel type d\'article recherchez-vous ?';

  @override
  String get vehicleSingular => 'Véhicule';

  @override
  String get partSingular => 'Pièce';

  @override
  String get unknownArticleType => 'Type d\'article inconnu.';

  @override
  String get urgencyLevel => 'Niveau d\'urgence';

  @override
  String get partNameRequired => 'Nom de la piece requis';

  @override
  String showVehiclesCount(int count) {
    return 'Afficher $count véhicule(s)';
  }

  @override
  String get buyerSearchingPartShort => 'Un acheteur recherche une piece';

  @override
  String get buyerSearchingVehicleShort => 'Un acheteur recherche un vehicule';

  @override
  String get validateLocation => 'Valider';

  @override
  String get colorField => 'Couleur';

  @override
  String get pubRequestCreateError =>
      'Erreur lors de la création de la demande.';

  @override
  String get videoOptional => 'Vidéo (optionnelle)';

  @override
  String get viewListing => 'Voir l\'annonce';

  @override
  String get enlarge => 'Agrandir';

  @override
  String get networkError => 'Erreur réseau';

  @override
  String get cannotGenerateImage => 'Impossible de générer l\'image';

  @override
  String get errorLoadingArticle => 'Erreur lors du chargement de l\'article.';

  @override
  String get conditionNew => 'Nouveau';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get budgetMinHint => 'Budget min';

  @override
  String get budgetMaxHint => 'Budget max';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get tvaLabel => 'TVA';

  @override
  String get deliveryLabelShort => 'Livraison';

  @override
  String get totalLabelShort => 'Total';

  @override
  String get articleLabel => 'Article';

  @override
  String get urgencyLabel => 'Urgence';

  @override
  String invoicesLoadErrorDetail(String status, String message) {
    return 'Impossible de charger les factures ($status) : $message';
  }

  @override
  String get verifyProPermissions =>
      'Vérification des autorisations professionnelles...';

  @override
  String get advertisingLabel => 'Publicité';

  @override
  String get sellerTypeLabel => 'Type de vendeur';

  @override
  String get deliveryToLabel => 'Livraison à';

  @override
  String get cashLabel => 'Espèces';

  @override
  String get onlineLabel => 'En ligne';

  @override
  String placeOrderButton(String total) {
    return 'Commander • $total F';
  }

  @override
  String get cashOnDeliveryTitle => 'Paiement à la livraison';

  @override
  String get cashOnDeliveryChosen =>
      'Vous avez choisi le paiement à la livraison.';

  @override
  String get cashOnDeliveryBilled =>
      'Vous serez facturé lors de la réception de votre commande.';

  @override
  String get previewLabel => 'Aperçu';

  @override
  String get changesSaved => 'Modifications enregistrées.';

  @override
  String saveErrorStatus(String status) {
    return 'Erreur sauvegarde: $status';
  }

  @override
  String saveErrorGeneric(String error) {
    return 'Erreur sauvegarde: $error';
  }

  @override
  String get itemAddedToCart => 'Article ajouté au panier';

  @override
  String get modifyPart => 'Modifier la pièce';

  @override
  String get someImagesNotAdded =>
      'Certaines images n\'ont pas pu être ajoutées:';

  @override
  String imagesAddedSuccess(int count) {
    return '$count image(s) ajoutée(s) avec succès';
  }

  @override
  String unsupportedFormat(String formats) {
    return 'Format non supporté. Formats acceptés: $formats';
  }

  @override
  String get loadingProfile => 'Chargement du profil...';

  @override
  String phoneWithNumber(String number) {
    return 'Tél. $number';
  }

  @override
  String get phoneNotProvided =>
      'Téléphone non renseigné — complétez votre profil';

  @override
  String get locationMissingProfile =>
      'Localisation manquante — mettez à jour votre position dans le profil.';

  @override
  String get profileContactLocationHint =>
      'Téléphone et localisation repris de votre inscription. Mettez à jour votre profil si besoin.';

  @override
  String get vehicleLocationLabel => 'Localisation du véhicule';

  @override
  String get profileLocationReuse =>
      'Reprise de votre position enregistrée à l\'inscription (profil).';

  @override
  String get noProfileLocation =>
      'Aucune position sur le profil — mettez à jour votre position dans Profil.';

  @override
  String get descriptionNotProvided => 'Description non renseignée';

  @override
  String get mileageLabel => 'Kilométrage';

  @override
  String get maxImages12 => 'Maximum d\'images atteint (12 images)';

  @override
  String get maxImages10 => 'Maximum d\'images atteint (10 images)';

  @override
  String cameraError(String error) {
    return 'Erreur caméra: $error';
  }

  @override
  String selectionError(String error) {
    return 'Erreur lors de la sélection: $error';
  }

  @override
  String imageAdded(String name) {
    return 'Image ajoutée: $name';
  }

  @override
  String imageUploaded(String name) {
    return 'Image uploadée: $name';
  }

  @override
  String uploadError(String error) {
    return 'Erreur upload: $error';
  }

  @override
  String errorDetail(String error) {
    return 'Erreur détaillée: $error';
  }

  @override
  String get verificationDetailTitle => 'Détail de la vérification';

  @override
  String get recipientLabel => 'Destinataire';

  @override
  String get cannotOpenDocument => 'Impossible d\'ouvrir le document';

  @override
  String get featureNoLongerAvailable =>
      'Cette fonctionnalité n\'est plus disponible';

  @override
  String get articleNotFound => 'Article introuvable';

  @override
  String get sessionExpiredReconnect => 'Session expirée. Reconnectez-vous.';

  @override
  String get cannotLoadProposal => 'Impossible de charger la proposition.';

  @override
  String get searchDetails => 'Détails de la recherche';

  @override
  String get proposeOfferButton => 'Proposer une offre';

  @override
  String get specialPromotion => 'Promotion spéciale';

  @override
  String get viewProposal => 'Voir la proposition';

  @override
  String get partSearched => 'Pièce recherchée';

  @override
  String get articleNotFoundVerification =>
      'Article introuvable pour la vérification';

  @override
  String get noUserForNotifications =>
      'Aucun utilisateur connecté. Impossible de charger les notifications.';

  @override
  String get verifySubscriptionPlan =>
      'Impossible de verifier le plan d\'abonnement.';

  @override
  String get viewSubscription => 'Voir abonnement';

  @override
  String get addPartTitle => 'Ajouter une pièce';

  @override
  String get myCarsTitle => 'Mes voitures';

  @override
  String get noCarsPublished => 'Vous n\'avez aucune voiture publiée';

  @override
  String get myPartsTitle => 'Mes pièces';

  @override
  String get recommendedLabel => 'Recommandé';

  @override
  String get priceNotCommunicated => 'Prix non communiqué';

  @override
  String get noSponsoredCars => 'Aucune voiture sponsorisée.';

  @override
  String get linkedArticleNotFound =>
      'Article lié introuvable pour cette publicité.';

  @override
  String get cannotLoadAdDetails =>
      'Impossible de charger les détails de cette publicité.';

  @override
  String get verifiedLabel => 'Vérifiée';

  @override
  String get vehiclesPending => 'Véhicules en attente';

  @override
  String get noVehiclesPending => 'Aucun véhicule en attente de validation.';

  @override
  String get statsForSellersOnly =>
      'Les statistiques détaillées sont réservées aux vendeurs.';

  @override
  String saleCreditsRegistered(int count) {
    return '$count crédit(s) « vente » enregistré(s)';
  }

  @override
  String get vehiclesOnlineStat => 'Véhicules en ligne';

  @override
  String get partsOnlineStat => 'Pièces en ligne';

  @override
  String get vehiclesSoldStat => 'Véhicules vendus';

  @override
  String get partsSoldStat => 'Pièces vendues';

  @override
  String get articlesMarkedSold => 'Articles marqués vendus';

  @override
  String get viewsRecorded => 'Vues enregistrées';

  @override
  String get topVehiclesViews => 'Top véhicules (vues)';

  @override
  String get globalViewsHint =>
      'Les vues globales apparaîtront ici dès consultation de vos véhicules.';

  @override
  String get activities => 'Activités';

  @override
  String get inTransitStatus => 'En Transit';

  @override
  String get placeLabel => 'Lieu';

  @override
  String get packageDelivered => 'Colis livré';

  @override
  String get arrivalNotified => 'Arrivée notifiée à l\'acheteur';

  @override
  String arrivalError(String error) {
    return 'Erreur arrivée: $error';
  }

  @override
  String get validateOnSiteFirst =>
      'Validez \"Sur place\" chez le fournisseur avant l\'étape acheteur.';

  @override
  String get doorToDoor => 'Porte à porte';

  @override
  String get geolocateSupplier => 'Géolocaliser fournisseur';

  @override
  String get geolocateBuyer => 'Géolocaliser Acheteur';

  @override
  String get contactButton => 'Contacter';

  @override
  String get cashOnDeliveryShort => 'Espèces à la livraison';

  @override
  String get onSite => 'Sur place';

  @override
  String get finishedLabel => 'Terminé';

  @override
  String get rejectedTabLabel => 'Rejeté';

  @override
  String get addMultipleImages => 'Ajouter plusieurs images';

  @override
  String imageTooLarge(String size) {
    return 'Image trop volumineuse: ${size}MB (max: 5MB)';
  }

  @override
  String formatNotSupportedExt(String ext, String formats) {
    return 'Format non supporté: $ext. Formats: $formats';
  }

  @override
  String articleNetworkCreateError(String error) {
    return 'Erreur réseau lors de la création de l\'article: $error';
  }

  @override
  String get searchingAddress => 'Recherche de l\'adresse...';

  @override
  String get saveProfileError => 'Erreur lors de la mise à jour.';

  @override
  String get backToSettings => 'Retour aux paramètres';

  @override
  String get sellerTypeUpdatedSuccess =>
      'Type de vendeur mis à jour avec succès !';

  @override
  String updateError(String error) {
    return 'Erreur lors de la mise à jour: $error';
  }

  @override
  String get subscriptionPaymentSuccess =>
      'Paiement réussi : abonnement activé avec succès.';

  @override
  String get subscriptionPaymentFailed =>
      'Échec du paiement ou de l\'activation.';

  @override
  String get deliveryAcceptedSuccess => 'Livraison acceptée avec succès !';

  @override
  String get tricycleLoginRequiredTitle =>
      'Vous devez vous connecter pour continuer.';

  @override
  String get tricycleLoginRequiredSubtitle =>
      'Connectez-vous pour pouvoir commander un tricycle.';

  @override
  String get tricycleRequestSentToDriver => 'Demande envoyée au chauffeur.';

  @override
  String get tricycleRequestCancelled => 'Votre demande a été annulée.';

  @override
  String get tricycleCannotCancel => 'La demande ne peut plus être annulée.';

  @override
  String get tricycleDriverAlreadyAccepted =>
      'Le chauffeur a déjà accepté la demande.';

  @override
  String get tricycleCancelFailed => 'Impossible d\'annuler la demande.';

  @override
  String tricycleCancelErrorCode(String code) {
    return 'Code: $code. Veuillez réessayer.';
  }

  @override
  String get tricycleCancelError => 'Erreur lors de l\'annulation.';

  @override
  String get tricycleRequestAcceptedChat =>
      'Demande acceptée. Vous pouvez maintenant échanger.';

  @override
  String get tricycleRequestRejected => 'Demande rejetée.';

  @override
  String get checkConnectionRetry =>
      'Vérifiez votre connexion internet puis réessayez.';

  @override
  String get pageNotAvailableForRole => 'Page non disponible pour ce rôle';

  @override
  String errorDetailed(String error) {
    return 'Erreur détaillée: $error';
  }

  @override
  String get videoUploadErrorRetry =>
      'Erreur lors de l\'upload de la vidéo. Veuillez réessayer.';

  @override
  String maxMediaSlots(int count) {
    return 'Vous pouvez sélectionner au maximum $count médias.';
  }

  @override
  String get driverRegistrationFormTitle => 'Formulaire d\'inscription';

  @override
  String get imagesNotAllAddedWarning =>
      'Certaines images n\'ont pas pu être ajoutées:';

  @override
  String get addedToCart => 'Article ajouté au panier';

  @override
  String get payOnline => 'En ligne';

  @override
  String orderCommandTotal(String total) {
    return 'Commander • $total F';
  }

  @override
  String registrationSaveError(String error) {
    return 'Erreur lors de l\'enregistrement: $error';
  }

  @override
  String get purchaseHistoryTitle => 'Historique des achats';

  @override
  String get purchaseHistorySubtitle => 'Parcours véhicules et transitaires';

  @override
  String get purchaseHistoryEmpty => 'Aucun achat en cours pour le moment.';

  @override
  String get purchaseHistoryLoadError =>
      'Impossible de charger l\'historique des achats.';

  @override
  String get purchaseHistoryChangeForwarder => 'Changer de transitaire';

  @override
  String get purchaseHistoryViewVehicle => 'Voir le véhicule';

  @override
  String get purchaseHistoryDetailsTitle => 'Détail de l\'achat';

  @override
  String get purchaseHistoryForwarderLabel => 'Transitaire choisi';

  @override
  String get purchaseHistoryNoForwarder => 'Aucun transitaire';

  @override
  String get purchaseHistoryDestinationLabel => 'Destination';

  @override
  String get purchaseHistoryModeLabel => 'Mode de livraison';

  @override
  String get purchaseHistoryDetailsLabel => 'Informations complémentaires';

  @override
  String purchaseHistoryStartedAt(String date) {
    return 'Démarré le $date';
  }

  @override
  String get purchaseStatusParcours => 'En cours — choix transitaire';

  @override
  String get purchaseStatusEnCours => 'Transitaire sélectionné';

  @override
  String get purchaseStatusTransferer => 'Vérification validée';

  @override
  String get purchaseStatusTraite => 'Terminé';

  @override
  String get purchaseStatusAnnule => 'Achat annulé';

  @override
  String get purchaseModeTransit => 'En transit';

  @override
  String get purchaseModeConsommation => 'En consommation';

  @override
  String get errorTransitaireActif =>
      'Un transitaire est déjà actif pour cet achat.';

  @override
  String get errorAchatAnnule => 'Cet achat a été annulé.';

  @override
  String get purchaseForwarderSelected =>
      'Transitaire mis à jour pour cet achat.';
}
