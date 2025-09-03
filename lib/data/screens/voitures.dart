import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'cars_info.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'create_sell.dart';

class VoituresPage extends StatefulWidget {
  const VoituresPage({super.key});

  @override
  State<VoituresPage> createState() => _VoituresPageState();
}

class _VoituresPageState extends State<VoituresPage> {
  List<dynamic> voitures = [];
  bool isLoading = true;
  String? error;
  List<bool> _isVisible = [];

  @override
  void initState() {
    super.initState();
    fetchVoitures();
  }

  Future<void> fetchVoitures() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final userService = UserService();
      final role = userService.currentRole;
      final userId = user?.uid;
      String url = getBaseUrl() + '/articles?type=voiture&statut=en_ligne';
      if (role == UserRole.vendeur && userId != null) {
        url += '&vendeur=$userId';
      }
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
          voitures = data;
          _isVisible = List.generate(data.length, (index) => true);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors du chargement des voitures';
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

  Future<void> _deleteVoiture(String articleId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Voulez-vous vraiment supprimer cette voiture ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    setState(() {
      _isVisible[index] = false;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final response = await http.delete(
        Uri.parse(getBaseUrl() + '/articles/$articleId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voiture supprimée avec succès !')),
        );
        fetchVoitures();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau ou serveur.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final isVendeur = userService.currentRole == UserRole.vendeur;

    final isAcheteurOrTransitaire =
        userService.currentRole == UserRole.acheteur ||
        userService.currentRole == UserRole.transitaire;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures en ligne'),
        backgroundColor: Colors.amber,
        actions: [
          if (isVendeur)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSellPage(),
                  ),
                );
              },
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : voitures.isEmpty
              ? Center(
                child: Text(
                  isVendeur
                      ? "Vous n'avez aucune voiture en ligne"
                      : "Aucune voiture disponible pour le moment.",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: voitures.length,
                itemBuilder: (context, index) {
                  final voiture = voitures[index];
                  return AnimatedOpacity(
                    opacity: _isVisible[index] ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CarsInfo(
                                      id:
                                          (voiture['_id'] ??
                                                  voiture['id'] ??
                                                  voiture['articleId'] ??
                                                  voiture['Id'] ??
                                                  voiture['article'])
                                              ?.toString(),
                                      titre: voiture['titre'] ?? '',
                                      description: voiture['description'] ?? '',
                                      marque: voiture['marque'] ?? '',
                                      modele:
                                          voiture['modele']?.toString() ?? '',
                                      annee: voiture['annee'] ?? '',
                                      prix: voiture['prix']?.toString() ?? '',
                                      condition: voiture['condition'],
                                      boiteVitesse: voiture['boiteVitesse'],
                                      carburant: voiture['carburant'],
                                      climatiseur: voiture['climatiseur'],
                                      distance: voiture['distance'],
                                      sieges: voiture['sieges'],
                                      portes: voiture['portes'],
                                      cylindre: voiture['cylindre'],
                                      images:
                                          (voiture['photos'] as List?)
                                              ?.map((e) => e.toString())
                                              .toList() ??
                                          [],
                                      video: voiture['video'],
                                      entreprise: voiture['entreprise'],
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    (voiture['photos'] as List?)?.isNotEmpty ==
                                            true
                                        ? Image.network(
                                          voiture['photos'][0],
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          height: 140,
                                          width: double.infinity,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (voiture['marque'] ?? '') +
                                    ' ' +
                                    (voiture['modele']?.toString() ?? ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                voiture['prix']?.toString() ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isVendeur)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 24,
                              ),
                              onPressed: () {
                                _deleteVoiture(voiture['_id'] ?? '', index);
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
