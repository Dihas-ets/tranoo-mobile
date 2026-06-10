import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class ConditionUtilisations extends StatelessWidget {
  const ConditionUtilisations({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.termsOfUse,
          style: const TextStyle(color: Colors.black),
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
   - Tranoo n'est pas responsable des transactions entre utilisateurs.
   - Les litiges doivent être résolus directement entre les parties concernées.

5. **Modifications**
   - Nous nous réservons le droit de modifier ces conditions à tout moment.
   - Les utilisateurs seront informés des changements importants.

En continuant à utiliser Tranoo, vous acceptez ces conditions d'utilisation.
'''),
      ),
    );
  }
}
