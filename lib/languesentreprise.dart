import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/providers/locale_provider.dart';

class LanguesEntreprise extends StatefulWidget {
  const LanguesEntreprise({super.key});

  @override
  State<LanguesEntreprise> createState() => _LanguesState();
}

class _LanguesState extends State<LanguesEntreprise> {
  String _selectedLanguage = 'fr'; // Langue par défaut (FR/EN)

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
          l10n.language,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xffF8BF13),
        centerTitle: true,
        // L'icône a été supprimée
        actions: [Padding(padding: const EdgeInsets.only(right: 2))],
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * (isPortrait ? 0.05 : 0.1),
          vertical: screenHeight * (isPortrait ? 0.03 : 0.1),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(l10n.french),
                    value: 'fr',
                    activeColor: const Color(0xff072858),
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                ),
                CircleAvatar(
                  radius: screenWidth * (isPortrait ? 0.06 : 0.04),
                  backgroundImage: const AssetImage(
                    'assets/images/francais.jpg',
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * (isPortrait ? 0.03 : 0.1)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(l10n.english),
                    value: 'en',
                    activeColor: const Color(0xff072858),
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                ),
                CircleAvatar(
                  radius: screenWidth * (isPortrait ? 0.06 : 0.04),
                  backgroundImage: const AssetImage(
                    'assets/images/anglais.jpg',
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * (isPortrait ? 0.2 : 0.2)),
            SizedBox(
              width:
                  screenWidth *
                  (isPortrait ? 0.9 : 0.8), // Largeur du bouton ajustée
              height: screenHeight * (isPortrait ? 0.06 : 0.2),
              child: ElevatedButton(
                onPressed: () {
                  final provider =
                      Provider.of<LocaleProvider>(context, listen: false);
                  provider.setLocale(Locale(_selectedLanguage));
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFFF8BF13),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(3),
                ),
                child: Text(
                  l10n.validate,
                  style: TextStyle(
                    fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Texte en noir
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
