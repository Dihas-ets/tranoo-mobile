import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'dart:io';
import 'historique_transit.dart';

class FormulaireTransitPage extends StatefulWidget {
  const FormulaireTransitPage({super.key});

  @override
  State<FormulaireTransitPage> createState() => _FormulaireTransitPageState();
}

class _FormulaireTransitPageState extends State<FormulaireTransitPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final TextEditingController _voitureController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _portDepartController = TextEditingController();
  final TextEditingController _portArriveeController = TextEditingController();
  final TextEditingController _dateTransitController = TextEditingController();
  final TextEditingController _statutController = TextEditingController();

  final List<File> _documents = [];

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _documents.add(File(pickedFile.path));
      });
    }
  }

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoriqueTransitPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.transitFormTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              l10n: l10n,
              controller: _voitureController,
              label: l10n.carNameLabel,
              hintText: l10n.carNameExample,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n: l10n,
              controller: _clientController,
              label: l10n.clientField,
              hintText: l10n.clientExample,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n: l10n,
              controller: _portDepartController,
              label: l10n.departurePortField,
              hintText: l10n.departurePortExample,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n: l10n,
              controller: _portArriveeController,
              label: l10n.arrivalPortField,
              hintText: l10n.arrivalPortExample,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n: l10n,
              controller: _dateTransitController,
              label: l10n.transitDateField,
              hintText: l10n.transitDateExample,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n: l10n,
              controller: _statutController,
              label: l10n.status,
              hintText: l10n.inTransit,
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  IconButton(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                  Text(
                    l10n.uploadDocuments,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _documents.map((file) {
                return GestureDetector(
                  onTap: () {},
                  child: Text(
                    file.path.split('/').last,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.submit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required AppLocalizations l10n,
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: const UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
