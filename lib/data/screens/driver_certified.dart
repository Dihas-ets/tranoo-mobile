import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/cloudinary_upload.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tranoo/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tranoo/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _uploadedFileName = image.name;
      });
      String? url;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        url = await uploadImageToCloudinary(
          bytes,
          folder: CloudinaryFolders.verificationDocs,
        );
      } else {
        _uploadedImage = File(image.path);
        url = await uploadImageToCloudinary(
          _uploadedImage!,
          folder: CloudinaryFolders.verificationDocs,
        );
      }
      if (url != null) {
        setState(() {
          _cloudinaryUrl = url;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadImageFailed)),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noImageSelected)),
      );
    }
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.fillFieldsAndUploadLicense)),
      );
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/chauffeurs/demandes'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'nom': lastName,
          'prenom': firstName,
          'telephone': phone,
          'email': email,
          'numeroPermit': permit,
          'message': message,
          'permisFile': permitUrl,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.requestSentSuccess)),
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
            content: Text(l10n.sendErrorWithBody(response.body)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorNetwork(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registrationForm),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(l10n.familyName),
            const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              decoration: _buildInputDecoration(l10n.enterYourName),
            ),
            const SizedBox(height: 16),
            _buildLabel(l10n.firstName),
            const SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              decoration: _buildInputDecoration(l10n.enterYourFirstName),
            ),
            const SizedBox(height: 16),
            _buildLabel(l10n.phoneNumber),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: _buildInputDecoration(l10n.typeYourPhone),
            ),
            const SizedBox(height: 16),
            _buildLabel(l10n.email),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: _buildInputDecoration(l10n.enterYourEmail),
            ),
            const SizedBox(height: 16),
            _buildLabel(l10n.licenseNumber),
            const SizedBox(height: 8),
            TextField(
              controller: _permitController,
              decoration: _buildInputDecoration(l10n.enterLicenseNumber),
            ),
            const SizedBox(height: 16),
            _buildLabel(l10n.messages),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: _buildInputDecoration(l10n.writeYourMessage),
            ),
            const SizedBox(height: 16),
            _buildLabel(l10n.uploadImagesLabel),
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
                      _uploadedFileName ?? l10n.myLicensePdf,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_cloudinaryUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(
                  _cloudinaryUrl!,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
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
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(l10n.submit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      '$text *',
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
