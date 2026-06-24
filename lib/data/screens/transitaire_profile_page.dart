import 'package:flutter/material.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';

/// Profil public transitaire — visible par les acheteurs depuis cars_info.
class TransitaireProfilePage extends StatelessWidget {
  final Map<String, dynamic> transitaire;
  final bool isOwner;
  final String? articleId;
  final VoidCallback? onTransitaireSelected;
  final Future<bool> Function()? beforeSelectTransitaire;

  const TransitaireProfilePage({
    super.key,
    required this.transitaire,
    this.isOwner = false,
    this.articleId,
    this.onTransitaireSelected,
    this.beforeSelectTransitaire,
  });

  Future<void> _handleSelect(BuildContext context) async {
    if (beforeSelectTransitaire != null) {
      final ok = await beforeSelectTransitaire!();
      if (!ok) return;
    }
    onTransitaireSelected?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          TransitaireProfileHelpers.displayName(transitaire),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
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
        isOwner: isOwner,
        articleId: articleId,
        onTransitaireSelected:
            onTransitaireSelected == null ? null : () => _handleSelect(context),
      ),
    );
  }
}
