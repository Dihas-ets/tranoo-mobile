import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/widgets/transitaire_gallery_section.dart';
import 'package:tranoo/widgets/transitaire_public_ui.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kTransitaireNavy = Color(0xFF1B2B4B);
const Color kTransitaireAmber = Color(0xFFF8BF13);

BoxDecoration transitairePremiumRingDecoration({double borderWidth = 1}) {
  return BoxDecoration(
    shape: BoxShape.circle,
    color: kTransitaireAmber.withOpacity(0.22),
    border: Border.all(
      color: kTransitaireAmber.withOpacity(0.55),
      width: borderWidth,
    ),
  );
}

class TransitaireStarRating extends StatelessWidget {
  final double rating;
  final bool compact;

  const TransitaireStarRating({
    super.key,
    required this.rating,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: kTransitaireAmber.withOpacity(compact ? 0.35 : 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kTransitaireAmber.withOpacity(0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: compact ? kTransitaireNavy : kTransitaireAmber,
            size: compact ? 14 : 17,
          ),
          SizedBox(width: compact ? 2 : 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.bold,
              color: kTransitaireNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class TransitaireProfileHelpers {
  static String displayName(
    Map<String, dynamic> user, {
    AppLocalizations? l10n,
  }) {
    final entreprise = (user['entreprise'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) return entreprise;
    final nom = (user['nom'] ?? '').toString().trim();
    final prenoms = (user['prenoms'] ?? '').toString().trim();
    final full = '$prenoms $nom'.trim();
    return full.isNotEmpty
        ? full
        : (l10n?.transitaireDefaultName ?? 'Transitaire');
  }

  static String subtitle(
    Map<String, dynamic> user, {
    AppLocalizations? l10n,
  }) {
    final entreprise = (user['entreprise'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) {
      return l10n?.transitaireBadgeLabel ?? 'Transitaire';
    }
    return l10n?.transitaireServicesSubtitle ??
        'Services de transit international';
  }

  static String locationLine(
    Map<String, dynamic> user, {
    AppLocalizations? l10n,
  }) {
    final ville = (user['ville'] ?? '').toString().trim();
    final pays = (user['pays'] ?? '').toString().trim();
    if (ville.isNotEmpty && pays.isNotEmpty) return '$ville, $pays';
    if (pays.isNotEmpty) return pays;
    if (ville.isNotEmpty) return ville;
    return l10n?.westAfricaDefault ?? 'Afrique de l\'Ouest';
  }

  static String? photoUrl(Map<String, dynamic> user) {
    final photo = (user['photo'] ?? '').toString().trim();
    return photo.isNotEmpty ? photo : null;
  }

  static String initials(Map<String, dynamic> user) {
    final name = displayName(user);
    return name.isNotEmpty ? name[0].toUpperCase() : 'T';
  }
}

/// Bord supérieur convexe du panneau blanc (forme ∩).
class _ConvexTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width / 2, -6, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class TransitaireProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double radius;
  final bool premium;

  const TransitaireProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.radius = 50,
    this.premium = false,
  });

  @override
  Widget build(BuildContext context) {
    final inner = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8EDF5),
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.72,
                fontWeight: FontWeight.bold,
                color: kTransitaireNavy,
              ),
            )
          : null,
    );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: premium
            ? Border.all(color: kTransitaireAmber.withOpacity(0.7), width: 2.5)
            : null,
      ),
      child: inner,
    );
  }
}

class TransitaireProfileView extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isOwner;
  final VoidCallback? onEditProfile;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenLanguage;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;
  final Widget? settingsExtra;

  const TransitaireProfileView({
    super.key,
    required this.user,
    this.isOwner = false,
    this.onEditProfile,
    this.onOpenHistory,
    this.onOpenSubscription,
    this.onOpenNotifications,
    this.onOpenLanguage,
    this.onLogout,
    this.onDeleteAccount,
    this.settingsExtra,
  });

  @override
  State<TransitaireProfileView> createState() => _TransitaireProfileViewState();
}

