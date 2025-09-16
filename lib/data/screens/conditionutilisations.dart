import 'package:flutter/material.dart';

class ConditionUtilisations extends StatelessWidget {
  const ConditionUtilisations({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conditions d\'utilisation',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xffF8BF13),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * (isPortrait ? 0.05 : 0.1),
          vertical: screenHeight * (isPortrait ? 0.03 : 0.1),
        ),
        child: const Text('''
Conditions d'Utilisation de l'Application Tranoo

Bienvenue sur Tranoo, votre application de vente de voitures importées. En utilisant cette application, vous acceptez les conditions suivantes :

1. **Objet de l'Application**
   Tranoo est une plateforme facilitant l'achat et la vente de voitures importées. Nous mettons en relation les vendeurs et les acheteurs.

2. **Inscription et Compte**
   - Vous devez fournir des informations exactes lors de votre inscription.
   - Vous êtes responsable de la sécurité de votre compte et de vos identifiants.

3. **Utilisation Acceptable**
   - L'application doit être utilisée uniquement pour la vente et l'achat de véhicules.
   - Toute activité frauduleuse entraînera une suspension du compte.

4. **Transactions et Responsabilité**
   - Tranoo agit en tant qu'intermédiaire et ne garantit pas la qualité des véhicules.
   - Les transactions doivent être réalisées avec prudence et transparence.

5. **Confidentialité et Sécurité**
   - Vos données sont protégées conformément à notre politique de confidentialité.
   - Aucune information personnelle ne sera partagée sans votre consentement.

6. **Modification des Conditions**
   - Nous nous réservons le droit de modifier ces conditions à tout moment.

Merci d'utiliser Tranoo !
          ''', textAlign: TextAlign.justify),
      ),
    );
  }
}
