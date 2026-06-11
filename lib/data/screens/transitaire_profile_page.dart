import 'package:flutter/material.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';

/// Profil public transitaire — visible par les acheteurs depuis cars_info.
class TransitaireProfilePage extends StatelessWidget {
  final Map<String, dynamic> transitaire;

  const TransitaireProfilePage({super.key, required this.transitaire});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          TransitaireProfileHelpers.displayName(transitaire),
          style: const TextStyle(
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
      body: TransitaireProfileView(
        user: transitaire,
        isOwner: false,
      ),
    );
  }
}
