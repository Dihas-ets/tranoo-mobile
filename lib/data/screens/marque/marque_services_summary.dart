import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/data/screens/motos.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/utils/livro_integration.dart';

/// Grille d'accès rapide services (accueil acheteur).
class MarqueServicesSummarySection extends StatelessWidget {
  const MarqueServicesSummarySection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isPortrait,
  });

  final double screenWidth;
  final double screenHeight;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    final iconSize = screenWidth * (isPortrait ? 0.085 : 0.06);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8BF13).withOpacity(0.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF8BF13).withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ServiceIcon(
                    label: 'Véhicules',
                    icon: Icons.directions_car,
                    iconSize: iconSize,
                    imagePath: 'assets/images/icon_vente3.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoituresPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ServiceIcon(
                    label: 'Motos',
                    icon: Icons.motorcycle,
                    iconSize: iconSize,
                    imagePath: 'assets/images/motorbike.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MotosPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ServiceIcon(
                    label: 'Pièces',
                    icon: Icons.build_circle,
                    iconSize: iconSize,
                    imagePath: 'assets/images/icon_pieces2.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PiecePage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ServiceIcon(
                    label: 'Livraisons',
                    icon: Icons.local_shipping,
                    iconSize: iconSize,
                    imagePath: 'assets/images/icon_livraison3.png',
                    onTap: () {
                      final authUser = Provider.of<myauth.AuthProvider>(
                        context,
                        listen: false,
                      ).user;
                      LivroIntegration.bindCurrentUser(authUser);
                      LivroIntegration.openFromServices(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.onTap,
    this.imagePath,
  });

  final String label;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final double circleDiameter = iconSize * 1.9;
    final double innerIconSize = circleDiameter * 0.82;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleDiameter,
              height: circleDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8BF13).withOpacity(0.22),
                border: Border.all(
                  color: const Color(0xFFF8BF13).withOpacity(0.45),
                  width: 1,
                ),
              ),
              child: Center(
                child: imagePath != null
                    ? Image.asset(
                        imagePath!,
                        width: innerIconSize,
                        height: innerIconSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          icon,
                          size: innerIconSize,
                          color: const Color(0xFF0A1F44),
                        ),
                      )
                    : Icon(
                        icon,
                        size: innerIconSize,
                        color: const Color(0xFF0A1F44),
                      ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1F44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
