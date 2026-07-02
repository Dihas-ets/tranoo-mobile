import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/alert_call_payload.dart';
import 'package:tranoo/services/urgent_fcm_utils.dart';
import 'package:tranoo/services/notification_ringtone_player.dart';
import 'package:tranoo/services/alert_pending_store.dart';
import 'package:tranoo/utils/local_notification_service.dart';
import 'package:tranoo/utils/locale_helper.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';

/// Écran plein écran pour proposition vendeur (acheteurs).
class AlertIncomingCallOverlay extends StatefulWidget {
  final AlertCallPayload payload;

  const AlertIncomingCallOverlay({super.key, required this.payload});

  @override
  State<AlertIncomingCallOverlay> createState() => _AlertIncomingCallOverlayState();
}

class _AlertIncomingCallOverlayState extends State<AlertIncomingCallOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _ringController;
  double _rejectDrag = 0;
  double _acceptDrag = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    HapticFeedback.mediumImpact();
    NotificationRingtonePlayer.playAlertLoop();
  }

  @override
  void dispose() {
    NotificationRingtonePlayer.stop();
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  static String? _dataStr(Map<String, String> data, String key) {
    final v = data[key];
    if (v == null) return null;
    final s = v.trim();
    return s.isEmpty ? null : s;
  }

  static String? _thumbnailUrl(Map<String, String> data) {
    final thumb = _dataStr(data, 'thumbnailUrl');
    if (thumb != null) return thumb;
    final photosRaw = data['photos'];
    if (photosRaw == null) return null;
    try {
      if (photosRaw.startsWith('[') && photosRaw.length > 2) {
        final inner = photosRaw.substring(1, photosRaw.length - 1);
        final first = inner.split(',').first.replaceAll('"', '').trim();
        if (first.isNotEmpty) return first;
      }
    } catch (_) {}
    return null;
  }

  List<String> _detailChips(Map<String, String> data) {
    final chips = <String>[];
    final marque = _dataStr(data, 'marque');
    final modele = _dataStr(data, 'modele');
    final piece = _dataStr(data, 'pieceName');
    if (marque != null) chips.add(marque);
    if (modele != null) chips.add(modele);
    if (piece != null) chips.add(piece);
    return chips;
  }

  void _reject() async {
    await AlertPendingStore.clear();
    if (mounted) Navigator.of(context).pop();
  }

  void _accept() {
    final notificationId = _dataStr(widget.payload.data, 'notificationId');
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const Notifications(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.payload.data;
    final title = widget.payload.title;
    final body = widget.payload.body;
    final thumb = _thumbnailUrl(data);
    final chips = _detailChips(data);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final t = _pulseController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.35),
                    radius: 1.1 + t * 0.15,
                    colors: [
                      Color.lerp(
                        const Color(0xFF2D2D2D),
                        const Color(0xFF1A1A1A),
                        t,
                      )!,
                      const Color(0xFF0A0A0A),
                    ],
                  ),
                ),
              );
            },
          ),
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _ringController,
              builder: (context, _) {
                final progress =
                    ((_ringController.value + i * 0.33) % 1.0);
                final scale = 0.55 + progress * 0.9;
                final opacity = (1 - progress) * 0.35;
                return Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: opacity),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_active,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        l10n.buyerAlert,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                _AvatarRing(imageUrl: thumb),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    body,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: chips
                        .map(
                          (c) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              c,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const Spacer(),
                Text(
                  l10n.swipeUpOrTap,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SwipeCallButton(
                        icon: Icons.call_end,
                        label: l10n.decline,
                        color: const Color(0xFFE53935),
                        dragOffset: _rejectDrag,
                        onDragUpdate: (d) =>
                            setState(() => _rejectDrag = d),
                        onTriggered: _reject,
                      ),
                      _SwipeCallButton(
                        icon: Icons.call,
                        label: l10n.answer,
                        color: const Color(0xFF43A047),
                        dragOffset: _acceptDrag,
                        onDragUpdate: (d) =>
                            setState(() => _acceptDrag = d),
                        onTriggered: _accept,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  final String? imageUrl;

  const _AvatarRing({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? TranooNetworkImage(
                  url: imageUrl!,
                  fit: BoxFit.cover,
                  cloudinaryWidthPx: cloudinaryWidthPx(context, logicalWidth: 148),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_car_rounded,
        color: Colors.white,
        size: 56,
      ),
    );
  }
}

class _SwipeCallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double dragOffset;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onTriggered;

  const _SwipeCallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.dragOffset,
    required this.onDragUpdate,
    required this.onTriggered,
  });

  static const double _triggerThreshold = 72;

  @override
  Widget build(BuildContext context) {
    final lift = dragOffset.clamp(-120.0, 0.0);
    final progress =
        (-lift / _triggerThreshold).clamp(0.0, 1.0);

    return Column(
      children: [
        GestureDetector(
          onTap: onTriggered,
          onVerticalDragUpdate: (details) {
            onDragUpdate(
              (dragOffset + details.delta.dy).clamp(-120.0, 0.0),
            );
          },
          onVerticalDragEnd: (details) {
            if (dragOffset <= -_triggerThreshold ||
                details.velocity.pixelsPerSecond.dy < -600) {
              onTriggered();
            } else {
              onDragUpdate(0);
            }
          },
          child: Transform.translate(
            offset: Offset(0, lift),
            child: Column(
              children: [
                if (progress > 0.05)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white.withValues(alpha: 0.5 + progress * 0.5),
                      size: 20 + progress * 8,
                    ),
                  ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 16 + progress * 12,
                        spreadRadius: progress * 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 34),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Affiche l'overlay d'appel pour les notifications d'alerte.
class AlertIncomingCallService {
  static bool _showing = false;
  static bool _appLaunchChecked = false;
  static final Set<String> _handledNotificationIds = {};

  static bool isAlertMessage(RemoteMessage message) =>
      isUrgentFcmMessage(message);

  static String? _notificationIdFromData(Map<String, String> data) {
    final id = (data['notificationId'] ?? '').trim();
    return id.isEmpty ? null : id;
  }

  static bool _alreadyHandled(Map<String, String> data) {
    final id = _notificationIdFromData(data);
    return id != null && _handledNotificationIds.contains(id);
  }

  static void _markHandled(Map<String, String> data) {
    final id = _notificationIdFromData(data);
    if (id != null) _handledNotificationIds.add(id);
  }

  static Future<void> show(
    RemoteMessage message, {
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    final locale = await LocaleHelper.storedLanguageCode();
    await showPayload(
      AlertCallPayload.fromRemoteMessage(message, locale: locale),
      navigatorKey: navigatorKey,
    );
  }

  static Future<void> showPayload(
    AlertCallPayload payload, {
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_alreadyHandled(payload.data)) return;
    if (_showing) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    _markHandled(payload.data);
    await AlertPendingStore.clear();
    _showing = true;
    try {
      await Navigator.of(ctx, rootNavigator: true).push(
        PageRouteBuilder(
          opaque: true,
          fullscreenDialog: true,
          pageBuilder: (_, __, ___) =>
              AlertIncomingCallOverlay(payload: payload),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      );
    } finally {
      _showing = false;
    }
  }

  /// Uniquement si l'app s'ouvre via la notif plein écran (pas au simple retour sur l'app).
  static Future<void> tryShowFromAppLaunchOnly({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_appLaunchChecked || _showing) return;
    _appLaunchChecked = true;

    final launchData = await LocalNotificationService.getAlertLaunchData();
    if (launchData == null || launchData.isEmpty) return;
    if (_alreadyHandled(launchData)) return;

    final ctx = navigatorKey.currentContext;
    final l10n = ctx != null ? AppLocalizations.of(ctx) : null;

    await showPayload(
      AlertCallPayload(
        title: launchData['title'] ?? l10n?.newAlertTitle ?? 'Nouvelle alerte',
        body: launchData['message'] ??
            l10n?.sellerRespondedToAlert ??
            'Un vendeur a répondu à votre alerte',
        data: launchData,
      ),
      navigatorKey: navigatorKey,
    );
  }
}
