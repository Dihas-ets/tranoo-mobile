import 'package:flutter/material.dart';

import 'connexion_page.dart'; // Assurez-vous que ce fichier existe

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  String? selectedCountry;
  final List<String> countries = [
    'Bénin',
    'Côte d\'Ivoire',
    'Sénégal',
    'Togo',
    'Mali',
    'Burkina Faso',
    'Niger'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFF9FAFB)),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(child: Image.asset("assets/images/logo_connexion.png")),
              const SizedBox(height: 40),
              const Text("S'inscrire",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 12),
              const Text("Trouvez votre voiture de rêve!",
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 40),

              buildTextField("Nom et Prénoms", Icons.person,
                  placeholder: "Jean Dupont"),
              const SizedBox(height: 20),
              buildTextField("Adresse email", Icons.email,
                  placeholder: "jean.dupont@email.com"),
              const SizedBox(height: 20),
              buildTextField("Téléphone", Icons.phone,
                  placeholder: "+229 97 12 34 56"),
              const SizedBox(height: 20),
              buildTextField("Mot de passe", Icons.lock,
                  isPassword: true, placeholder: "********"),
              const SizedBox(height: 20),
              buildTextField("Confirmer le mot de passe", Icons.lock,
                  isPassword: true, placeholder: "********"),
              const SizedBox(height: 20),

              // Sélection du Pays
              buildDropdown(),

              const SizedBox(height: 20),
              buildTextField("Maison", Icons.home,
                  placeholder: "Rue 123, Cotonou"),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page de connexion après l'inscription
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnexionPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8BF13),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("S'inscrire",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vous avez déjà un compte ? ",
                      style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ConnexionPage()));
                    },
                    child: const Text("Se connecter",
                        style: TextStyle(
                            color: Color(0xFF0461B6),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour créer un champ de saisie avec un placeholder
  Widget buildTextField(String label, IconData icon,
      {bool isPassword = false, String? placeholder}) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: Builder(
        builder: (context) {
          final focusNode = Focus.of(context);
          final bool isFocused = focusNode.hasFocus;

          return TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(icon,
                  color: isFocused ? const Color(0xFFF8BF13) : Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isFocused ? const Color(0xFFF8BF13) : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8BF13)),
              ),
            ),
          );
        },
      ),
    );
  }

  // Fonction pour le champ de sélection du pays
  Widget buildDropdown() {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: Builder(
        builder: (context) {
          final focusNode = Focus.of(context);
          final bool isFocused = focusNode.hasFocus;

          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Pays',
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.public,
                  color: isFocused ? const Color(0xFFF8BF13) : Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isFocused ? const Color(0xFFF8BF13) : Colors.grey,
                    width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8BF13)),
              ),
            ),
            value: selectedCountry,
            items: countries.map((country) {
              return DropdownMenuItem(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCountry = value;
              });
            },
          );
        },
      ),
    );
  }
}
