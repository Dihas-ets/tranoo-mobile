import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kTransitaireNavy = Color(0xFF1B2B4B);
const Color kTransitaireAmber = Color(0xFFF8BF13);

/// Style services rapides : cercle / fond jaune Tranoo transparent.
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

/// Note étoile — réservée aux transitaires premium.
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
  static String displayName(Map<String, dynamic> user) {
    final entreprise = (user['entreprise'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) return entreprise;
    final nom = (user['nom'] ?? '').toString().trim();
    final prenoms = (user['prenoms'] ?? '').toString().trim();
    final full = '$prenoms $nom'.trim();
    return full.isNotEmpty ? full : 'Transitaire';
  }

  static String subtitle(Map<String, dynamic> user) {
    final entreprise = (user['entreprise'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) return 'Transitaire';
    return 'Services de transit international';
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
}

class TransitaireProfileView extends StatelessWidget {
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

  Future<void> _contactTransitaire(BuildContext context) async {
    final tel = (user['telephone'] ?? '').toString().trim();
    if (tel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de contact indisponible.')),
      );
      return;
    }
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  double _displayRating() {
    final id = (user['_id'] ?? user['uid'] ?? '').toString();
    if (id.isEmpty) return 4.5;
    final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return 4.0 + (hash % 10) / 10;
  }

  @override
  Widget build(BuildContext context) {
    final name = TransitaireProfileHelpers.displayName(user);
    final photo = TransitaireProfileHelpers.photoUrl(user);
    final location = TransitaireProfileHelpers.locationLine(user);
    final subtitle = TransitaireProfileHelpers.subtitle(user);
    final subscribed = user['hasSubscription'] == true ||
        user['subscriptionStatus'] == 'active';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3E6B), kTransitaireNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -48,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFE8F1FF),
                        backgroundImage:
                            photo != null ? NetworkImage(photo) : null,
                        child: photo == null
                            ? Text(
                                TransitaireProfileHelpers.initials(user),
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: kTransitaireNavy,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 58, 20, 0),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kTransitaireNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey.shade600),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (!isOwner && subscribed)
                      Expanded(
                        child: Center(
                          child: TransitaireStarRating(
                            rating: _displayRating(),
                          ),
                        ),
                      )
                    else
                      _StatItem(
                        value: '—',
                        label: isOwner ? 'Livraisons' : 'Note',
                      ),
                    _StatItem(
                      value: isOwner ? '—' : '—',
                      label: 'En transit',
                    ),
                    _StatItem(
                      value: subscribed ? 'Actif' : '—',
                      label: 'Abonnement',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (isOwner) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _PrimaryOutlineButton(
                          label: 'Modifier le profil',
                          onPressed: onEditProfile,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PrimaryFilledButton(
                          label: 'Historique',
                          onPressed: onOpenHistory,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: _PrimaryFilledButton(
                      label: 'Contacter',
                      onPressed: () => _contactTransitaire(context),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _InfoSection(user: user),
                if (isOwner) ...[
                  const SizedBox(height: 20),
                  _SettingsGroup(
                    title: 'Compte',
                    items: [
                      _SettingsItem(
                        icon: Icons.person_outline,
                        label: 'Modifier le profil',
                        onTap: onEditProfile,
                      ),
                      _SettingsItem(
                        icon: Icons.card_membership_outlined,
                        label: 'Abonnement',
                        onTap: onOpenSubscription,
                      ),
                      _SettingsItem(
                        icon: Icons.history,
                        label: 'Historique des transits',
                        onTap: onOpenHistory,
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: onOpenNotifications,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SettingsGroup(
                    title: 'Préférences',
                    items: [
                      _SettingsItem(
                        icon: Icons.language,
                        label: 'Langue',
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
                    title: 'Actions',
                    items: [
                      _SettingsItem(
                        icon: Icons.logout,
                        label: 'Déconnexion',
                        onTap: onLogout,
                        color: kTransitaireNavy,
                      ),
                      _SettingsItem(
                        icon: Icons.delete_forever_outlined,
                        label: 'Supprimer le compte',
                        onTap: onDeleteAccount,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTransitaireNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
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
        backgroundColor: kTransitaireNavy,
        foregroundColor: Colors.white,
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
        side: const BorderSide(color: kTransitaireNavy),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Map<String, dynamic> user;

  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[];
    final tel = (user['telephone'] ?? '').toString().trim();
    final email = (user['email'] ?? '').toString().trim();
    final entreprise = (user['entreprise'] ?? '').toString().trim();
    if (entreprise.isNotEmpty) {
      rows.add(MapEntry('Entreprise', entreprise));
    }
    if (tel.isNotEmpty) rows.add(MapEntry('Téléphone', tel));
    if (email.isNotEmpty) rows.add(MapEntry('E-mail', email));

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
          const Text(
            'Informations',
            style: TextStyle(
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
