import 'package:flutter/material.dart';

class LanguesEntreprise extends StatefulWidget {
  const LanguesEntreprise({super.key});

  @override
  State<LanguesEntreprise> createState() => _LanguesState();
}

class _LanguesState extends State<LanguesEntreprise> {
  String _selectedLanguage = 'francais'; // Langue par défaut

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Langue',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                    title: const Text('Français'),
                    value: 'francais',
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
                    title: const Text('Anglais'),
                    value: 'anglais',
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
            SizedBox(height: screenHeight * (isPortrait ? 0.03 : 0.1)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Espagnol'),
                    value: 'espagnol',
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
                    'assets/images/espagnol.jpg',
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * (isPortrait ? 0.03 : 0.1)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Allemand'),
                    value: 'allemand',
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
                    'assets/images/demangle.jpg',
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * (isPortrait ? 0.03 : 0.1)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Italien'),
                    value: 'italien',
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
            SizedBox(height: screenHeight * (isPortrait ? 0.2 : 0.2)),
            SizedBox(
              width:
                  screenWidth *
                  (isPortrait ? 0.9 : 0.8), // Largeur du bouton ajustée
              height: screenHeight * (isPortrait ? 0.06 : 0.2),
              child: ElevatedButton(
                onPressed: () {
                  // Action à réaliser après la sélection
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Langue sélectionnée: $_selectedLanguage'),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color(0xFFF8BF13), // Ton fond jaune
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Bordures arrondies
                    ),
                  ),
                  elevation: MaterialStateProperty.all(3),
                ),
                child: Text(
                  'Valider',
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
