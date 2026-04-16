import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/wallet_screen.dart';
import 'package:tranoo/data/screens/connexion_page.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/profile2.dart';
import 'package:tranoo/data/screens/historique_transit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as local_auth;

class ProfilUtilisateur2 extends StatefulWidget {
  const ProfilUtilisateur2({super.key});

  @override
  State<ProfilUtilisateur2> createState() => _ProfilUtilisateur2State();
}

class _ProfilUtilisateur2State extends State<ProfilUtilisateur2> {
  File? _image;
  String selectedLanguage = "Français";
  String selectedCurrencyValue = "XOF";
  Map<String, dynamic>? userData;
  bool loading = true;
  String? errorMsg;
  double? _walletBalance;
  String _walletCurrency = "XOF";
  bool _walletLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _walletLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _walletLoading = false;
          _walletBalance = null;
        });
        return;
      }
      final idToken = await user.getIdToken();
      final String baseUrl = getBaseUrl();
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      final res = await dio.get('/wallet/me');
      setState(() {
        _walletBalance = (res.data['balance'] ?? 0).toDouble();
        _walletCurrency = (res.data['currency'] ?? 'XOF').toString();
        selectedCurrencyValue = _walletCurrency;
        _walletLoading = false;
      });
    } catch (e) {
      setState(() {
        _walletLoading = false;
        _walletBalance = 0.0;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text('Suppression du compte')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette action est irreversible.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Votre compte, votre acces a l\'application et vos donnees liees seront supprimes.',
            ),
            SizedBox(height: 12),
            Text(
              'Assurez-vous de ne plus avoir besoin de ce compte avant de confirmer.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) {
        if (context.mounted) Navigator.of(context).pop(); // close progress
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
          );
        }
        return;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: getBaseUrl(),
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      await dio.delete('/users/me');

      if (context.mounted) Navigator.of(context).pop(); // close progress
      await Provider.of<local_auth.AuthProvider>(context, listen: false)
          .logout();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ConnexionPage()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // close progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur suppression: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
          userData = null;
          errorMsg = "Utilisateur non connecté.";
        });
        return;
      }
      final idToken = await user.getIdToken();
      final String baseUrl = getBaseUrl();
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      final response = await dio.get('/protected/me');
      setState(() {
        userData = response.data['user'];
        loading = false;
        errorMsg = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        userData = null;
        errorMsg =
            "Impossible de charger le profil. Vérifiez votre connexion ou vos droits.";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadPhoto(_image!);
    }
  }

  Future<void> _uploadPhoto(File image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      // Upload vers Cloudinary avec le dossier profiles
      final url = await uploadImageToCloudinary(
        image,
        folder: CloudinaryFolders.profiles,
      );
      
      if (url != null) {
        // Mettre à jour via PATCH /users/me
        final idToken = await user.getIdToken();
        final String baseUrl = getBaseUrl();
        final dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'Authorization': 'Bearer $idToken'},
          ),
        );
        await dio.patch('/users/me', data: {"photo": url});
        final me = await dio.get('/protected/me');
        final refreshedUser = me.data['user'];
        await local_auth.AuthProvider.saveUserToPrefs(idToken, refreshedUser);
        if (mounted) {
          context.read<local_auth.AuthProvider>().reloadUser();
        setState(() {
          userData?["photo"] = url;
        });
        }
      }
    } catch (e) {
      print('Erreur upload photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());
    if (errorMsg != null) return Center(child: Text(errorMsg!));
    if (userData == null)
      return Center(child: Text("Aucune donnée utilisateur"));
    if (userData != null && userData?['role'] != 'transitaire') {
      return Center(child: Text("Accès réservé aux transitaires."));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Compte",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildProfileCard(),
            const SizedBox(height: 50),
            _buildAccountOptions(),
            const SizedBox(height: 20),
            const Text(
              "Plus",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildMoreOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _image != null
                          ? FileImage(_image!) as ImageProvider
                          : (userData != null &&
                              userData!["photo"] != null &&
                              userData!["photo"].toString().isNotEmpty)
                          ? NetworkImage(userData!["photo"].toString()) as ImageProvider
                          : null,
                  child: (_image == null && 
                          (userData == null || 
                           userData!["photo"] == null || 
                           userData!["photo"].toString().isEmpty))
                      ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: -5,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit,
                        color: Color(0xFFF8BF13),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData?["nom"] ?? "",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                userData?["email"] ?? "",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Color(0xFFFFCE31)),
      title: Text(title, style: const TextStyle()),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )
              : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildAccountOptions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildListTile(
            title: "Mon compte",
            subtitle: "Apporter des modifications à votre compte",
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile2()),
              );
            },
          ),
          _buildListTile(
            title: "Historique des transits",
            //subtitle: "Devenir titulaire et vendez avec nous",
            icon: Icons.history,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoriqueTransitPage(),
                ),
              );
            },
          ),
          // _buildListTile(
          //   title: "Devenir chauffeur certifié",
          //   subtitle: "Proposer des services de livraison",
          //   icon: Icons.delivery_dining,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => DriverCertifiedPage()),
          //     );
          //   },
          // ),
          _buildListTile(
            title: "Mon portefeuille",
            icon: Icons.account_balance_wallet,
            trailing: _walletLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    "${_walletBalance?.toStringAsFixed(0) ?? '0'} $_walletCurrency",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              ).then((_) => _loadWallet()); // Recharger après retour
            },
          ),
          _buildListTile(
            title: "Suppression de compte",
            icon: Icons.delete_forever,
            color: Colors.red,
            onTap: () => _deleteAccount(),
          ),
          _buildListTile(
            title: "Déconnexion",
            icon: Icons.logout,
            color: Color(0xFFFFCE31),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnexionPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          _buildOption(
            "Notifications",
            "",
            Icons.notifications,
            badge: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notifications()),
              );
            },
          ),
          _buildOption(
            "Langue",
            selectedLanguage,
            Icons.language,
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _showLanguageDialog(context),
            ),
          ),
          _buildOption(
            "Devise",
            selectedCurrencyValue,
            Icons.monetization_on,
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _showCurrencyDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    String title,
    String value,
    IconData icon, {
    bool badge = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFFFCE31)),
      title: Row(
        children: [
          Text(title, style: const TextStyle()),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      trailing:
          trailing ??
          (badge
              ? const Icon(Icons.circle, size: 12, color: Colors.red)
              : const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black,
              )),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var lang in [
                "Français",
                "Anglais",
                "Espagnol",
                "Allemand",
                "Italien",
              ])
                ListTile(
                  title: Text(lang),
                  onTap: () {
                    setState(() {
                      selectedLanguage = lang;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une devise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('XOF'),
                onTap: () {
                  Navigator.pop(context, 'XOF');
                },
              ),
              ListTile(
                title: const Text('Euro'),
                onTap: () {
                  Navigator.pop(context, 'Euro');
                },
              ),
              ListTile(
                title: const Text('Dollars'),
                onTap: () {
                  Navigator.pop(context, 'Dollars');
                },
              ),
            ],
          ),
        );
      },
    ).then((selectedCurrency) {
      if (selectedCurrency != null) {
        setState(() {
          selectedCurrencyValue = selectedCurrency;
        });
      }
    });
  }
}
