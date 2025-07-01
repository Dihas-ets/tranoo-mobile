import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _uploadedFileName = image.name;
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

            // Bouton de soumission
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Action de soumission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Soumettre'),
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
