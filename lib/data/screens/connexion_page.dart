// import 'package:flutter/material.dart';
// import 'package:tranoo/data/screens/avant_home.dart';

// import 'inscription_page.dart';

// class ConnexionPage extends StatefulWidget {
//   const ConnexionPage({super.key});

//   @override
//   State<ConnexionPage> createState() => _ConnexionPageState();
// }

// class _ConnexionPageState extends State<ConnexionPage> {
//   bool isEmailFocused = false;
//   bool isPasswordFocused = false;

//   @override
//   Widget build(BuildContext context) {
//     // Récupération des dimensions de l'écran
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//     final isPortrait = mediaQuery.orientation == Orientation.portrait;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: screenWidth * (isPortrait ? 0.05 : 0.1),
//             vertical: screenHeight * (isPortrait ? 0.02 : 0.05),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: screenHeight * (isPortrait ? 0.1 : 0.05)),
//               Center(
//                 child: Image.asset(
//                   "assets/images/logo_connexion.png",
//                   width: screenWidth * (isPortrait ? 0.6 : 0.4),
//                   height: screenHeight * (isPortrait ? 0.15 : 0.2),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),
//               Text(
//                 "Se connecter",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: screenWidth * (isPortrait ? 0.06 : 0.04),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.02),
//               Text(
//                 "Bienvenue à Tranoo",
//                 style: TextStyle(
//                   fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
//                 ),
//               ),
//               SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),

//               // Champ Email
//               Focus(
//                 onFocusChange: (focused) {
//                   setState(() => isEmailFocused = focused);
//                 },
//                 child: TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     labelStyle: TextStyle(
//                       color: Colors.grey,
//                       fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
//                     ),
//                     prefixIcon: Icon(
//                       Icons.email_outlined,
//                       color: isEmailFocused ? Colors.amber : Colors.grey,
//                       size: screenWidth * (isPortrait ? 0.06 : 0.04),
//                     ),
//                     hintText: "exemple@mail.com",
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: EdgeInsets.symmetric(
//                       vertical: screenHeight * 0.02,
//                       horizontal: screenWidth * 0.04,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Colors.grey,
//                         width: 2,
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Colors.grey),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Colors.amber),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: screenHeight * 0.02),

//               // Champ Mot de passe
//               Focus(
//                 onFocusChange: (focused) {
//                   setState(() => isPasswordFocused = focused);
//                 },
//                 child: TextField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Mot de passe',
//                     labelStyle: TextStyle(
//                       color: Colors.grey,
//                       fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
//                     ),
//                     prefixIcon: Icon(
//                       Icons.lock_outline,
//                       color: isPasswordFocused ? Colors.amber : Colors.grey,
//                       size: screenWidth * (isPortrait ? 0.06 : 0.04),
//                     ),
//                     hintText: "••••••••",
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: EdgeInsets.symmetric(
//                       vertical: screenHeight * 0.02,
//                       horizontal: screenWidth * 0.04,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Colors.grey),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Colors.grey),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Colors.amber,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: screenHeight * 0.02),

//               // Lien "Mot de passe oublié"
//               TextButton(
//                 onPressed: () {
//                   // Ajoute ici la logique pour réinitialiser le mot de passe
//                 },
//                 child: Text(
//                   "Mot de passe oublié ?",
//                   style: TextStyle(
//                     fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
//                     color: Colors.black,
//                   ),
//                 ),
//               ),

//               SizedBox(height: screenHeight * 0.02),

//               // Bouton Se connecter
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const AvantHome(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFF8BF13),
//                     foregroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(
//                       vertical: screenHeight * 0.02,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Se connecter',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: screenWidth * (isPortrait ? 0.045 : 0.035),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: screenHeight * 0.03),

//               // Lien vers l'inscription
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Vous n'avez pas de compte ? ",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const InscriptionPage(),
//                         ),
//                       );
//                     },
//                     child: Text(
//                       "S'inscrire",
//                       style: TextStyle(
//                         color: const Color(0xFF0461B6),
//                         fontWeight: FontWeight.bold,
//                         fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// ... existing code ...

import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/avant_home.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';

import 'inscription_page.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  bool isEmailFocused = false;
  bool isPasswordFocused = false;
  String? selectedRole;
  final List<String> roles = ['Acheteur', 'Vendeur', 'Transitaire'];
  final userService = UserService();

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * (isPortrait ? 0.05 : 0.1),
            vertical: screenHeight * (isPortrait ? 0.02 : 0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * (isPortrait ? 0.1 : 0.05)),
              Center(
                child: Image.asset(
                  "assets/images/logo_connexion.png",
                  width: screenWidth * (isPortrait ? 0.6 : 0.4),
                  height: screenHeight * (isPortrait ? 0.15 : 0.2),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),
              Text(
                "Se connecter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * (isPortrait ? 0.06 : 0.04),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Bienvenue à Tranoo",
                style: TextStyle(
                  fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                ),
              ),
              SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),

              // Champ Email
              Focus(
                onFocusChange: (focused) {
                  setState(() => isEmailFocused = focused);
                },
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isEmailFocused ? Colors.amber : Colors.grey,
                      size: screenWidth * (isPortrait ? 0.06 : 0.04),
                    ),
                    hintText: "exemple@mail.com",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Champ Mot de passe
              Focus(
                onFocusChange: (focused) {
                  setState(() => isPasswordFocused = focused);
                },
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isPasswordFocused ? Colors.amber : Colors.grey,
                      size: screenWidth * (isPortrait ? 0.06 : 0.04),
                    ),
                    hintText: "••••••••",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.amber,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Sélection du rôle
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {});
                },
                child: Builder(
                  builder: (context) {
                    final focusNode = Focus.of(context);
                    final bool isFocused = focusNode.hasFocus;

                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Rôle',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: isFocused ? const Color(0xFFF8BF13) : Colors.grey,
                          size: screenWidth * (isPortrait ? 0.06 : 0.04),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isFocused ? const Color(0xFFF8BF13) : Colors.grey,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF8BF13),
                          ),
                        ),
                      ),
                      value: selectedRole,
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Lien "Mot de passe oublié"
              TextButton(
                onPressed: () {
                  // Ajoute ici la logique pour réinitialiser le mot de passe
                },
                child: Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(
                    fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Bouton Se connecter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedRole != null) {
                      // Définir le rôle de l'utilisateur
                      switch (selectedRole) {
                        case 'Acheteur':
                          userService.setRole(UserRole.acheteur);
                          break;
                        case 'Vendeur':
                          userService.setRole(UserRole.vendeur);
                          break;
                        case 'Transitaire':
                          userService.setRole(UserRole.transitaire);
                          break;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvantHome(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez sélectionner un rôle'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8BF13),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * (isPortrait ? 0.045 : 0.035),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Lien vers l'inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous n'avez pas de compte ? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InscriptionPage(),
                        ),
                      );
                    },
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: const Color(0xFF0461B6),
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}