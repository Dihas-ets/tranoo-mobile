import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/cloudinary_upload.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tranoo/services/user_service.dart'; // Ajout pour getBaseUrl
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
=======

>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
import 'package:flutter/foundation.dart' show kIsWeb;

class DriverCertifiedPage extends StatefulWidget {
  const DriverCertifiedPage({super.key});

  @override
  DriverCertifiedPageState createState() => DriverCertifiedPageState();
}

class DriverCertifiedPageState extends State<DriverCertifiedPage> {
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _permitController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  File? _uploadedImage;
  String? _uploadedFileName;
  String? _cloudinaryUrl;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _uploadedFileName = image.name;
      });
      String? url;
      if (kIsWeb) {
        // Web : lire les bytes et uploader
        final bytes = await image.readAsBytes();
        url = await uploadImageToCloudinary(bytes);
      } else {
        // Mobile : utiliser File
        _uploadedImage = File(image.path);
        url = await uploadImageToCloudinary(_uploadedImage!);
      }
      if (url != null) {
        setState(() {
          _cloudinaryUrl = url;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l\'upload de l\'image.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image sélectionnée.')),
      );
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });
    final lastName = _lastNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final permit = _permitController.text.trim();
    final message = _messageController.text.trim();
    final permitUrl = _cloudinaryUrl;
    if (lastName.isEmpty ||
        firstName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        permit.isEmpty ||
        permitUrl == null) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs obligatoires et uploader votre permis.',
          ),
        ),
      );
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final response = await http.post(
        Uri.parse(getBaseUrl() + '/chauffeurs/demandes'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'nom': lastName,
          'prenom': firstName,
          'telephone': phone,
          'email': email,
          'numeroPermit': permit, // <-- correction ici
          'message': message,
          'permisFile': permitUrl, // <-- correction ici
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande envoyée avec succès !')),
        );
        _lastNameController.clear();
        _firstNameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _permitController.clear();
        _messageController.clear();
        setState(() {
          _cloudinaryUrl = null;
          _uploadedImage = null;
          _uploadedFileName = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi : \\${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau : $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulaire d’inscription'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de famille
            _buildLabel('Nom de famille *'),
            const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              decoration: _buildInputDecoration('Entrer votre nom'),
            ),
            const SizedBox(height: 16),

            // Prénom
            _buildLabel('Prénom *'),
            const SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              decoration: _buildInputDecoration('Entrer votre prénom'),
            ),
            const SizedBox(height: 16),

            // Numéro de Téléphone
            _buildLabel('Numéro de Téléphone *'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: _buildInputDecoration(
                'Tapez votre numéro de Téléphone',
              ),
            ),
            const SizedBox(height: 16),

            // E-mail
            _buildLabel('E-mail *'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: _buildInputDecoration('Entrer votre mail'),
            ),
            const SizedBox(height: 16),

            // Numéro de permit
            _buildLabel('Numéro de permit *'),
            const SizedBox(height: 8),
            TextField(
              controller: _permitController,
              decoration: _buildInputDecoration(
                'Entrer votre numéro de permit',
              ),
            ),
            const SizedBox(height: 16),

            // Messages
            _buildLabel('Messages'),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: _buildInputDecoration('Écrivez votre message'),
            ),
            const SizedBox(height: 16),

            // Télécharger des images
            _buildLabel('Télécharger des images'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _uploadedFileName ?? 'Mon permis pdf',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Affichage de l'image uploadée depuis Cloudinary
            if (_cloudinaryUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(
                  _cloudinaryUrl!,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),

            // Bouton de soumission
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('Soumettre'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
