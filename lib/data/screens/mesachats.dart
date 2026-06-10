import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class MesAchatsPage extends StatefulWidget {
  const MesAchatsPage({super.key});

  @override
  State<MesAchatsPage> createState() => _MesAchatsPageState();
}

class _MesAchatsPageState extends State<MesAchatsPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  List<Map<String, dynamic>> achats = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAchats();
  }

  Future<void> fetchAchats() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final url = '${getBaseUrl()}/achats';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          achats = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          error = l10n.purchasesLoadError;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        error = l10n.networkOrServerError;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        title: Text(l10n.myPurchases),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: achats.length,
                  itemBuilder: (context, index) {
                    final achat = achats[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achat['produit']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(l10n.purchaseStatusLabel(achat['statut'] ?? '')),
                            Text(l10n.deliveryDateLabel(achat['date'] ?? '')),
                            Text(l10n.deliveryLocationLabel(achat['lieu'] ?? '')),
                            if (achat['carburant'] != '-')
                              Text(l10n.fuelTypeLabel(achat['carburant'] ?? '')),
                            Text(l10n.colorLabel(achat['couleur'] ?? '')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
