import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/data/screens/transitaire_profile_page.dart';
import 'package:tranoo/data/screens/transitaires_list_page.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';

/// Carousel transitaires compact — premium jaune Tranoo, standard ardoise.
class TransitaireCarouselSection extends StatefulWidget {
  final bool showTitle;
  final bool showSeeMoreButton;
  final double height;

  const TransitaireCarouselSection({
    super.key,
    this.showTitle = true,
    this.showSeeMoreButton = true,
    this.height = 116,
  });

  @override
  State<TransitaireCarouselSection> createState() =>
      _TransitaireCarouselSectionState();
}

class _TransitaireCarouselSectionState extends State<TransitaireCarouselSection> {
  List<Map<String, dynamic>> _transitaires = [];
  bool _loading = true;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _carouselTimer;
  int _carouselIndex = 0;

  static const _standardGradient = [
    Color(0xFF546E7A),
    Color(0xFF37474F),
  ];

  @override
  void initState() {
    super.initState();
    _loadTransitaires();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  bool _isSubscribed(Map<String, dynamic> u) =>
      u['hasSubscription'] == true || u['subscriptionStatus'] == 'active';

  Future<void> _loadTransitaires() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final res = await http.get(
        Uri.parse(
          '${UserService().dio.options.baseUrl}/users/transitaires/all',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data is List ? data : (data['users'] ?? []);
        final all = (list as List)
            .whereType<Map>()
            .map((u) => Map<String, dynamic>.from(u))
            .toList();
        all.sort((a, b) {
          final aSub = _isSubscribed(a) ? 0 : 1;
          final bSub = _isSubscribed(b) ? 0 : 1;
          return aSub.compareTo(bSub);
        });
        setState(() {
          _transitaires = all;
          _loading = false;
          _carouselIndex = 0;
        });
        _startCarouselTimer();
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    if (_transitaires.length <= 1) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _transitaires.isEmpty) return;
      if (!_pageController.hasClients) return;
      if (_carouselIndex < _transitaires.length - 1) {
        _carouselIndex++;
      } else {
        _carouselIndex = 0;
      }
      _pageController.animateToPage(
        _carouselIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  String _name(Map<String, dynamic> u) {
    final entreprise = (u['entreprise'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) return entreprise;
    final nom = (u['nom'] ?? '').toString().trim();
    final prenoms = (u['prenoms'] ?? '').toString().trim();
    final full = '$prenoms $nom'.trim();
    return full.isNotEmpty ? full : 'Transitaire';
  }

  double _rating(Map<String, dynamic> u) {
    final id = (u['_id'] ?? u['uid'] ?? '').toString();
    if (id.isEmpty) return 4.5;
    final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return 4.0 + (hash % 10) / 10;
  }

  String _locationLine(Map<String, dynamic> u, AppLocalizations l10n) {
    final ville = (u['ville'] ?? '').toString().trim();
    final pays = (u['pays'] ?? '').toString().trim();
    if (ville.isNotEmpty && pays.isNotEmpty) return '$ville · $pays';
    if (pays.isNotEmpty) return pays;
    if (ville.isNotEmpty) return ville;
    return l10n.internationalTransit;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_transitaires.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Text(
            l10n.recommendedForwarders,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _transitaires.length,
            padEnds: false,
            onPageChanged: (i) => _carouselIndex = i,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                child: _buildCard(_transitaires[index], l10n),
              );
            },
          ),
        ),
        if (widget.showSeeMoreButton) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransitairesListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.groups_outlined, size: 16),
              label: Text(l10n.seeMoreForwarders),
              style: OutlinedButton.styleFrom(
                foregroundColor: kTransitaireNavy,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> u, AppLocalizations l10n) {
    final subscribed = _isSubscribed(u);
    if (subscribed) {
      return _buildPremiumCard(u, l10n);
    }
    return _buildStandardCard(u, l10n);
  }

  Widget _buildPremiumCard(Map<String, dynamic> u, AppLocalizations l10n) {
    final name = _name(u);
    final photo = (u['photo'] ?? '').toString();
    final location = _locationLine(u, l10n);

    return GestureDetector(
      onTap: () => _openProfile(u),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              kTransitaireAmber.withOpacity(0.34),
              kTransitaireAmber.withOpacity(0.12),
              Colors.white,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
          border: Border.all(color: kTransitaireAmber.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: kTransitaireAmber.withOpacity(0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: kTransitaireAmber),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Row(
                  children: [
                    Container(
                      decoration: transitairePremiumRingDecoration(),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty
                            ? Text(
                                name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: kTransitaireNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kTransitaireNavy,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 13,
                                color: kTransitaireNavy.withOpacity(0.55),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kTransitaireNavy.withOpacity(0.65),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kTransitaireAmber.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.forwarderPremiumBadge,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: kTransitaireNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TransitaireStarRating(
                          rating: _rating(u),
                          compact: true,
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: kTransitaireNavy.withOpacity(0.35),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardCard(Map<String, dynamic> u, AppLocalizations l10n) {
    final name = _name(u);
    final photo = (u['photo'] ?? '').toString();
    final location = _locationLine(u, l10n);

    return GestureDetector(
      onTap: () => _openProfile(u),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: _standardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _standardGradient.first.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withOpacity(0.18),
                backgroundImage:
                    photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty
                    ? Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.78),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        l10n.forwarderStandardBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.white.withOpacity(0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProfile(Map<String, dynamic> u) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransitaireProfilePage(transitaire: u),
      ),
    );
  }
}

/// Skeleton pour la rangée transitaires sur l'accueil.
class TransitaireCarouselSkeleton extends StatelessWidget {
  final double height;

  const TransitaireCarouselSkeleton({super.key, this.height = 116});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => SkeletonBox(
          width: MediaQuery.sizeOf(context).width * 0.85,
          height: height,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
