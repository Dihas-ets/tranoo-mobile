import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/data/screens/transitaires_list_page.dart';
import 'package:tranoo/data/screens/transitaire_profile_page.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/transit_mission_service.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/utils/tranoo_toast.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';
import 'package:tranoo/widgets/transitaire_public_ui.dart';

const RouteSettings kTransitaireFlowRoute = RouteSettings(name: 'transitaire_flow');

/// Bandeau transitaires — avatars carrés horizontaux (style « Send Again »).
class TransitaireCarouselSection extends StatefulWidget {
  final bool showTitle;
  final bool showSeeMoreButton;
  final String? articleId;
  /// Avant d'ouvrir la liste ou un profil transitaire.
  final Future<bool> Function()? beforeBrowseTransitaire;
  /// Avant de confirmer le choix d'un transitaire.
  final Future<bool> Function()? beforeSelectTransitaire;
  final VoidCallback? onSelectSuccess;

  const TransitaireCarouselSection({
    super.key,
    this.showTitle = true,
    this.showSeeMoreButton = true,
    this.articleId,
    this.beforeBrowseTransitaire,
    this.beforeSelectTransitaire,
    this.onSelectSuccess,
  });

  @override
  State<TransitaireCarouselSection> createState() =>
      _TransitaireCarouselSectionState();
}

class _TransitaireCarouselSectionState extends State<TransitaireCarouselSection> {
  List<Map<String, dynamic>> _transitaires = [];
  bool _loading = true;

  static const double _photoSize = 84;

  @override
  void initState() {
    super.initState();
    _loadTransitaires();
  }

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
          final aSub = TransitairePublicUi.isSubscribed(a) ? 0 : 1;
          final bSub = TransitairePublicUi.isSubscribed(b) ? 0 : 1;
          return aSub.compareTo(bSub);
        });
        setState(() {
          _transitaires = all;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _ensureCanBrowse() async {
    if (widget.beforeBrowseTransitaire != null) {
      return widget.beforeBrowseTransitaire!();
    }
    return true;
  }

  Future<bool> _ensureCanSelect() async {
    if (widget.beforeSelectTransitaire != null) {
      return widget.beforeSelectTransitaire!();
    }
    return true;
  }

  void _openList() async {
    if (!await _ensureCanBrowse()) return;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: kTransitaireFlowRoute,
        builder: (_) => TransitairesListPage(
          articleId: widget.articleId,
          beforeBrowseTransitaire: widget.beforeBrowseTransitaire,
          beforeSelectTransitaire: widget.beforeSelectTransitaire,
          onSelectSuccess: widget.onSelectSuccess,
        ),
      ),
    );
  }

  Future<void> _openTransitaireProfile(Map<String, dynamic> user) async {
    final articleId = widget.articleId;
    if (articleId == null || articleId.isEmpty) {
      _openList();
      return;
    }
    if (!await _ensureCanBrowse()) return;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: kTransitaireFlowRoute,
        builder: (_) => TransitaireProfilePage(
          transitaire: user,
          articleId: articleId,
          beforeSelectTransitaire: widget.beforeSelectTransitaire,
          onTransitaireSelected: () => _selectTransitaire(user),
        ),
      ),
    );
  }

  Future<void> _selectTransitaire(Map<String, dynamic> user) async {
    final articleId = widget.articleId;
    final transitaireId = user['_id']?.toString();
    if (articleId == null || transitaireId == null) return;
    if (!await _ensureCanSelect()) return;
    if (!mounted) return;

    final result = await withTranooLoading(
      context,
      () => TransitMissionService.instance.selectTransitaire(
        articleId: articleId,
        transitaireId: transitaireId,
      ),
    );
    if (!mounted) return;

    if (result.ok) {
      Navigator.of(context).popUntil(
        (route) => route.settings.name != kTransitaireFlowRoute.name,
      );
      if (!mounted) return;
      widget.onSelectSuccess?.call();
    } else if (result.error != null) {
      showTranooToast(context, message: result.error!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const TransitaireCarouselSkeleton();
    }
    if (_transitaires.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showSeeMoreButton && !widget.showTitle) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openList,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(l10n.seeMoreForwarders),
              style: TextButton.styleFrom(
                foregroundColor: kTransitaireNavy,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (widget.showTitle) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kTransitaireAmber.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 18,
                  color: kTransitaireNavy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.recommendedForwarders,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kTransitaireNavy,
                  ),
                ),
              ),
              if (widget.showSeeMoreButton)
                TextButton.icon(
                  onPressed: _openList,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(l10n.seeMoreForwarders),
                  style: TextButton.styleFrom(
                    foregroundColor: kTransitaireNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _transitaires.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                TransitaireSquareAvatarCard(
                  user: _transitaires[i],
                  l10n: l10n,
                  photoSize: _photoSize,
                  compact: true,
                  onTap: () => _openTransitaireProfile(_transitaires[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class TransitaireCarouselSkeleton extends StatelessWidget {
  const TransitaireCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
            child: const SizedBox(
              width: 92,
              child: Column(
                children: [
                  SkeletonBox(
                    width: 84,
                    height: 84,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  SizedBox(height: 8),
                  SkeletonLine(widthFactor: 0.9, height: 11),
                  SizedBox(height: 4),
                  SkeletonLine(widthFactor: 0.5, height: 10),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
