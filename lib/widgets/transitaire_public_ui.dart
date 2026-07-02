import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/tranoo_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';

export 'transitaire_profile_ui.dart'
    show kTransitaireAmber, kTransitaireNavy, TransitaireStarRating;

import 'transitaire_profile_ui.dart' show kTransitaireAmber, kTransitaireNavy;

/// Helpers + cartes pub transitaires (acheteurs).
class TransitairePublicUi {
  static bool isSubscribed(Map<String, dynamic> u) =>
      u['hasSubscription'] == true || u['subscriptionStatus'] == 'active';

  static double displayRating(Map<String, dynamic> u) {
    final avg = (u['ratingAverage'] as num?)?.toDouble() ?? 0;
    if (avg > 0) return avg;
    return 0;
  }

  static bool hasRating(Map<String, dynamic> u) => true;

  static String displayName(Map<String, dynamic> user) {
    final entreprise = (user['entreprise'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) return entreprise;
    final nom = (user['nom'] ?? '').toString().trim();
    final prenoms = (user['prenoms'] ?? '').toString().trim();
    final full = '$prenoms $nom'.trim();
    return full.isNotEmpty ? full : 'Transitaire';
  }

  static String locationLine(Map<String, dynamic> user) {
    final ville = (user['ville'] ?? '').toString().trim();
    final pays = (user['pays'] ?? '').toString().trim();
    if (ville.isNotEmpty && pays.isNotEmpty) return '$ville, $pays';
    if (pays.isNotEmpty) return pays;
    if (ville.isNotEmpty) return ville;
    return 'Afrique de l\'Ouest';
  }

  static String? photoUrl(Map<String, dynamic> user) {
    final photo = (user['photo'] ?? '').toString().trim();
    return photo.isNotEmpty ? photo : null;
  }

  static String initials(Map<String, dynamic> user) {
    final name = displayName(user);
    return name.isNotEmpty ? name[0].toUpperCase() : 'T';
  }

  static int galleryCount(Map<String, dynamic> user) {
    final raw = user['transitaireGallery'];
    if (raw is! List) return 0;
    return raw.length;
  }

  static String? description(Map<String, dynamic> user) {
    final d = (user['transitaireDescription'] ?? '').toString().trim();
    return d.isNotEmpty ? d : null;
  }

  static String listMetaLine(AppLocalizations l10n, Map<String, dynamic> user) {
    final base =
        '${l10n.internationalTransit} • ${l10n.forwarderStandardBadge}';
    final desc = description(user);
    if (desc == null) return base;
    return '$base • $desc';
  }

  static Future<void> callTransitaire(
    BuildContext context,
    Map<String, dynamic> user,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final tel = (user['telephone'] ?? '').toString().trim();
    if (tel.isEmpty) {
      showTranooToast(context, message: l10n.contactPhoneUnavailable, isError: true);
      return;
    }
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

void showTransitairePhotoZoom(
  BuildContext context, {
  required String? photoUrl,
  required String initials,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: Colors.black.withOpacity(0.88),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, __) {
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: InteractiveViewer(
                  minScale: 0.6,
                  maxScale: 5,
                  child: photoUrl != null
                      ? TranooNetworkImage(
                          url: photoUrl,
                          fit: BoxFit.contain,
                          cloudinaryWidthPx: cloudinaryWidthPx(context),
                        )
                      : Container(
                          width: 220,
                          height: 220,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: kTransitaireAmber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: kTransitaireNavy,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Photo carrée cliquable (zoom) — style uniforme pour tous.
class TransitaireSquarePhoto extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double size;
  final bool zoomable;
  final VoidCallback? onTap;

  const TransitaireSquarePhoto({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.size = 84,
    this.zoomable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(14));
    final wrapped = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: size,
          height: size,
          color: const Color(0xFFECEFF1),
          child: photoUrl != null
              ? TranooNetworkImage(
                  url: photoUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  cloudinaryWidthPx: cloudinaryWidthPx(
                    context,
                    logicalWidth: size,
                  ),
                )
              : Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF546E7A),
                    ),
                  ),
                ),
        ),
      ),
    );

    if (!zoomable && onTap == null) return wrapped;

    return GestureDetector(
      onTap: onTap ??
          (zoomable
              ? () => showTransitairePhotoZoom(
                    context,
                    photoUrl: photoUrl,
                    initials: initials,
                  )
              : null),
      child: wrapped,
    );
  }
}

