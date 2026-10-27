import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/data/screens/installment_demo_service.dart';

const _navy = Color(0xFF103E35);
const _gold = Color(0xFFF8BF13);
const _background = Color(0xFFF4F0E5);
const _green = Color(0xFF1E9B73);
const _dashboardOrange = Color(0xFFE68A18);
const _dashboardOrangeAlpha = 0.48;
const _additionalDemoCosts = <String, int>{
  'Suivi du véhicule': 500000,
  'Assurance': 500000,
  'Frais administratifs': 500000,
};

String _formatXof(int amount) {
  final digits = amount.toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]} ',
  );
  return '$formatted FCFA';
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _formatCompactDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String _formatCompactXof(int amount) {
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1)}M';
  }
  if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(0)}k';
  }
  return '$amount';
}

bool _hasDemoAccess(String uid) => uid == installmentDemoUserUid;

Widget _accessDenied(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Démo paiement échelonné')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Cette fonctionnalité est réservée au compte autorisé.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class InstallmentDemoVehiclePage extends StatelessWidget {
  const InstallmentDemoVehiclePage({super.key, required this.vehicle});

  final InstallmentDemoVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !_hasDemoAccess(uid)) return _accessDenied(context);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Votre véhicule'),
        centerTitle: true,
        backgroundColor: _background,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: vehicle.imageUrl.isEmpty
                          ? const _VehicleImagePlaceholder()
                          : Image.network(
                              vehicle.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const _VehicleImagePlaceholder(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: _navy.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détail du prix',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _priceRow('Prix du véhicule', vehicle.price),
                        ..._additionalDemoCosts.entries.map(
                          (cost) => Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: _priceRow(cost.key, cost.value),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),
                        _priceRow('Frais financiers et intérêts', 0),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),
                        _priceRow(
                          'Coût total',
                          vehicle.price +
                              _additionalDemoCosts.values
                                  .fold(0, (sum, amount) => sum + amount),
                          emphasized: true,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Les frais indiqués sont ajoutés au prix du véhicule.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Retour'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: vehicle.totalPrice > 0
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => InstallmentDemoSchedulePage(
                                    vehicle: vehicle.withAdditionalCosts(
                                      _additionalDemoCosts,
                                    ),
                                    ownerUid: uid,
                                  ),
                                ),
                              )
                          : null,
                      child: const Text('Continuer le processus'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstallmentDemoSchedulePage extends StatefulWidget {
  const InstallmentDemoSchedulePage({
    super.key,
    required this.vehicle,
    required this.ownerUid,
  });

  final InstallmentDemoVehicle vehicle;
  final String ownerUid;

  @override
  State<InstallmentDemoSchedulePage> createState() =>
      _InstallmentDemoSchedulePageState();
}

class _InstallmentDemoSchedulePageState
    extends State<InstallmentDemoSchedulePage> {
  InstallmentDemoFrequency _frequency = InstallmentDemoFrequency.months;
  int _count = 2;
  final _trancheCountController = TextEditingController();
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  int get _maxCount => switch (_frequency) {
        InstallmentDemoFrequency.days => 730,
        InstallmentDemoFrequency.weeks => 104,
        InstallmentDemoFrequency.months => 24,
        InstallmentDemoFrequency.tranche => 24,
      };

  int? get _selectedCount {
    if (_frequency != InstallmentDemoFrequency.tranche) return _count;
    final count = int.tryParse(_trancheCountController.text);
    if (count == null || count < 2 || count > _maxCount) return null;
    return count;
  }

  List<int> get _countOptions => switch (_frequency) {
        InstallmentDemoFrequency.days => [
            ...List.generate(29, (index) => index + 2),
            45,
            60,
            90,
            120,
            180,
            270,
            365,
            540,
            730,
          ],
        InstallmentDemoFrequency.weeks =>
          List.generate(_maxCount - 1, (index) => index + 2),
        InstallmentDemoFrequency.months =>
          List.generate(_maxCount - 1, (index) => index + 2),
        InstallmentDemoFrequency.tranche => const [],
      };

  @override
  void dispose() {
    _trancheCountController.dispose();
    super.dispose();
  }

  void _changeFrequency(InstallmentDemoFrequency frequency) {
    setState(() {
      _frequency = frequency;
      if (frequency == InstallmentDemoFrequency.tranche) {
        _trancheCountController.clear();
      } else if (!_countOptions.contains(_count)) {
        _count = _countOptions.first;
      }
    });
  }

  Future<void> _chooseStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) setState(() => _startDate = selected);
  }

  Future<void> _savePlan() async {
    final requestedCount = _selectedCount;
    if (requestedCount == null ||
        requestedCount < 2 ||
        requestedCount > _maxCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saisissez un nombre entre 2 et $_maxCount '
            '${_frequencyLabel(_frequency).toLowerCase()}.',
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final plan = InstallmentDemoPlan(
        ownerUid: widget.ownerUid,
        vehicle: widget.vehicle,
        frequency: _frequency,
        startDate: _startDate,
        payments: createInstallmentDemoPayments(
          price: widget.vehicle.totalPrice,
          count: requestedCount,
          frequency: _frequency,
          startDate: _startDate,
        ),
      );
      await InstallmentDemoStorage.save(plan);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const InstallmentDemoDashboardPage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’enregistrer le programme : $error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != widget.ownerUid || !_hasDemoAccess(widget.ownerUid)) {
      return _accessDenied(context);
    }

    final selectedCount = _selectedCount;
    final preview = selectedCount == null
        ? null
        : createInstallmentDemoPayments(
            price: widget.vehicle.totalPrice,
            count: selectedCount,
            frequency: _frequency,
            startDate: _startDate,
          );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(widget.vehicle.title),
        backgroundColor: _background,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  const Text(
                    'Choisissez la fréquence et la durée.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _frequencyChip(
                          'Jours',
                          InstallmentDemoFrequency.days,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _frequencyChip(
                          'Semaines',
                          InstallmentDemoFrequency.weeks,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _frequencyChip(
                          'Mois',
                          InstallmentDemoFrequency.months,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _frequencyChip(
                          'Tranche',
                          InstallmentDemoFrequency.tranche,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Maximum : 2 ans ($_maxCount '
                    '${_frequencyLabel(_frequency).toLowerCase()}).',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  if (_frequency == InstallmentDemoFrequency.tranche)
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Nombre de tranches',
                            style: TextStyle(
                              color: _navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 84,
                          child: TextField(
                            controller: _trancheCountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: '2–24',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre d’échéances',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _navy,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _countOptions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.45,
                          ),
                          itemBuilder: (context, index) {
                            final count = _countOptions[index];
                            final selected = count == _count;
                            return InkWell(
                              borderRadius: BorderRadius.circular(13),
                              onTap: () => setState(() => _count = count),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected ? _gold : Colors.white,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: selected
                                        ? _gold
                                        : const Color(0xFFE2E2E2),
                                  ),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: selected ? Colors.white : _navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (preview == null)
                    const Text(
                      'Saisissez un nombre de tranches entre 2 et 24 pour afficher le calendrier.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    RichText(
                      textAlign: TextAlign.center,
                      text: _scheduleSummary(
                        preview.first.amount,
                        selectedCount!,
                        _frequency,
                      ),
                    ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _chooseStartDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text('Date de départ : ${_formatDate(_startDate)}'),
                  ),
                  const SizedBox(height: 18),
                  if (preview != null)
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _gold,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Première échéance : ${_formatDate(preview.first.dueDate)}\n'
                                'Dernière échéance : ${_formatDate(preview.last.dueDate)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _showBreakdown(preview),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Voir le détail des échéances',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _savePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _saving ? 'Enregistrement…' : 'Voir le tableau de bord',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frequencyChip(String label, InstallmentDemoFrequency frequency) {
    final selected = _frequency == frequency;
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () => _changeFrequency(frequency),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? _gold : Colors.white,
          border: Border.all(color: selected ? _gold : const Color(0xFFE2E2E2)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _navy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showBreakdown(List<InstallmentDemoPayment> payments) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _background,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Détail des ${payments.length} échéances',
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _green.withValues(alpha: 0.12),
                      foregroundColor: _navy,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(_formatXof(payments[index].amount)),
                    trailing: Text(_formatDate(payments[index].dueDate)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstallmentDemoDashboardPage extends StatefulWidget {
  const InstallmentDemoDashboardPage({super.key});

  @override
  State<InstallmentDemoDashboardPage> createState() =>
      _InstallmentDemoDashboardPageState();
}

class _InstallmentDemoDashboardPageState
    extends State<InstallmentDemoDashboardPage> {
  InstallmentDemoPlan? _plan;
  bool _loading = true;
  String? _error;
  bool _showCollectedAmount = true;
  bool _showAllScheduledPayments = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || !_hasDemoAccess(uid)) {
        setState(() {
          _loading = false;
          _error = 'Cette fonctionnalité est réservée au compte autorisé.';
        });
        return;
      }
      final plan = await InstallmentDemoStorage.load(uid);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
        if (plan == null) _error = 'Aucun programme de paiement enregistré.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger votre programme de paiement : $error';
      });
    }
  }

  Future<bool> _markPaymentAsPaid(int index) async {
    final plan = _plan;
    if (plan == null) return false;
    final payments = [...plan.payments];
    final current = payments[index];
    if (current.paid) return false;
    payments[index] = InstallmentDemoPayment(
      dueDate: current.dueDate,
      amount: current.amount,
      paid: true,
    );
    final updatedPlan = plan.copyWithPayments(payments);
    try {
      await InstallmentDemoStorage.save(updatedPlan);
      if (mounted) setState(() => _plan = updatedPlan);
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d’enregistrer le statut : $error'),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _payNextInstallment() async {
    final plan = _plan;
    if (plan == null) return;
    final nextIndex = plan.payments.indexWhere((payment) => !payment.paid);
    if (nextIndex < 0) return;

    await _openPayment(nextIndex);
  }

  Future<void> _openPayment(int index) async {
    final plan = _plan;
    if (plan == null || plan.payments[index].paid) return;

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => InstallmentDemoPaymentPage(
          payment: plan.payments[index],
          paymentNumber: index + 1,
          frequency: plan.frequency,
          onConfirm: () => _markPaymentAsPaid(index),
        ),
      ),
    );
    if (paid == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement effectué avec succès.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !_hasDemoAccess(uid)) return _accessDenied(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final plan = _plan;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Mon véhicule'),
        backgroundColor: _background,
      ),
      body: plan == null
          ? Center(
              child: Text(_error ?? 'Aucun programme de paiement disponible.'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 48),
              children: [
                _dashboardBalance(plan),
                const SizedBox(height: 12),
                _vehicleSummary(plan.vehicle),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _dashboardMetric(
                        icon: Icons.calendar_month,
                        label: 'Fréquence',
                        value: _frequencyLabel(plan.frequency),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dashboardMetric(
                        icon: Icons.payments_outlined,
                        label: 'Contribution',
                        value: _formatXof(
                          plan.payments.isEmpty
                              ? 0
                              : plan.payments.first.amount,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _nextPaymentCard(plan),
                const SizedBox(height: 22),
                _sectionTitle(
                  'Impayées — date dépassée',
                  'La date limite de paiement est passée',
                ),
                const SizedBox(height: 10),
                ..._paymentSection(
                  plan,
                  plan.payments.indexed
                      .where((item) =>
                          !item.$2.paid &&
                          item.$2.dueDate.isBefore(DateTime.now()))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle(
                  'Échéances à venir',
                  'Les prochaines contributions prévues',
                ),
                const SizedBox(height: 10),
                _upcomingPayments(plan),
                const SizedBox(height: 20),
                _historySection(plan),
              ],
            ),
    );
  }

  Widget _dashboardBalance(InstallmentDemoPlan plan) {
    final lastDate =
        plan.payments.isEmpty ? plan.startDate : plan.payments.last.dueDate;
    final daysRemaining = lastDate.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _dashboardOrange.withValues(alpha: _dashboardOrangeAlpha),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Montant collecté',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () => setState(
                  () => _showCollectedAmount = !_showCollectedAmount,
                ),
                color: Colors.white,
                icon: Icon(
                  _showCollectedAmount
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ],
          ),
          Text(
            _showCollectedAmount ? _formatXof(plan.totalPaid) : '••••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reste à payer : ${_formatXof(plan.remainingAmount)}',
            style: const TextStyle(color: Colors.white),
          ),
          const Divider(color: Colors.white54, height: 28),
          Row(
            children: [
              Expanded(
                child: _balanceDetail(
                  'Jours restants',
                  '${daysRemaining < 0 ? 0 : daysRemaining}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white54,
              ),
              Expanded(
                child: _balanceDetail('Fin prévue', _formatDate(lastDate)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vehicleSummary(InstallmentDemoVehicle vehicle) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 58,
                child: vehicle.imageUrl.isEmpty
                    ? const _VehicleImagePlaceholder()
                    : Image.network(
                        vehicle.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _VehicleImagePlaceholder(),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.type} · ${_formatXof(vehicle.totalPrice)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _balanceDetail(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );

  Widget _dashboardMetric({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _green.withValues(alpha: 0.12),
              foregroundColor: _green,
              child: Icon(icon, size: 17),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _nextPaymentCard(InstallmentDemoPlan plan) {
    final nextIndex = plan.payments.indexWhere((payment) => !payment.paid);
    final nextPayment =
        nextIndex < 0 ? null : plan.payments.elementAt(nextIndex);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.hourglass_bottom, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prochaine échéance',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  nextPayment == null
                      ? 'Toutes les échéances sont terminées'
                      : '${_formatDate(nextPayment.dueDate)} · '
                          '${_formatXof(nextPayment.amount)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          if (nextPayment != null) const SizedBox(width: 8),
          if (nextPayment != null)
            FilledButton(
              onPressed: _payNextInstallment,
              style: FilledButton.styleFrom(
                backgroundColor: _navy.withValues(alpha: 0.72),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text(
                'Payer\nmaintenant',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      );

  List<Widget> _paymentSection(
    InstallmentDemoPlan plan,
    List<(int, InstallmentDemoPayment)> items, {
    String emptyMessage = 'Aucune échéance en attente.',
  }) {
    if (items.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ];
    }
    return items
        .map(
          (item) => _paymentRow(
            plan,
            item.$1,
            item.$2,
            history: item.$2.paid,
          ),
        )
        .toList();
  }

  Widget _upcomingPayments(InstallmentDemoPlan plan) {
    if (plan.payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Aucune échéance prévue.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    final visibleCount = _showAllScheduledPayments
        ? plan.payments.length
        : plan.payments.length.clamp(0, 10);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1DED5)),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) => _installmentGridItem(
              index,
              plan.payments[index],
            ),
          ),
          if (plan.payments.length > 10)
            TextButton(
              onPressed: () => setState(
                () => _showAllScheduledPayments = !_showAllScheduledPayments,
              ),
              child: Text(
                _showAllScheduledPayments ? 'Voir moins' : 'Voir plus',
              ),
            ),
        ],
      ),
    );
  }

  Widget _installmentGridItem(int index, InstallmentDemoPayment payment) {
    final overdue = !payment.paid && payment.dueDate.isBefore(DateTime.now());
    return Semantics(
      button: !payment.paid,
      label:
          'Échéance ${index + 1}, ${_formatXof(payment.amount)}, ${_formatDate(payment.dueDate)}, '
          '${payment.paid ? 'payée' : overdue ? 'en retard' : 'à venir'}',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: payment.paid ? null : () => _openPayment(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: overdue && !payment.paid
                          ? const Color(0xFFFFE5E5)
                          : Colors.white,
                      border: Border.all(
                        color: payment.paid
                            ? _green
                            : overdue
                                ? Colors.redAccent
                                : const Color(0xFFDAD6CB),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: payment.paid
                        ? null
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: overdue ? Colors.redAccent : _navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  if (payment.paid)
                    const Positioned(
                      right: -1,
                      top: 5,
                      child: Icon(
                        Icons.check,
                        color: _green,
                        size: 29,
                        shadows: [
                          Shadow(color: Colors.white, blurRadius: 2),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCompactXof(payment.amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _formatCompactDate(payment.dueDate),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historySection(InstallmentDemoPlan plan) {
    final history = plan.payments.indexed
        .where((item) => item.$2.paid)
        .toList()
        .reversed
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Historique',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (history.isNotEmpty)
              TextButton(
                onPressed: () => _showFullHistory(history),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: const Text('Voir tout'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(Icons.swap_vert, color: _green, size: 30),
                SizedBox(height: 6),
                Text(
                  'Aucun paiement effectué',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vos paiements apparaîtront ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: history
                  .take(3)
                  .map(
                    (item) => _historyPaymentTile(
                      item.$1,
                      item.$2,
                      isLast: item == history.take(3).last,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _historyPaymentTile(
    int index,
    InstallmentDemoPayment payment, {
    bool isLast = false,
  }) =>
      ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: _green.withValues(alpha: 0.12),
          foregroundColor: _green,
          child: const Icon(Icons.check, size: 18),
        ),
        title: Text(
          'Échéance ${index + 1}',
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(_formatDate(payment.dueDate)),
        trailing: Text(
          _formatXof(payment.amount),
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        shape: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFECE9E1))),
      );

  Future<void> _showFullHistory(
    List<(int, InstallmentDemoPayment)> history,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _background,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Historique des paiements',
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _historyPaymentTile(
                      item.$1,
                      item.$2,
                      isLast: index == history.length - 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentRow(
    InstallmentDemoPlan plan,
    int index,
    InstallmentDemoPayment payment, {
    bool history = false,
  }) =>
      Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: BorderSide(
            color: history
                ? _green
                : payment.dueDate.isBefore(DateTime.now())
                    ? Colors.redAccent
                    : const Color(0xFFE1DED5),
            width:
                history || payment.dueDate.isBefore(DateTime.now()) ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _green.withValues(alpha: 0.15),
                    foregroundColor: _navy,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      history
                          ? 'payé'
                          : payment.dueDate.isBefore(DateTime.now())
                              ? 'en retard'
                              : 'à venir',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: history
                            ? _green
                            : payment.dueDate.isBefore(DateTime.now())
                                ? Colors.redAccent
                                : _green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!history)
                    TextButton(
                      onPressed: () => _openPayment(index),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      child: const Text(
                        'Payer',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Échéance ${index + 1}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                _formatXof(payment.amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatDate(payment.dueDate),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
}

class InstallmentDemoPaymentPage extends StatefulWidget {
  const InstallmentDemoPaymentPage({
    super.key,
    required this.payment,
    required this.paymentNumber,
    required this.frequency,
    required this.onConfirm,
  });

  final InstallmentDemoPayment payment;
  final int paymentNumber;
  final InstallmentDemoFrequency frequency;
  final Future<bool> Function() onConfirm;

  @override
  State<InstallmentDemoPaymentPage> createState() =>
      _InstallmentDemoPaymentPageState();
}

class _InstallmentDemoPaymentPageState
    extends State<InstallmentDemoPaymentPage> {
  bool _processing = false;

  Future<void> _confirmPayment() async {
    setState(() => _processing = true);
    final completed = await widget.onConfirm();
    if (!mounted) return;
    if (completed) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: _background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Récapitulatif',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _summaryRow(
                    'Échéance',
                    '${widget.paymentNumber} / '
                        '${_frequencyLabel(widget.frequency)}',
                  ),
                  _summaryRow(
                      'Date limite', _formatDate(widget.payment.dueDate)),
                  const Divider(height: 28),
                  _summaryRow(
                    'Montant à payer',
                    _formatXof(widget.payment.amount),
                    emphasized: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _processing ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _processing ? 'Traitement…' : 'Confirmer le paiement',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _summaryRow(String label, String value, {bool emphasized = false}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: emphasized ? _navy : Colors.black87,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );

class _VehicleImagePlaceholder extends StatelessWidget {
  const _VehicleImagePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Icon(Icons.directions_car, size: 56, color: Colors.blueGrey),
        ),
      );
}

Widget _priceRow(String label, int amount, {bool emphasized = false}) => Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? _navy : Colors.black54,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          _formatXof(amount),
          style: TextStyle(
            color: emphasized ? _gold : _navy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

String _frequencyLabel(InstallmentDemoFrequency frequency) =>
    switch (frequency) {
      InstallmentDemoFrequency.days => 'Jours',
      InstallmentDemoFrequency.weeks => 'Semaines',
      InstallmentDemoFrequency.months => 'Mois',
      InstallmentDemoFrequency.tranche => 'Tranches',
    };

TextSpan _scheduleSummary(
  int amount,
  int count,
  InstallmentDemoFrequency frequency,
) {
  final frequencyUnit = switch (frequency) {
    InstallmentDemoFrequency.days => 'jour',
    InstallmentDemoFrequency.weeks => 'semaine',
    InstallmentDemoFrequency.months => 'mois',
    InstallmentDemoFrequency.tranche => 'tranche',
  };
  final amountText = _formatXof(amount);
  final amountUnitStart = amountText.lastIndexOf(' ');
  return TextSpan(
    style: const TextStyle(color: _navy, fontWeight: FontWeight.w600),
    children: [
      const TextSpan(text: 'Vous paierez '),
      TextSpan(
        text: amountText.substring(0, amountUnitStart),
        style: const TextStyle(color: Colors.red),
      ),
      TextSpan(
        text: amountText.substring(amountUnitStart),
        style: const TextStyle(color: Colors.red),
      ),
      TextSpan(
        text: frequency == InstallmentDemoFrequency.tranche
            ? ' en '
            : ' par $frequencyUnit pendant ',
      ),
      TextSpan(
        text: '$count',
        style: const TextStyle(color: Colors.red),
      ),
      TextSpan(
        text: ' ${_frequencyLabel(frequency).toLowerCase()}',
      ),
      const TextSpan(text: '.'),
    ],
  );
}
