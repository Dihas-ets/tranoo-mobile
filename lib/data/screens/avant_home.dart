import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cart_service.dart';
import '../../providers/counter_provider.dart';
import '../../config/backend_config.dart';
import 'marque.dart';
import 'voitures.dart';
import 'piece.dart';
import 'profil3.dart';
import 'profilutilisateurpage.dart';
import 'profil_utilisateur2.dart';
import 'cart_page.dart';
import 'notifications.dart';
import 'connexion_page.dart';
import 'mesfactures.dart';
import 'second_page.dart';
import '../../providers/auth_provider.dart' as myauth;
import '../../services/notification_service.dart';
import '../../utils/page_refresh_registry.dart';
import '../../main.dart' show rootNavigatorKey;
import '../../widgets/alert_incoming_call_overlay.dart';
import '../../widgets/alert_display_permission_dialog.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'create_sell.dart';
import 'create_sell2.dart';

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome>
    with WidgetsBindingObserver, RegisterPageRefresh {
  @override
  Future<void> onPagePullRefresh() async => _runLightRefresh(force: true);
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didCheckOnboarding = false;
  int _invoiceUnreadCount = 0;
  bool _didShowSellerAlertPopup = false;
  Timer? _lightRefreshTimer;
  DateTime? _lastLightRefreshAt;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlertIncomingCallService.tryShowFromAppLaunchOnly(
        navigatorKey: rootNavigatorKey,
      );
      AlertDisplayPermissionDialog.showIfNeeded(context);
    });
    _checkOnboardingAndInactivity();
    _updateLastLoginTime();
    _runLightRefresh(force: true);
    _lightRefreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (_) => _runLightRefresh(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lightRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AlertDisplayPermissionDialog.showIfNeeded(context);
      _runLightRefresh(force: true);
    }
  }

  Future<void> _runLightRefresh({bool force = false}) async {
    if (!mounted) return;
    final now = DateTime.now();
    if (!force &&
        _lastLightRefreshAt != null &&
        now.difference(_lastLightRefreshAt!) < const Duration(seconds: 45)) {
      return;
    }
    _lastLightRefreshAt = now;
    await _loadUnreadInvoicesCount();
    if (!mounted) return;
    await Provider.of<CounterProvider>(context, listen: false).loadCounters();
  }

  Future<void> _loadUnreadInvoicesCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      final resp = await Dio().get(
        '${getApiBaseUrl()}/invoices/my',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = resp.data;
      final count = (data is Map<String, dynamic>)
          ? ((data['unreadCount'] as num?)?.toInt() ?? 0)
          : 0;
      if (!mounted) return;
      setState(() {
        _invoiceUnreadCount = count;
      });
    } catch (_) {}
  }

  Future<void> _checkOnboardingAndInactivity() async {
    if (_didCheckOnboarding) return;
    _didCheckOnboarding = true;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SecondPage()),
          (route) => false,
        );
      });
      return;
    }
  }

  Future<void> _updateLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _profilePageForUser(Map<String, dynamic>? user) {
    final role = (user?['role'] ?? user?['typeUtilisateur'] ?? user?['type'])
        ?.toString()
        .toLowerCase();
    if (role == 'vendeur') return const ProfilUtilisateurPage();
    if (role == 'transitaire') return const ProfilUtilisateur2();
    return const Profil3();
  }

  List<Widget> _pagesForUser(Map<String, dynamic>? user) {
    return [
      const Marque(),
      const VoituresPage(),
      PiecePage(),
      _profilePageForUser(user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = Provider.of<myauth.AuthProvider>(context).user;
    final pages = _pagesForUser(user);
    final role = (user?['role'] ?? user?['typeUtilisateur'] ?? user?['type'])
        ?.toString()
        .toLowerCase();

    if (!_didShowSellerAlertPopup && role == 'vendeur') {
      _didShowSellerAlertPopup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _maybeShowSellerAlertPopup();
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: Center(
            child: Image.asset(
              'assets/images/logo_connexion.png',
              height: 32,
              fit: BoxFit.contain,
              // Aucun texte de fallback pour éviter d'afficher "Tranoo"
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.receipt_long_outlined, color: Colors.black),
                if (_invoiceUnreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _invoiceUnreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MesFacturesPage()),
              );
              await _loadUnreadInvoicesCount();
            },
          ),
          Consumer<CartService>(
            builder: (context, cart, child) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        color: Colors.black),
                    if (cart.totalQuantity > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cart.totalQuantity.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
              );
            },
          ),
          Consumer<CounterProvider>(
            builder: (context, counter, child) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none_outlined,
                        color: Colors.black),
                    if (counter.unreadNotificationsCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            counter.unreadNotificationsCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Notifications(),
                      ),
                    );
                    if (!context.mounted) return;
                    await Provider.of<CounterProvider>(
                      context,
                      listen: false,
                    ).loadCounters();
                  }();
                },
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: pages[_selectedIndex],
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0XffF8BF13),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: user != null
                        ? const Icon(Icons.person, size: 40)
                        : const Icon(Icons.person_outline, size: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user != null
                        ? (user['nom'] ?? l10n.user)
                        : l10n.userNotConnected,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user != null) ...[
                    Text(
                      user['email'] ?? "",
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: Text(l10n.home),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AvantHome()),
                      );
                    },
                  ),
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        l10n.account,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.profile),
                    onTap: () {
                      Navigator.pop(context);
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseSignIn)),
                        );
                        return;
                      }
                      final Widget page = _profilePageForUser(user);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => page),
                      );
                    },
                  ),
                  if (user != null)
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.logout),
                      onTap: () async {
                        Navigator.pop(context);
                        await Provider.of<myauth.AuthProvider>(context,
                                listen: false)
                            .logout();
                      },
                    ),
                  if (user == null)
                    ListTile(
                      leading: const Icon(Icons.login),
                      title: Text(l10n.login),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ConnexionPage()),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF9FAFB),
        selectedItemColor: const Color(0xFFF8BF13),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car), label: l10n.cars),
          BottomNavigationBarItem(icon: const Icon(Icons.build), label: l10n.pieces),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.profile),
        ],
      ),
    );
  }

  Future<void> _maybeShowSellerAlertPopup() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      final data = await _notificationService.getUserNotifications(
        page: 1,
        limit: 10,
        unreadOnly: true,
      );
      final notifsRaw = data['notifications'];
      if (notifsRaw is! List) return;

      final unreadAlerts = notifsRaw
          .whereType<Map>()
          .where((n) => (n['type']?.toString() ?? '') == 'alerte')
          .toList();
      if (unreadAlerts.isEmpty) return;

      final notif = Map<String, dynamic>.from(unreadAlerts.first);
      final id = (notif['_id'] ?? '').toString();
      final title = (notif['title'] ?? l10n.newAlertDefault).toString();
      final dataMap = (notif['data'] is Map)
          ? Map<String, dynamic>.from(notif['data'])
          : {};
      final requestType = (dataMap['requestType'] ?? '').toString();
      final isPieceAlert = requestType == 'piece_search';

      final List<String> details = [
        if ((dataMap['marque'] ?? '').toString().isNotEmpty)
          l10n.alertLabelBrand(dataMap['marque'].toString()),
        if ((dataMap['modele'] ?? '').toString().isNotEmpty)
          l10n.alertLabelModel(dataMap['modele'].toString()),
        if ((dataMap['etat'] ?? '').toString().isNotEmpty && !isPieceAlert)
          l10n.alertLabelCondition(dataMap['etat'].toString()),
        if ((dataMap['annee'] ?? '').toString().isNotEmpty && isPieceAlert)
          l10n.alertLabelYear(dataMap['annee'].toString()),
        if ((dataMap['anneeMin'] ?? '').toString().isNotEmpty && !isPieceAlert)
          l10n.alertLabelYearMin(dataMap['anneeMin'].toString()),
        if ((dataMap['anneeMax'] ?? '').toString().isNotEmpty && !isPieceAlert)
          l10n.alertLabelYearMax(dataMap['anneeMax'].toString()),
        if ((dataMap['budgetMax'] ?? '').toString().isNotEmpty)
          l10n.alertLabelBudgetMax(dataMap['budgetMax'].toString()),
        if ((dataMap['pieceName'] ?? '').toString().isNotEmpty)
          l10n.alertLabelPart(dataMap['pieceName'].toString()),
        if ((dataMap['urgence'] ?? '').toString().isNotEmpty)
          l10n.alertLabelUrgency(dataMap['urgence'].toString()),
        if ((dataMap['localisation'] ?? '').toString().isNotEmpty)
          l10n.alertLabelLocation(dataMap['localisation'].toString()),
        if ((dataMap['description'] ?? '').toString().isNotEmpty)
          l10n.alertLabelDetails(dataMap['description'].toString()),
      ];

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          color: Color(0xFFB45309)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.close,
                        onPressed: () async {
                          if (id.isNotEmpty) {
                            await _notificationService.markAsRead(id);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPieceAlert
                              ? l10n.buyerSearchingPart
                              : l10n.buyerSearchingVehicle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.characteristics,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (details.isEmpty)
                          Text(
                            l10n.noCharacteristicsProvided,
                            style: const TextStyle(fontSize: 13),
                          )
                        else
                          ...details.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text('• $item',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BF13),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (id.isNotEmpty) {
                        await _notificationService.markAsRead(id);
                      }
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      if (isPieceAlert) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateSellPage2()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateSellPage()),
                        );
                      }
                    },
                    child: Text(l10n.proposeOffer),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (_) {
      // Silencieux: on ne bloque pas l'appbar si erreur réseau.
    }
  }
}
