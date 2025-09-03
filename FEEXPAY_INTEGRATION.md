# Intégration FeexPay dans l'application Tranoo

Ce document explique comment intégrer et utiliser le service de paiement FeexPay dans votre application Flutter Tranoo.

## 🚀 Qu'est-ce que FeexPay ?

FeexPay est un agrégateur de paiement africain qui permet d'accepter des paiements via :
- **Mobile Money** : MTN Mobile Money, Moov Money, Orange Money
- **Cartes bancaires** : VISA, Mastercard
- **Portefeuilles numériques** : Comptes FeexPay

## 📋 Prérequis

1. **Compte FeexPay** : Créez un compte sur [feexpay.me](https://feexpay.me)
2. **Validation du compte** : Validez votre compte avec les documents requis
3. **API Key** : Obtenez votre clé API depuis le dashboard FeexPay
4. **Shop ID** : Notez votre identifiant de boutique

## 🔧 Configuration

### 1. Mise à jour des identifiants

Modifiez le fichier `lib/config/feexpay_config.dart` :

```dart
class FeexPayConfig {
  // Remplacez par vos vraies valeurs
  static const String shopId = "VOTRE_VRAI_SHOP_ID";
  static const String apiToken = "VOTRE_VRAI_API_TOKEN";
  
  // Changez en "LIVE" pour la production
  static const String mode = "SANDBOX";
  
  // Personnalisez vos URLs de callback
  static const String successCallbackUrl = "https://votre-site.com/success";
  static const String errorCallbackUrl = "https://votre-site.com/error";
}
```

### 2. Configuration des URLs de callback

Configurez vos URLs de callback pour recevoir les notifications de paiement :

```dart
// Exemple d'URLs de callback
static const String successCallbackUrl = "https://tranoo.com/payment/success";
static const String errorCallbackUrl = "https://tranoo.com/payment/error";
```

## 📱 Utilisation

### 1. Initialisation du service

```dart
// Dans votre main.dart ou lors du démarrage de l'app
await FeexPayService.initialize();
```

### 2. Lancement d'un paiement

```dart
final result = await FeexPayService.startPayment(
  amount: 5000, // 5000 FCFA
  customId: "CMD_001",
  description: "Paiement commande #001",
  paymentType: "MOBILE", // ou "CARD", "WALLET"
);

if (result['status'] == 'success') {
  // Ouvrir la page de paiement
  final paymentUrl = result['payment_url'];
  // Utiliser url_launcher pour ouvrir l'URL
} else {
  // Gérer l'erreur
  print(result['message']);
}
```

### 3. Vérification du statut d'une transaction

```dart
final status = await FeexPayService.checkTransactionStatus("TRANSACTION_ID");
if (status['status'] == 'success') {
  print("Transaction: ${status['data']}");
}
```

### 4. Gestion des reversements

```dart
final refund = await FeexPayService.refund(
  transactionId: "TRANSACTION_ID",
  amount: 5000,
  reason: "Demande client",
);
```

## 🎨 Écrans disponibles

### PaymentScreen
- Formulaire de saisie des détails de paiement
- Sélection du type de paiement
- Validation des montants
- Lancement du processus de paiement

### TransactionsScreen
- Historique des transactions
- Solde du compte
- Détails des transactions
- Gestion des reversements

## 🔒 Sécurité

### Validation des montants
- Montant minimum : 100 FCFA
- Montant maximum : 10 000 000 FCFA

### Validation des types de paiement
- MOBILE : Mobile Money uniquement
- CARD : Cartes bancaires uniquement
- WALLET : Portefeuille FeexPay uniquement

### Gestion des erreurs
- Validation des paramètres
- Gestion des erreurs réseau
- Gestion des erreurs API

## 📊 Gestion des transactions

### Statuts possibles
- `success` : Paiement réussi
- `pending` : Paiement en cours
- `failed` : Paiement échoué
- `cancelled` : Paiement annulé

### Informations disponibles
- ID de transaction
- Montant
- Description
- Date de création
- Méthode de paiement
- Statut
- Informations client (si disponibles)

## 🚨 Gestion des erreurs

### Erreurs courantes
- **Montant invalide** : Vérifiez les limites (100 - 10M FCFA)
- **Type de paiement non supporté** : Utilisez MOBILE, CARD ou WALLET
- **Erreur réseau** : Vérifiez votre connexion internet
- **Identifiants invalides** : Vérifiez votre Shop ID et API Token

### Messages d'erreur personnalisés
Tous les messages d'erreur sont centralisés dans `FeexPayConfig.errorMessages` et peuvent être personnalisés selon vos besoins.

## 🔄 Webhooks (Optionnel)

Pour recevoir des notifications en temps réel, configurez des webhooks :

```dart
static const String webhookUrl = "https://votre-site.com/webhook/feexpay";
static const List<String> webhookEvents = [
  'payment.success',
  'payment.failed',
  'payment.cancelled',
  'refund.success',
  'refund.failed',
];
```

## 📱 Notifications Push (Optionnel)

Activez les notifications push pour informer les utilisateurs des transactions :

```dart
static const bool enablePushNotifications = true;
static const String pushNotificationTitle = "Nouvelle transaction FeexPay";
```

## 🧪 Tests

### Mode SANDBOX
- Utilisez le mode SANDBOX pour les tests
- Les transactions ne sont pas réelles
- Idéal pour le développement et les tests

### Mode LIVE
- Passez en mode LIVE pour la production
- Les transactions sont réelles
- Assurez-vous que votre compte est validé

## 📈 Monitoring et métriques

### Métriques disponibles
- Nombre de transactions
- Taux de succès
- Montants moyens
- Types de paiement utilisés

### Configuration des métriques
```dart
static const bool enableMetrics = true;
static const int metricsFlushInterval = 60000; // 1 minute
```

## 🔧 Personnalisation

### Thème et couleurs
Modifiez les couleurs dans les écrans selon votre charte graphique :

```dart
// Dans PaymentScreen et TransactionsScreen
backgroundColor: Colors.blue[600], // Votre couleur principale
```

### Validation personnalisée
Ajoutez vos propres règles de validation dans `FeexPayConfig` :

```dart
static bool isValidCustomField(String value) {
  // Votre logique de validation
  return value.length >= 3;
}
```

## 📚 Ressources utiles

- [Documentation officielle FeexPay](https://docs.feexpay.me)
- [Dashboard FeexPay](https://dashboard.feexpay.me)
- [Support FeexPay](mailto:contact@feexpay.me)

## 🆘 Support

### En cas de problème
1. Vérifiez vos identifiants (Shop ID, API Token)
2. Vérifiez le mode (SANDBOX/LIVE)
3. Consultez les logs de l'application
4. Contactez le support FeexPay

### Logs de débogage
Activez le mode debug pour plus d'informations :

```dart
static const bool enableDebugMode = true;
static const bool enableLogging = true;
```

## 📝 Notes importantes

- **Devise** : Seul le FCFA (XOF) est supporté actuellement
- **Frais** : Consultez la grille tarifaire FeexPay
- **Limites** : Respectez les limites de montant
- **Sécurité** : Ne partagez jamais votre API Token

## 🚀 Déploiement

### Préparation
1. Changez le mode en "LIVE"
2. Vérifiez vos URLs de callback
3. Testez avec de petits montants
4. Validez votre compte FeexPay

### Production
1. Désactivez le mode debug
2. Configurez les webhooks
3. Activez les notifications
4. Surveillez les métriques

---

**Version** : 1.0  
**Dernière mise à jour** : ${new Date().toLocaleDateString()}  
**Auteur** : Équipe Tranoo