Widget _inlineStarRating(double rating, {bool numberFirst = false}) {
  final safeRating = rating.clamp(0, 5).toDouble();
  final value = Text(
    safeRating.toStringAsFixed(1),
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: kTransitaireNavy,
    ),
  );
  const star = Icon(Icons.star_rounded, color: kTransitaireAmber, size: 16);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: numberFirst
        ? [value, const SizedBox(width: 2), star]
        : [star, const SizedBox(width: 2), value],
  );
}

Widget _listMetaRow(AppLocalizations l10n, Map<String, dynamic> user) {
  final desc = TransitairePublicUi.description(user);
  final labelStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey.shade700,
    height: 1.35,
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.public_rounded,
            size: 15,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              l10n.internationalTransit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '•',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          Icon(
            Icons.local_shipping_outlined,
            size: 15,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              l10n.forwarderStandardBadge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
        ],
      ),
      if (desc != null) ...[
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.description_outlined,
                size: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

Widget _photoRatingBadge(double rating) {
  final safeRating = rating.clamp(0, 5).toDouble();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.58),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          safeRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.star_rounded, color: kTransitaireAmber, size: 13),
      ],
    ),
  );
}

/// Carte verticale — photo carrée, nom en dessous, étoiles pour tous.
class TransitaireSquareAvatarCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final double photoSize;
  final bool compact;

  const TransitaireSquareAvatarCard({
    super.key,
    required this.user,
    required this.l10n,
    required this.onTap,
    this.photoSize = 84,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = TransitairePublicUi.displayName(user);
    final photo = TransitairePublicUi.photoUrl(user);
    final initials = TransitairePublicUi.initials(user);
    final rating = TransitairePublicUi.displayRating(user);
    final showRating = TransitairePublicUi.hasRating(user);

    return SizedBox(
      width: photoSize + 14,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TransitaireSquarePhoto(
                      photoUrl: photo,
                      initials: initials,
                      size: photoSize,
                      onTap: () => showTransitairePhotoZoom(
                        context,
                        photoUrl: photo,
                        initials: initials,
                      ),
                    ),
                    if (compact && showRating)
                      Positioned(
                        right: -10,
                        bottom: 6,
                        child: _photoRatingBadge(rating),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: kTransitaireNavy,
                    height: 1.15,
                  ),
                ),
                if (!compact && showRating) ...[
                  const SizedBox(height: 4),
                  _inlineStarRating(rating, numberFirst: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte pub compacte — carousel accueil (alias avatar vertical).
class TransitairePubCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onOpenProfile;
  final AppLocalizations l10n;

  const TransitairePubCard({
    super.key,
    required this.user,
    required this.onOpenProfile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return TransitaireSquareAvatarCard(
      user: user,
      l10n: l10n,
      onTap: onOpenProfile,
      photoSize: 84,
    );
  }
}

/// Carte mise en avant — carousel horizontal liste (même style avatar).
class TransitaireFeaturedCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onOpenProfile;
  final AppLocalizations l10n;

  const TransitaireFeaturedCard({
    super.key,
    required this.user,
    required this.onOpenProfile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return TransitaireSquareAvatarCard(
      user: user,
      l10n: l10n,
      onTap: onOpenProfile,
      photoSize: 88,
    );
  }
}

/// Carte liste — style « My Booking » avec header, corps et actions.
class TransitaireListCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const TransitaireListCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final name = TransitairePublicUi.displayName(user);
    final photo = TransitairePublicUi.photoUrl(user);
    final initials = TransitairePublicUi.initials(user);
    final location = TransitairePublicUi.locationLine(user);
    final rating = TransitairePublicUi.displayRating(user);
    final showRating = TransitairePublicUi.hasRating(user);
    final galleryCount = TransitairePublicUi.galleryCount(user);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(
                  Icons.public_rounded,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.internationalTransit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransitaireSquarePhoto(
                  photoUrl: photo,
                  initials: initials,
                  size: 88,
                  onTap: () => showTransitairePhotoZoom(
                    context,
                    photoUrl: photo,
                    initials: initials,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: kTransitaireNavy,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (showRating) ...[
                            const SizedBox(width: 6),
                            _inlineStarRating(rating, numberFirst: true),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      _listMetaRow(l10n, user),
                      if (galleryCount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 15,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.galleryMediaCount(galleryCount),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        TransitairePublicUi.callTransitaire(context, user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTransitaireAmber,
                      foregroundColor: kTransitaireNavy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      l10n.callShort,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTransitaireNavy,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      l10n.viewProfile,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
