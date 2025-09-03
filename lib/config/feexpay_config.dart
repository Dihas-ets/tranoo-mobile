class FeexPayConfig {
  // Configuration de base
  static const String baseUrl = "https://api.feexpay.me";

  // Configuration de votre compte (à remplacer par vos vraies valeurs)
  static const String shopId = "VOTRE_SHOP_ID";
  static const String apiToken = "VOTRE_API_TOKEN";

  // Mode d'environnement
  static const String mode = "SANDBOX"; // ou "LIVE" pour la production

  // URLs de callback (à personnaliser selon votre application)
  static const String successCallbackUrl = "https://votre-site.com/success";
  static const String errorCallbackUrl = "https://votre-site.com/error";

  // Configuration des paiements
  static const String defaultCurrency = "XOF"; // FCFA
  static const int defaultAmount = 1000; // 1000 FCFA par défaut

  // Types de paiement supportés
  static const List<String> supportedPaymentTypes = [
    "MOBILE", // Mobile Money (MTN, Moov, Orange)
    "CARD", // Cartes bancaires (VISA, Mastercard)
    "WALLET", // Portefeuille FeexPay
  ];

  // Limites des transactions
  static const int minAmount = 100; // 100 FCFA minimum
  static const int maxAmount = 10000000; // 10 000 000 FCFA maximum

  // Configuration des timeouts
  static const int connectionTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000; // 30 secondes

  // Configuration des retry
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 seconde

  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiToken',
    'X-Shop-ID': shopId,
    'User-Agent': 'TranooApp/1.0',
  };

  // Validation des paramètres
  static bool isValidAmount(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  static bool isValidPaymentType(String paymentType) {
    return supportedPaymentTypes.contains(paymentType.toUpperCase());
  }

  static bool isValidCurrency(String currency) {
    return currency.toUpperCase() == defaultCurrency;
  }

  // Messages d'erreur
  static const Map<String, String> errorMessages = {
    'invalid_amount':
        'Le montant doit être entre $minAmount et $maxAmount FCFA',
    'invalid_payment_type': 'Type de paiement non supporté',
    'invalid_currency': 'Devise non supportée. Utilisez $defaultCurrency',
    'network_error': 'Erreur de connexion réseau',
    'timeout_error': 'Délai d\'attente dépassé',
    'api_error': 'Erreur de l\'API FeexPay',
    'invalid_credentials': 'Identifiants invalides',
    'insufficient_funds': 'Fonds insuffisants',
    'transaction_failed': 'Transaction échouée',
    'transaction_cancelled': 'Transaction annulée',
  };

  // Configuration des webhooks (optionnel)
  static const String webhookUrl = "https://votre-site.com/webhook/feexpay";
  static const List<String> webhookEvents = [
    'payment.success',
    'payment.failed',
    'payment.cancelled',
    'refund.success',
    'refund.failed',
  ];

  // Configuration des notifications push (optionnel)
  static const bool enablePushNotifications = true;
  static const String pushNotificationTitle = "Nouvelle transaction FeexPay";

  // Configuration du mode debug
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;

  // Configuration des métriques
  static const bool enableMetrics = true;
  static const int metricsFlushInterval = 60000; // 1 minute

  // Configuration de la sécurité
  static const bool enableSSLVerification = true;
  static const bool enableCertificatePinning = false;

  // Configuration du cache
  static const bool enableCache = true;
  static const int cacheExpirationTime = 300000; // 5 minutes

  // Configuration des tentatives de reconnexion
  static const bool enableAutoReconnect = true;
  static const int maxReconnectAttempts = 5;
  static const int reconnectDelay = 2000; // 2 secondes
}
