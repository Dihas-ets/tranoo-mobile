import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mastervacpage.dart';
import 'create_sell2.dart';
import 'package:tranoo/utils/role_redirect.dart';

class Piece extends StatefulWidget {
  const Piece({super.key});

  @override
  State<Piece> createState() => _PieceState();
}

class _PieceState extends State<Piece> {
  List<dynamic> pieces = [];
  bool isLoading = true;
  String? error;
  List<bool> _isVisible = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    fetchPieces();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> fetchPieces() async {
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
      String url = getBaseUrl() + '/articles?type=piece&statut=en_ligne';
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
          pieces = data;
          _isVisible = List.generate(data.length, (index) => true);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors du chargement des pièces';
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

  Future<void> _deletePiece(String articleId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer cette pièce ?'),
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
          const SnackBar(content: Text('Pièce supprimée avec succès !')),
        );
        fetchPieces();
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
    final isAcheteurOuChauffeur =
        userService.isAcheteur || userService.isChauffeur;
    final filteredPieces =
        pieces.where((p) {
          final title = (p['titre'] ?? '').toString().toLowerCase();
          return _searchText.isEmpty || title.contains(_searchText);
        }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pièces détachées'),
        backgroundColor: Colors.amber,
        actions:
            isVendeur
                ? [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateSellPage2(),
                        ),
                      ).then((_) => fetchPieces());
                    },
                  ),
                ]
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une pièce...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Message pour acheteur ou chauffeur
            if (isAcheteurOuChauffeur)
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16),
              //   child: Text(
              //     'Vous êtes acheteur ou chauffeur',
              //     style: TextStyle(
              //       color: Colors.blue,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // Grille des pièces
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : error != null
                        ? Center(child: Text(error!))
                        : filteredPieces.isEmpty
                        ? Center(
                          child: Text(
                            isVendeur
                                ? "Vous n'avez aucune pièce en ligne actuellement"
                                : "Aucune pièce en ligne actuellement",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        )
                        : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: filteredPieces.length,
                          itemBuilder: (context, index) {
                            final piece = filteredPieces[index];
                            final pieceId = piece['_id'] ?? '';
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
                                              (context) => MastervacPage(
                                                id:
                                                    (piece['_id'] ??
                                                            piece['id'] ??
                                                            piece['articleId'] ??
                                                            piece['Id'] ??
                                                            piece['article'])
                                                        ?.toString(),
                                                isAcheteur: !isVendeur,
                                                title: piece['titre'] ?? '',
                                                year: piece['annee'] ?? '',
                                                description:
                                                    piece['description'] ?? '',
                                                company:
                                                    piece['entreprise'] ?? '',
                                                location:
                                                    piece['localisation'] ?? '',
                                                price:
                                                    piece['prix']?.toString() ??
                                                    '',
                                                images:
                                                    (piece['photos'] as List?)
                                                        ?.map(
                                                          (e) => e.toString(),
                                                        )
                                                        .toList() ??
                                                    [],
                                                fuelType: piece['typeMoteur'],
                                                model:
                                                    piece['modele']?.toString(),
                                                pieceType: piece['pieceType'],
                                                video: piece['video'],
                                              ),
                                        ),
                                      ).then((_) => fetchPieces());
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child:
                                              (piece['photos'] as List?)
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? Image.network(
                                                    piece['photos'][0],
                                                    height: 40,
                                                    width: 40,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    height: 40,
                                                    width: 40,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          piece['titre'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isVendeur)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _deletePiece(pieceId, index);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
          ],
        ),
      ),
    );
  }
}
