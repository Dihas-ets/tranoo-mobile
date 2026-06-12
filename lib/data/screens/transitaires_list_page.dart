import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/data/screens/transitaire_profile_page.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';
import 'package:tranoo/widgets/transitaire_public_ui.dart';

/// Liste transitaires — cartes style « My Booking », sans filtre.
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
            .whereType<Map>()
            .map((u) => Map<String, dynamic>.from(u))
            .toList();
        all.sort((a, b) => TransitairePublicUi.displayName(a)
            .compareTo(TransitairePublicUi.displayName(b)));
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
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(
          l10n.forwardersTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: kTransitaireNavy,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: kTransitaireNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? SkeletonPresets.transitairesList()
          : _transitaires.isEmpty
              ? Center(
                  child: Text(
                    l10n.noForwardersAvailable,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : RefreshIndicator(
                  color: kTransitaireAmber,
                  onRefresh: _loadTransitaires,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: _transitaires.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final u = _transitaires[index];
                      return TransitaireListCard(
                        user: u,
                        l10n: l10n,
                        onTap: () => _openProfile(u),
                      );
                    },
                  ),
                ),
    );
  }
}
