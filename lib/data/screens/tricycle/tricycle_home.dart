import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/data/screens/discussion.dart';
import 'package:tranoo/data/screens/connexion_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TricycleHomePage extends StatefulWidget {
  const TricycleHomePage({super.key});

  @override
  State<TricycleHomePage> createState() => _TricycleHomePageState();
}

class _TricycleHomePageState extends State<TricycleHomePage> {
  bool _loading = true;
  String? _error;
  Position? _position;
  List<Map<String, dynamic>> _chauffeurs = [];
  DateTime? _lastLocationSentAt;
  Position? _lastLocationSent;
  StreamSubscription<Position>? _posSub;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _init();
    // Écouter les changements d'authentification
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        // Utilisateur connecté, recharger les données
        _loadNearby();
        _sendLocationIfNeeded(force: true);
      } else if (mounted) {
        // Utilisateur déconnecté, vider la liste
        setState(() {
          _chauffeurs = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _ensureLocationReady();
      await _sendLocationIfNeeded(force: true);
      await _loadNearby();
      _startTracking();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted, initialize location
      await _ensureLocationReady();
    } else if (status.isDenied) {
      // Permission denied, show a message to the user
      if (mounted) {
        setState(() {
          _error =
              'Permission de localisation refusée. Veuillez l\'activer dans les paramètres.';
        });
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, guide user to settings
      if (mounted) {
        setState(() {
          _error =
              'Permission de localisation bloquée. Veuillez l\'activer dans les paramètres.';
        });
      }
      await openAppSettings();
    }
  }

  Future<void> _ensureLocationReady() async {
    try {
      final status = await Permission.location.status;
      if (status.isDenied) {
        final newStatus = await Permission.location.request();
        if (!newStatus.isGranted) {
          throw Exception('Permission de localisation refusée.');
        }
      } else if (status.isPermanentlyDenied) {
        throw Exception(
            'Permission de localisation bloquée. Veuillez l\'activer dans les paramètres.');
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _position = pos;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la localisation : $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  void _startTracking() {
    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((pos) async {
      _position = pos;
      if (mounted) setState(() {});
      await _sendLocationIfNeeded();
      // rafraîchir la liste (sans spam)
      await _loadNearby(silent: true);
    });
  }

  Future<void> _sendLocationIfNeeded({bool force = false}) async {
    final pos = _position;
    if (pos == null) return;

    // Vérifier si l'utilisateur est connecté avant d'envoyer la localisation
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Pas d'envoi si non connecté

    final now = DateTime.now();
    if (!force && _lastLocationSentAt != null) {
      final seconds = now.difference(_lastLocationSentAt!).inSeconds;
      final moved = _lastLocationSent == null
          ? true
          : Geolocator.distanceBetween(
                _lastLocationSent!.latitude,
                _lastLocationSent!.longitude,
                pos.latitude,
                pos.longitude,
              ) >
              50;
      if (seconds < 5 && !moved) return;
    }

    final token = await user.getIdToken();
    if (token == null) return;

    try {
      final baseUrl = getBaseUrl(); // inclut /api
      await http.post(
        Uri.parse('$baseUrl/tricycles/location'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      _lastLocationSentAt = now;
      _lastLocationSent = pos;
    } catch (e) {
      // Ignorer les erreurs silencieusement pour ne pas interrompre l'expérience utilisateur
      print('Erreur envoi localisation: $e');
    }
  }

  Future<void> _loadNearby({bool silent = false}) async {
    final pos = _position;
    if (pos == null) {
      if (!silent && mounted) {
        setState(() {
          _error =
              'Localisation non disponible. Veuillez activer la localisation.';
        });
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!silent && mounted) {
        setState(() {
          _chauffeurs = [];
          _error =
              'Vous devez être connecté pour voir les tricycles disponibles.';
        });
      }
      return;
    }

    if (!silent) {
      setState(() {
        _error = null;
      });
    }

    try {
      final token = await user.getIdToken();
      if (token == null) {
        if (!silent && mounted) {
          setState(() {
            _chauffeurs = [];
          });
        }
        return;
      }

      final baseUrl = getBaseUrl();
      final uri =
          Uri.parse('$baseUrl/tricycles/nearby').replace(queryParameters: {
        'lat': pos.latitude.toString(),
        'lng': pos.longitude.toString(),
      });

      debugPrint('URL appelée: $uri');
      debugPrint('Token: ${token.substring(0, 20)}...');
      debugPrint('Position: ${pos.latitude}, ${pos.longitude}');

      final client = http.Client();
      final res = await client.get(uri, headers: {
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 10));

      debugPrint('Réponse status: ${res.statusCode}');
      debugPrint('Réponse body: ${res.body}');

      if (res.statusCode == 500) {
        debugPrint('Erreur 500 détaillée: ${res.body}');
        throw Exception('Erreur serveur (500). Veuillez réessayer plus tard.');
      } else if (res.statusCode != 200) {
        throw Exception('Erreur chargement tricycles (${res.statusCode})');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = List<Map<String, dynamic>>.from(data['chauffeurs'] ?? []);

      if (mounted) {
        setState(() {
          _chauffeurs = list;
        });
      }
    } catch (e) {
      debugPrint('Erreur complète lors du chargement des tricycles : $e');
      if (!silent && mounted) {
        setState(() {
          _error = 'Erreur serveur. Vérifiez votre connexion internet.';
        });
      }
    }
  }

  Future<Map<String, dynamic>> _createContact(String chauffeurId) async {
    final pos = _position;
    if (pos == null) throw Exception('Localisation indisponible');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Vous devez être connecté pour contacter un chauffeur.');
    }

    final token = await user.getIdToken();
    if (token == null) throw Exception('Vous devez être connecté.');

    final baseUrl = getBaseUrl();
    final res = await http.post(
      Uri.parse('$baseUrl/tricycles/$chauffeurId/contact'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      final body = res.body;
      throw Exception('Impossible de contacter ce chauffeur: $body');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> _callChauffeur(Map<String, dynamic> chauffeur) async {
    // Vérifier si l'utilisateur est connecté
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Veuillez vous connecter pour appeler un chauffeur'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    if (chauffeur['canContact'] != true) return;
    try {
      await _createContact(chauffeur['_id'] as String);
      // Après contact initié, appel direct
      final phone = (chauffeur['telephone'] ?? '').toString();
      if (phone.isEmpty) return;
      final uri = Uri(scheme: 'tel', path: phone);
      await launchUrl(uri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _messageChauffeur(Map<String, dynamic> chauffeur) async {
    // Vérifier si l'utilisateur est connecté
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Veuillez vous connecter pour envoyer un message'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    if (chauffeur['canContact'] != true) return;
    try {
      final payload = await _createContact(chauffeur['_id'] as String);
      final room = payload['room'] as Map<String, dynamic>?;
      final roomId = (payload['roomId'] ?? room?['_id'])?.toString();
      if (roomId == null || roomId.isEmpty || room == null) {
        throw Exception('Room de discussion introuvable');
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Discussion(roomId: roomId, roomData: room),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _openDirections(Map<String, dynamic> chauffeur) async {
    final lat = chauffeur['latitude'];
    final lng = chauffeur['longitude'];
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)?.tricycle_home_title ?? 'Tricycles'),
      ),
      body: Column(
        children: [
          // Partie supérieure : Carte Flutter Map
          Expanded(
            flex: 1,
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(
                    _position?.latitude ?? 6.3654, _position?.longitude ?? 2.4183),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.tranoo.tranoo_pro',
                ),
                MarkerLayer(
                  markers: _chauffeurs.map<Marker>((chauffeur) {
                    return Marker(
                      point: LatLng(chauffeur['latitude'], chauffeur['longitude']),
                      width: 80.0,
                      height: 80.0,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Partie inférieure : Liste des tricycles disponibles
          Expanded(
            flex: 1,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF8BF13)))
                : _error != null
                    ? _buildErrorState(_error!)
                    : _chauffeurs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.directions_bike,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucun tricycle disponible pour le moment.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _ensureLocationReady();
                              await _sendLocationIfNeeded(force: true);
                              await _loadNearby();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _chauffeurs.length,
                              itemBuilder: (context, index) {
                                final chauffeur = _chauffeurs[index];
                                return _buildChauffeurCard(chauffeur);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChauffeurCard(Map<String, dynamic> chauffeur) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Action lors de l'appui sur la carte
          _openDirections(chauffeur);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  chauffeur['photo'] ?? 'https://via.placeholder.com/150',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chauffeur['nom'] ?? 'Nom inconnu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chauffeur['telephone'] ?? 'Téléphone inconnu',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Appeler le chauffeur
                  _callChauffeur(chauffeur);
                },
                icon: const Icon(Icons.phone, color: Color(0xFFF8BF13)),
              ),
              IconButton(
                onPressed: () {
                  // Envoyer un message au chauffeur
                  _messageChauffeur(chauffeur);
                },
                icon: const Icon(Icons.message, color: Color(0xFFF8BF13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
