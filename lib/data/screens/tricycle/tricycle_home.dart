import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/widgets/auth_message_popup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tranoo/services/user_service.dart';
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
  String? _pendingChauffeurId;
  String? _pendingContactId;
  bool _pendingAccepted = false;
  Timer? _pendingStatusTimer;
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
    _pendingStatusTimer?.cancel();
    super.dispose();
  }

  void _startPendingStatusWatch() {
    _pendingStatusTimer?.cancel();
    final contactId = _pendingContactId;
    if (contactId == null || contactId.isEmpty) return;
    _pendingStatusTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _refreshPendingContactStatus();
    });
  }

  Future<void> _refreshPendingContactStatus() async {
    final contactId = _pendingContactId;
    if (contactId == null || contactId.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final token = await user.getIdToken();
      if (token == null) return;
      final baseUrl = getBaseUrl();
      final res = await http.get(
        Uri.parse('$baseUrl/tricycles/contacts/$contactId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final contact = data['contact'] as Map<String, dynamic>?;
      final status = contact?['status']?.toString();
      if (status == 'accepted' && mounted) {
        setState(() {
          _pendingAccepted = true;
        });
        _pendingStatusTimer?.cancel();
      }
    } catch (_) {}
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
      AuthMessagePopup.showError(
        context,
        title: 'Vous devez vous connecter pour continuer.',
        subtitle: 'Connectez-vous pour pouvoir commander un tricycle.',
        buttonText: 'OK',
      );
      return;
    }

    if (chauffeur['canContact'] != true) return;
    try {
      final payload = await _createContact(chauffeur['_id'] as String);
      final contact = payload['contact'] as Map<String, dynamic>?;
      final contactId = (contact?['_id'] ?? payload['contactId'])?.toString();

      if (contactId != null && contactId.isNotEmpty) {
        if (mounted) {
          setState(() {
            _pendingChauffeurId = chauffeur['_id'] as String;
            _pendingContactId = contactId;
            _pendingAccepted = false;
          });
        }
        _startPendingStatusWatch();
      }
      if (!mounted) return;
      AuthMessagePopup.showInfo(
        context,
        title: 'Demande envoyée au chauffeur.',
      );
    } catch (e) {
      if (!mounted) return;
      AuthMessagePopup.showError(
        context,
        title: 'Une erreur est survenue.',
        subtitle: 'Vérifiez votre connexion internet puis réessayez.',
        buttonText: 'Réessayer',
      );
    }
  }

  Future<void> _cancelRequest() async {
    final contactId = _pendingContactId;
    if (contactId == null || contactId.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final token = await user.getIdToken();
      if (token == null) return;

      final baseUrl = getBaseUrl();
      final res = await http.post(
        Uri.parse('$baseUrl/tricycles/contacts/$contactId/close'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() {
          _pendingChauffeurId = null;
          _pendingContactId = null;
          _pendingAccepted = false;
        });
        _pendingStatusTimer?.cancel();
        AuthMessagePopup.showSuccess(
          context,
          title: 'Votre demande a été annulée.',
        );
      } else if (res.statusCode == 403) {
        // Annulation impossible uniquement si la demande a été acceptée.
        setState(() {
          _pendingChauffeurId = null;
          _pendingContactId = null;
          _pendingAccepted = false;
        });
        _pendingStatusTimer?.cancel();
        AuthMessagePopup.showWarning(
          context,
          title: 'La demande ne peut plus être annulée.',
          subtitle: 'Le chauffeur a déjà pris en charge ou clôturé la demande.',
        );
      } else {
        AuthMessagePopup.showError(
          context,
          title: "Impossible d'annuler la demande.",
          subtitle: 'Code: ${res.statusCode}. Veuillez réessayer.',
          buttonText: 'Réessayer',
        );
      }
    } catch (e) {
      if (mounted) {
        AuthMessagePopup.showError(
          context,
          title: 'Erreur lors de l’annulation.',
          subtitle: 'Vérifiez votre connexion puis réessayez.',
          buttonText: 'Réessayer',
        );
      }
    }
  }

  // _messageChauffeur et _openDirections ne sont plus utilisés côté acheteur

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
                  markers: _chauffeurs
                      .where((c) =>
                          c['latitude'] != null && c['longitude'] != null)
                      .map<Marker>((chauffeur) {
                    return Marker(
                      point: LatLng(
                        (chauffeur['latitude'] as num).toDouble(),
                        (chauffeur['longitude'] as num).toDouble(),
                      ),
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 32.0,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Partie inférieure : panneau type "bottom sheet" avec les tricycles
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFF8BF13)))
                  : _error != null
                      ? _buildErrorState(_error!)
                      : _chauffeurs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.directions_bike,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucun tricycle disponible pour le moment.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
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
                                padding: const EdgeInsets.fromLTRB(
                                    16, 12, 16, 24),
                                itemCount: _chauffeurs.length,
                                itemBuilder: (context, index) {
                                  final chauffeur = _chauffeurs[index];
                                  return _buildChauffeurCard(chauffeur);
                                },
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChauffeurCard(Map<String, dynamic> chauffeur) {
    final distanceKm = chauffeur['distanceKm'] as num?;
    final eta = chauffeur['etaMinutes'] as num?;
    final status = (chauffeur['status'] ?? '') as String;
    final statusColor = switch (chauffeur['statusColor']) {
      'green' => Colors.green,
      'red' => Colors.red,
      _ => Colors.orange,
    };
    final isPending = _pendingChauffeurId != null &&
        _pendingChauffeurId == chauffeur['_id']?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // L'acheteur ne gère pas l'itinéraire, uniquement la commande.
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icône véhicule (image fournie côté app)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/tricycle.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tricycle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              distanceKm != null
                                  ? '${distanceKm.toStringAsFixed(2)} Km'
                                  : 'Distance inconnue',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (eta != null)
                              Text(
                                '• ${eta.toInt()} min',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status == 'available'
                              ? 'Disponible'
                              : status == 'out_of_range'
                                  ? 'Loin'
                                  : 'Occupé',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${chauffeur['prenoms'] ?? ''} ${chauffeur['nom'] ?? ''}'
                        .trim()
                        .isEmpty
                        ? 'Chauffeur tricycle'
                        : '${chauffeur['prenoms'] ?? ''} ${chauffeur['nom'] ?? ''}'
                            .trim(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    chauffeur['telephone'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              isPending
                  ? Row(
                      children: [
                        if (_pendingAccepted) ...[
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side:
                                    const BorderSide(color: Color(0xFF05C46B)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: null,
                              child: const Text(
                                'Demande acceptée',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF05C46B),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side:
                                    const BorderSide(color: Color(0xFF05C46B)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: null,
                              child: const Text(
                                'Demande envoyée',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF05C46B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFE5E5),
                                foregroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: _cancelRequest,
                              child: const Text(
                                'Annuler',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF05C46B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: chauffeur['canContact'] == true
                            ? () => _callChauffeur(chauffeur)
                            : null,
                        child: const Text(
                          'Commander · Tricycle',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
