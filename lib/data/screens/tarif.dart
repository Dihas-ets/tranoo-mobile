import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tranoo/services/user_service.dart';
import 'subscription_payment.dart';

class Tarif extends StatefulWidget {
  const Tarif({super.key});

  @override
  State<Tarif> createState() => _TarifState();
}

class _TarifState extends State<Tarif> {
  bool loading = false;
  String? errorMsg;
  final UserService _userService = UserService();
  List<dynamic> _transitaires = [];
  bool _hasSubscription = false;
  DateTime? _activatedAt;
  DateTime? _expiresAt;
  double _prixMensuel =
      5000.0; // Prix par défaut, sera chargé depuis le backend

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });
    try {
      // Charger le prix de l'abonnement depuis le backend
      await _loadSubscriptionPricing();

      if (_userService.isAcheteur || _userService.isChauffeur) {
        await _loadTransitaires();
      } else if (_userService.isTransitaire) {
        await _loadSubscription();
      }
    } catch (e) {
      errorMsg = 'Impossible de charger les données';
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _loadTransitaires() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final dio = Dio(
      BaseOptions(
        baseUrl: UserService().dio.options.baseUrl,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    final resp = await dio.get(
      '/users',
      queryParameters: {'role': 'transitaire'},
    );
    _transitaires = resp.data is List ? resp.data : (resp.data['users'] ?? []);
  }

  Future<void> _loadSubscriptionPricing() async {
    try {
      final url =
          '${UserService().dio.options.baseUrl}/admin/subscription-pricing';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _prixMensuel = (data['prixMensuel'] ?? 5000.0).toDouble();
          });
        }
      }
    } catch (e) {
      // Garder le prix par défaut en cas d'erreur
      if (mounted) {
        setState(() {
          _prixMensuel = 5000.0;
        });
      }
    }
  }

  Future<void> _loadSubscription() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: UserService().dio.options.baseUrl,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final resp = await dio.get('/subscription/me');
      final data = resp.data ?? {};
      _hasSubscription =
          data['hasSubscription'] == true || (data['status'] == 'active');
      final act = data['activatedAt'];
      final exp = data['expiresAt'];
      _activatedAt = act != null ? DateTime.tryParse(act.toString()) : null;
      _expiresAt = exp != null ? DateTime.tryParse(exp.toString()) : null;
    } catch (_) {
      _hasSubscription = false;
      _activatedAt = null;
      _expiresAt = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     // children: const [
      //     //   Icon(Icons.workspace_premium, color: Colors.black),
      //     //   SizedBox(width: 8),
      //     //   Text('Abonnement'),
      //     // ],
      //   ),
      //   backgroundColor: const Color(0xFFF8BF13),
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (_userService.isAcheteur || _userService.isChauffeur)
              ? _buildAcheteurView()
              : _buildTransitaireView(),
    );
  }

  Widget _buildAcheteurView() {
    if (errorMsg != null) return Center(child: Text(errorMsg!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFCC00), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Transitaires recommandés',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _transitaires.length,
            itemBuilder: (context, index) {
              final u = _transitaires[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF8BF13),
                    child: Text(
                      ((u['entreprise'] ?? u['prenoms'] ?? 'T') as String)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text((u['entreprise'] ?? '-') as String),
                  subtitle: Text((u['email'] ?? '-') as String),
                  trailing: const Icon(Icons.verified, color: Colors.green),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransitaireView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFCC00), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Abonnement Transitaire',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (!_hasSubscription) ...[
                  const Text(
                    "Activez un abonnement mensuel pour être mis en avant auprès des acheteurs.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_prixMensuel.toInt()} FCFA / mois",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SubscriptionPaymentScreen(),
                          ),
                        );

                        // Si l'abonnement a été activé avec succès
                        if (result == true) {
                          await _loadSubscription(); // Recharger les données
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFFFCC00),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                          'Souscrire maintenant - ${_prixMensuel.toInt()} FCFA'),
                    ),
                  ),
                ] else ...[
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Activé le: ${_activatedAt?.day}/${_activatedAt?.month}/${_activatedAt?.year}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Expire le: ${_expiresAt?.day}/${_expiresAt?.month}/${_expiresAt?.year}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: const Color(0xFFFFCC00),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Gérer',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionProgressCard(),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _miniStatCard(
                    'Visibilité',
                    'Boostée',
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniStatCard('Mises en avant', '—', Icons.star)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildChartsSection(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle offre'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFF8BF13),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF8BF13),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionProgressCard() {
    final now = DateTime.now();
    final totalDays = 30;
    int remaining = 0;
    if (_expiresAt != null) {
      remaining = _expiresAt!.difference(now).inDays.clamp(0, 365);
    }
    final progress = (_expiresAt != null)
        ? (1 - (remaining / totalDays)).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Statut d\'abonnement',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_hasSubscription ? 'Actif' : 'Inactif',
                  style: TextStyle(
                      color: _hasSubscription
                          ? const Color(0xFF188100)
                          : Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFF8BF13)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
              _expiresAt != null
                  ? 'Votre abonnement expire dans $remaining jours'
                  : 'Aucun abonnement actif',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Performances',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Commandes livrées / mois',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const _BarChart(
                  values: [4, 8, 6, 10, 7, 12],
                  labels: ['J', 'F', 'M', 'A', 'M', 'J']),
              const SizedBox(height: 16),
              const Text('Répartition des clients',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const _PieChart(
                  values: [40, 35, 25],
                  colors: [Color(0xFFF8BF13), Colors.black, Colors.grey],
                  legends: ['Acheteurs', 'Chauffeurs', 'Autres']),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  const _BarChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxVal =
        (values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1)
            .toDouble();
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final h = (values[i] / maxVal) * 70 + 10;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      height: h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFCC00), Colors.black],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      labels[i],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String> legends;
  const _PieChart(
      {required this.values, required this.colors, required this.legends});

  @override
  Widget build(BuildContext context) {
    final total = values.fold<double>(0, (p, e) => p + e);
    double start = -90;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: CustomPaint(
            painter:
                _PiePainter(values: values, colors: colors, startAngle: start),
            size: const Size(140, 140),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(values.length, (i) {
            final pct =
                total > 0 ? (values[i] / total * 100).toStringAsFixed(0) : '0';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: colors[i],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text(
                  '${legends[i]} ($pct%)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }),
        )
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double startAngle;
  _PiePainter(
      {required this.values, required this.colors, required this.startAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (p, e) => p + e);
    double start = startAngle * 3.1415926535 / 180;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height / 2;
    for (int i = 0; i < values.length; i++) {
      final double sweep =
          total > 0 ? ((values[i] / total) * 2.0 * 3.1415926535) : 0.0;
      paint.color = colors[i];
      canvas.drawArc(rect.deflate(size.height / 4), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
