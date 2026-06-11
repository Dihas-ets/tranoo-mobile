import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/data/screens/transitaire_profile_page.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';

/// Liste complète des transitaires (abonnés en tête).
class TransitairesListPage extends StatefulWidget {
  const TransitairesListPage({super.key});

  @override
  State<TransitairesListPage> createState() => _TransitairesListPageState();
}

class _TransitairesListPageState extends State<TransitairesListPage> {
  List<Map<String, dynamic>> _transitaires = [];
  bool _loading = true;

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
            .where((u) => u is Map)
            .map((u) => Map<String, dynamic>.from(u as Map))
            .toList();
        all.sort((a, b) {
          final aSub = a['hasSubscription'] == true ? 0 : 1;
          final bSub = b['hasSubscription'] == true ? 0 : 1;
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

  bool _isSubscribed(Map<String, dynamic> u) =>
      u['hasSubscription'] == true || u['subscriptionStatus'] == 'active';

  void _openProfile(Map<String, dynamic> u) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransitaireProfilePage(transitaire: u),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.forwardersTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: kTransitaireNavy,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: kTransitaireNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => const SkeletonBox(
                height: 72,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            )
          : _transitaires.isEmpty
              ? Center(
                  child: Text(
                    l10n.noForwardersAvailable,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transitaires.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final u = _transitaires[index];
                    final name = TransitaireProfileHelpers.displayName(u);
                    final photo = TransitaireProfileHelpers.photoUrl(u);
                    final location =
                        TransitaireProfileHelpers.locationLine(u);
                    final subscribed = _isSubscribed(u);

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: subscribed ? 3 : 1,
                      shadowColor: subscribed
                          ? kTransitaireAmber.withOpacity(0.35)
                          : Colors.black12,
                      child: InkWell(
                        onTap: () => _openProfile(u),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: subscribed
                                  ? kTransitaireAmber.withOpacity(0.5)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: kTransitaireNavy.withOpacity(0.08),
                                backgroundImage:
                                    photo != null ? NetworkImage(photo) : null,
                                child: photo == null
                                    ? Text(
                                        TransitaireProfileHelpers.initials(u),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kTransitaireNavy,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: kTransitaireNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      location,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: subscribed
                                      ? kTransitaireAmber.withOpacity(0.2)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      subscribed
                                          ? Icons.star_rounded
                                          : Icons.person_outline,
                                      size: 14,
                                      color: subscribed
                                          ? kTransitaireAmber
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      subscribed
                                          ? l10n.forwarderSubscribedShort
                                          : l10n.forwarderStandardShort,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: subscribed
                                            ? kTransitaireNavy
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
