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
  String? _selectedChauffeurId;
  bool _pendingAccepted = false;
  Timer? _pendingStatusTimer;
  DateTime? _lastLocationSentAt;
  Position? _lastLocationSent;
  StreamSubscription<Position>? _posSub;
  StreamSubscription<User?>? _authSub;
  double _sheetSize = 0.25;
  Timer? _nearbyTimer;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _init();
    _nearbyTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (!mounted) return;
      await _loadNearby(silent: true);
    });
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
    _nearbyTimer?.cancel();
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

  Future<void> _submitSelectedChauffeur() async {
    final selectedId = _selectedChauffeurId;
    if (selectedId == null) return;
    final selected = _chauffeurs
        .where((c) => c['_id']?.toString() == selectedId)
        .cast<Map<String, dynamic>>()
        .toList();
    if (selected.isEmpty) return;
    await _callChauffeur(selected.first);
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
        // On ne bloque l'annulation que si le serveur prouve une acceptation explicite.
        // Si "accepted" est arrivé par erreur côté backend (ancien bug), on retente.
        try {
          final baseUrl2 = getBaseUrl();
          final details = await http.get(
            Uri.parse('$baseUrl2/tricycles/contacts/$contactId'),
            headers: {'Authorization': 'Bearer $token'},
          );
          final body = details.statusCode == 200
              ? (jsonDecode(details.body) as Map<String, dynamic>)
              : null;
          final contact = body?['contact'] as Map<String, dynamic>?;
          final acceptedAt = contact?['acceptedAt'];

          if (acceptedAt == null) {
            final retry = await http.post(
              Uri.parse('$baseUrl2/tricycles/contacts/$contactId/close'),
              headers: {'Authorization': 'Bearer $token'},
            );
            if (retry.statusCode == 200) {
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
              return;
            }
          }
        } catch (_) {}

        AuthMessagePopup.showWarning(
          context,
          title: 'La demande ne peut plus être annulée.',
          subtitle: 'Le chauffeur a déjà accepté la demande.',
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
            AppLocalizations.of(context)?.tricycle_home_title ?? 'Tricycles',
            style: const TextStyle(color: Color(0xFF000000)), // Titre en noir
        ),
        backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo
        foregroundColor: const Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final sheetH = h * _sheetSize;
          final mapBottomRadius = sheetH <= (h * 0.26) ? 26.0 : 18.0;

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: sheetH,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(mapBottomRadius),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        center: LatLng(
                          _position?.latitude ?? 6.3654,
                          _position?.longitude ?? 2.4183,
                        ),
                        zoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.tranoo.tranoo_pro',
                        ),
                        MarkerLayer(
                          markers: _chauffeurs
                              .where((c) =>
                                  c['latitude'] != null &&
                                  c['longitude'] != null)
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
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: sheetH,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    // Même background que marque.dart pour Services
                    color: const Color(0xFFF8BF13).withOpacity(0.25),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(
                      color: const Color(0xFFF8BF13).withOpacity(0.35),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                ),
              ),
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (n) {
                  final next = n.extent.clamp(0.25, 0.75);
                  if ((next - _sheetSize).abs() > 0.001) {
                    setState(() => _sheetSize = next);
                  }
                  return false;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.25,
                  maxChildSize: 0.75,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: 46,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _buildBottomPanel(scrollController),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel(ScrollController scrollController) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF8BF13)),
      );
    }
    if (_error != null) return _buildErrorState(_error!);
    if (_chauffeurs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_bike, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun tricycle disponible pour le moment.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _ensureLocationReady();
        await _sendLocationIfNeeded(force: true);
        await _loadNearby();
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80), // Padding bas augmenté pour voir le contenu
        itemCount: _chauffeurs.length + 1,
        itemBuilder: (context, index) {
          if (index == _chauffeurs.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20), // Padding bas pour voir le bouton
              child: _buildBottomActionButton(),
            );
          }
          final chauffeur = _chauffeurs[index];
          return _buildChauffeurCard(chauffeur);
        },
      ),
    );
  }

  Widget _buildChauffeurCard(Map<String, dynamic> chauffeur) {
    final chauffeurId = chauffeur['_id'].toString();
    final isSelected =
        _selectedChauffeurId != null && _selectedChauffeurId == chauffeurId;

    // Même background que marque.dart pour Services
    final bg = const Color(0xFFF8BF13).withOpacity(0.25);
    
    // Extraire les données du chauffeur
    final status = chauffeur['status'] as String? ?? 'unknown';
    final distanceKm = (chauffeur['distanceKm'] as num?)?.toDouble();
    final eta = (chauffeur['etaMinutes'] as num?)?.toInt();
    
    // Couleur du statut
    Color statusColor;
    switch (status) {
      case 'available':
        statusColor = Colors.green;
        break;
      case 'busy':
        statusColor = Colors.orange;
        break;
      case 'out_of_range':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF8BF13).withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => _selectedChauffeurId = chauffeurId);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8BF13).withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/tricycle.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          distanceKm != null
                              ? '${distanceKm.toStringAsFixed(2)} Km'
                              : 'Distance inconnue',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        if (eta != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${eta.toInt()} min',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status == 'available'
                              ? 'Disponible'
                              : status == 'out_of_range'
                                  ? 'Loin'
                                  : 'Occupé',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? const Color(0xFFB8860B) : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionButton() {
    final selectedId = _selectedChauffeurId;
    if (selectedId == null) {
      return const SizedBox.shrink();
    }

    final isSelectedPending = _pendingChauffeurId == selectedId;
    if (isSelectedPending) {
      if (_pendingAccepted) {
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Color(0xFFB8860B)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: null,
          child: const Text(
            'Demande acceptée',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8860B),
            ),
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFB8860B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: null,
              child: const Text(
                'Demande envoyée',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8860B),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _cancelRequest,
              child: const Text(
                'Annuler',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    Map<String, dynamic> chauffeur = {};
    for (final c in _chauffeurs) {
      if (c['_id']?.toString() == selectedId) {
        chauffeur = c;
        break;
      }
    }
    final canContact = chauffeur['canContact'] == true;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8BF13), 
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: canContact ? _submitSelectedChauffeur : null,
        icon: const _PulseCallIcon(),
        label: const Text(
          'Commander · Tricycle',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PulseCallIcon extends StatefulWidget {
  const _PulseCallIcon();

  @override
  State<_PulseCallIcon> createState() => _PulseCallIconState();
}

class _PulseCallIconState extends State<_PulseCallIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale1 = 1.0 + (t * 0.55);
        final scale2 = 1.0 + ((1 - t) * 0.75);
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF8BF13).withOpacity(0.22 * (t)),
                ),
              ),
            ),
            Transform.scale(
              scale: scale1,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF8BF13).withOpacity(0.28 * (1 - t)),
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF8BF13),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/tricycle.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