class _TransitaireProfileViewState extends State<TransitaireProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _contactTransitaire(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final tel = (widget.user['telephone'] ?? '').toString().trim();
    if (tel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactPhoneUnavailable)),
      );
      return;
    }
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  double _displayRating() {
    final id = (widget.user['_id'] ?? widget.user['uid'] ?? '').toString();
    if (id.isEmpty) return 4.5;
    final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return 4.0 + (hash % 10) / 10;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = widget.user;
    final name = TransitaireProfileHelpers.displayName(user, l10n: l10n);
    final photo = TransitaireProfileHelpers.photoUrl(user);
    final initials = TransitaireProfileHelpers.initials(user);
    final location = TransitaireProfileHelpers.locationLine(user, l10n: l10n);
    final subtitle = TransitaireProfileHelpers.subtitle(user, l10n: l10n);
    final subscribed = TransitairePublicUi.isSubscribed(user);
    final galleryItems = parseTransitaireGallery(user['transitaireGallery']);

    return Column(
      children: [
        _ProfileCoverHeader(
          photoUrl: photo,
          initials: initials,
          name: name,
          subtitle: subtitle,
          location: location,
          premium: subscribed,
          showRating: !widget.isOwner && subscribed,
          rating: _displayRating(),
          premiumLabel: l10n.forwarderPremiumBadge,
        ),
        _ProfileTabBar(controller: _tabController, l10n: l10n),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DetailsTab(
                user: user,
                isOwner: widget.isOwner,
                l10n: l10n,
                onContact: () => _contactTransitaire(context),
                onEditProfile: widget.onEditProfile,
                onOpenHistory: widget.onOpenHistory,
                onOpenSubscription: widget.onOpenSubscription,
                onOpenNotifications: widget.onOpenNotifications,
                onOpenLanguage: widget.onOpenLanguage,
                onLogout: widget.onLogout,
                onDeleteAccount: widget.onDeleteAccount,
                settingsExtra: widget.settingsExtra,
              ),
              TransitaireGalleryGrid(
                items: galleryItems,
                user: user,
                emptyMessage: l10n.transitaireGalleryEmpty,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCoverHeader extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final String name;
  final String subtitle;
  final String location;
  final bool premium;
  final bool showRating;
  final double rating;
  final String premiumLabel;

  const _ProfileCoverHeader({
    required this.photoUrl,
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.location,
    required this.premium,
    required this.showRating,
    required this.rating,
    required this.premiumLabel,
  });

  Widget _coverBackground() {
    if (photoUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(photoUrl!, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A3F6B), kTransitaireNavy],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: _coverBackground(),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: ClipPath(
                clipper: _ConvexTopClipper(),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 88, 20, 10),
                  child: Column(
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: kTransitaireNavy,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.place_outlined,
                              size: 15, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (showRating) ...[
                        const SizedBox(height: 10),
                        TransitaireStarRating(rating: rating),
                        const SizedBox(height: 4),
                        Text(
                          premiumLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kTransitaireNavy.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 66,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => showTransitairePhotoZoom(
                context,
                photoUrl: photoUrl,
                initials: initials,
              ),
              child: TransitaireProfileAvatar(
                photoUrl: photoUrl,
                initials: initials,
                premium: premium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  final TabController controller;
  final AppLocalizations l10n;

  const _ProfileTabBar({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: controller,
        indicatorColor: kTransitaireAmber,
        indicatorWeight: 3,
        labelColor: kTransitaireNavy,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: [
          Tab(text: l10n.details),
          Tab(text: l10n.transitaireProfileTabGallery),
        ],
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isOwner;
  final AppLocalizations l10n;
  final VoidCallback onContact;
  final VoidCallback? onEditProfile;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenLanguage;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;
  final Widget? settingsExtra;

  const _DetailsTab({
    required this.user,
    required this.isOwner,
    required this.l10n,
    required this.onContact,
    this.onEditProfile,
    this.onOpenHistory,
    this.onOpenSubscription,
    this.onOpenNotifications,
    this.onOpenLanguage,
    this.onLogout,
    this.onDeleteAccount,
    this.settingsExtra,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        32 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        if (isOwner) ...[
          Row(
            children: [
              Expanded(
                child: _PrimaryOutlineButton(
                  label: l10n.editProfile,
                  onPressed: onEditProfile,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrimaryFilledButton(
                  label: l10n.transitHistory,
                  onPressed: onOpenHistory,
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onContact,
              icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
              label: Text(l10n.contactTransitaire),
              style: ElevatedButton.styleFrom(
                backgroundColor: kTransitaireAmber,
                foregroundColor: kTransitaireNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _InfoSection(user: user, l10n: l10n),
        if (isOwner) ...[
          const SizedBox(height: 20),
          _SettingsGroup(
            title: l10n.account,
            items: [
              _SettingsItem(
                icon: Icons.person_outline,
                label: l10n.editProfile,
                onTap: onEditProfile,
              ),
              _SettingsItem(
                icon: Icons.card_membership_outlined,
                label: l10n.forwarderSubscription,
                onTap: onOpenSubscription,
              ),
              _SettingsItem(
                icon: Icons.history,
                label: l10n.transitHistoryTitle,
                onTap: onOpenHistory,
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: l10n.notifications,
                onTap: onOpenNotifications,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            title: l10n.preferences,
            items: [
              _SettingsItem(
                icon: Icons.language,
                label: l10n.language,
                onTap: onOpenLanguage,
              ),
            ],
          ),
          if (settingsExtra != null) ...[
            const SizedBox(height: 12),
            settingsExtra!,
          ],
          const SizedBox(height: 12),
          _SettingsGroup(
            title: l10n.actions,
            items: [
              _SettingsItem(
                icon: Icons.logout,
                label: l10n.logout,
                onTap: onLogout,
                color: kTransitaireNavy,
              ),
              _SettingsItem(
                icon: Icons.delete_forever_outlined,
                label: l10n.deleteAccount,
                onTap: onDeleteAccount,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PrimaryFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryFilledButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kTransitaireAmber,
        foregroundColor: kTransitaireNavy,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _PrimaryOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryOutlineButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: kTransitaireNavy,
        side: BorderSide(color: kTransitaireAmber.withOpacity(0.9), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Map<String, dynamic> user;
  final AppLocalizations l10n;

  const _InfoSection({required this.user, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[];
    final tel = (user['telephone'] ?? '').toString().trim();
    final email = (user['email'] ?? '').toString().trim();
    final entreprise = (user['entreprise'] ?? '').toString().trim();
    final description =
        (user['transitaireDescription'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) {
      rows.add(MapEntry(l10n.company, entreprise));
    }
    if (tel.isNotEmpty) rows.add(MapEntry(l10n.phone, tel));
    if (email.isNotEmpty) rows.add(MapEntry(l10n.email, email));
    if (description.isNotEmpty) {
      rows.add(MapEntry(l10n.description, description));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stepInfo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kTransitaireNavy,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? kTransitaireNavy, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}

InputDecoration transitaireFieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF5F6F8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kTransitaireNavy, width: 1.2),
    ),
  );
}
