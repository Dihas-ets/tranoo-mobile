import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tranoo/services/user_service.dart';

class MesAchatsPage extends StatefulWidget {
  MesAchatsPage({super.key});

  @override
  State<MesAchatsPage> createState() => _MesAchatsPageState();
}

class _MesAchatsPageState extends State<MesAchatsPage> {
  List<Map<String, dynamic>> achats = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAchats();
  }

  Future<void> fetchAchats() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url = getBaseUrl() + '/achats';
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
        setState(() {
          error = 'Erreur lors du chargement des achats';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur réseau';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        title: const Text("Mes Achats"),
      ),
      body: ListView.builder(
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
                  Text("Statut : ${achat['statut']}"),
                  Text("Date de livraison : ${achat['date']}"),
                  Text("Lieu de livraison : ${achat['lieu']}"),
                  if (achat['carburant'] != "-")
                    Text("Type de carburant : ${achat['carburant']}"),
                  Text("Couleur : ${achat['couleur']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
