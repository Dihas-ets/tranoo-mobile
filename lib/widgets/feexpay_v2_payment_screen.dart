import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:random_string/random_string.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/feexpay_v2_payment_service.dart';
import 'package:tranoo/widgets/feexpay_v2_constants.dart';
class FeexPayV2PaymentScreen extends StatefulWidget {
  final double amount;
  final String description;
  final String? customId;
  final String paymentType;
  final String? duree;
  final String? publiciteId;
  final String? achatId;

  const FeexPayV2PaymentScreen({
    super.key,
    required this.amount,
    required this.description,
    this.customId,
    this.paymentType = 'achat',
    this.duree,
    this.publiciteId,
    this.achatId,
  });

  @override
  State<FeexPayV2PaymentScreen> createState() => _FeexPayV2PaymentScreenState();
}

class _FeexPayV2PaymentScreenState extends State<FeexPayV2PaymentScreen>
    with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  late final TabController _tabCtrl;
  String _countryCode = 'BJ';
  String _network = 'mtn';
  String _cardType = 'VISA';
  bool _processing = false;
  bool _corisOtpSent = false;
  bool _waitingCardReturn = false;
  String? _error;
  int? _paymentSession;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _prefillUserInfo();
  }

  void _prefillUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _emailCtrl.text = user.email ?? '';
    final display = (user.displayName ?? '').trim();
    if (display.isNotEmpty) {
      final parts = display.split(RegExp(r'\s+'));
      _firstNameCtrl.text = parts.first;
      if (parts.length > 1) {
        _lastNameCtrl.text = parts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    if (_paymentSession != null) {
      FeexPayV2PaymentService.cancelPaymentSession(_paymentSession);
    }
    _tabCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  FeexPayCountry get _country => feexPayCountryByCode(_countryCode);

  FeexPayNetworkOption get _selectedNetwork => _country.networks
      .firstWhere((n) => n.id == _network, orElse: () => _country.networks.first);

  void _onCountryChanged(String? code) {
    if (code == null || code == _countryCode) return;
    final country = feexPayCountryByCode(code);
    setState(() {
      _countryCode = code;
      _network = country.networks.first.id;
      _corisOtpSent = false;
      _otpCtrl.clear();
      _error = null;
    });
  }

  void _cancelWaiting() {
    if (_paymentSession != null) {
      FeexPayV2PaymentService.cancelPaymentSession(_paymentSession);
    }
    if (!mounted) return;
    setState(() {
      _processing = false;
      _waitingCardReturn = false;
      _paymentSession = null;
      _error = null;
    });
  }

  void _onNetworkSelected(String id) {
    setState(() {
      _network = id;
      _corisOtpSent = false;
      _otpCtrl.clear();
      _error = null;
    });
  }

  Future<void> _payMobile() async {
    if (widget.amount < FeexPayV2Constants.minMobileAmount) {
      setState(() => _error =
          'Montant minimum : ${FeexPayV2Constants.minMobileAmount.toStringAsFixed(0)} FCFA.');
      return;
    }

    final rawPhone = _phoneCtrl.text.trim();
    final phone = FeexPayV2PaymentService.normalizePhone(rawPhone, _country);
    final phoneError = FeexPayV2PaymentService.validatePhoneForNetwork(
      _network,
      rawPhone,
      country: _country,
    );
    if (phoneError != null) {
      setState(() => _error = phoneError);
      return;
    }

    final otp = _otpCtrl.text.trim();
    final customId = widget.customId ?? randomAlphaNumeric(15);

    if (_selectedNetwork.requiresOtpUpfront && otp.isEmpty) {
      setState(() => _error = 'Entrez l\'OTP obtenu via #144#391# (Orange Sénégal).');
      return;
    }

    if (_selectedNetwork.twoStepOtp && !_corisOtpSent) {
      setState(() {
        _processing = true;
        _error = null;
      });
      try {
        await FeexPayV2PaymentService.sendCorisOtp(
          amount: widget.amount,
          phoneNumber: phone,
          description: widget.description,
          customId: customId,
          paymentType: widget.paymentType,
          duree: widget.duree,
          publiciteId: widget.publiciteId,
          achatId: widget.achatId,
        );
        if (!mounted) return;
        setState(() {
          _processing = false;
          _corisOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code envoyé par SMS. Entrez-le pour confirmer.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _processing = false;
          _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        });
      }
      return;
    }

    if (_selectedNetwork.twoStepOtp && otp.isEmpty) {
      setState(() => _error = 'Entrez le code reçu par SMS.');
      return;
    }

    final session = FeexPayV2PaymentService.beginPaymentSession();
    setState(() {
      _processing = true;
      _error = null;
      _paymentSession = session;
      if (_selectedNetwork.mayRedirect) _waitingCardReturn = true;
    });

    final result = await FeexPayV2PaymentService.payWithMobileMoney(
      network: _network,
      amount: widget.amount,
      phoneNumber: phone,
      description: widget.description,
      customId: customId,
      paymentType: widget.paymentType,
      duree: widget.duree,
      publiciteId: widget.publiciteId,
      achatId: widget.achatId,
      otp: _selectedNetwork.twoStepOtp || _selectedNetwork.requiresOtpUpfront
          ? otp
          : null,
      sessionId: session,
    );

    _handlePaymentResult(result);
  }

  Future<void> _payCard() async {
    if (widget.amount < FeexPayV2Constants.minCardAmount) {
      setState(() => _error =
          'Montant minimum carte : ${FeexPayV2Constants.minCardAmount.toStringAsFixed(0)} FCFA.');
      return;
    }

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final rawPhone = _phoneCtrl.text.trim();
    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _error = 'Prénom et nom requis.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Adresse e-mail valide requise.');
      return;
    }
    final phone = FeexPayV2PaymentService.normalizePhone(rawPhone, _country);
    final phoneError = FeexPayV2PaymentService.validatePhoneForNetwork(
      'mtn',
      rawPhone,
      country: _country,
    );
    if (phoneError != null) {
      setState(() => _error = phoneError);
      return;
    }

    final session = FeexPayV2PaymentService.beginPaymentSession();
    setState(() {
      _processing = true;
      _waitingCardReturn = true;
      _error = null;
      _paymentSession = session;
    });

    final result = await FeexPayV2PaymentService.payWithCard(
      amount: widget.amount,
      phoneNumber: phone,
      firstName: firstName,
      lastName: lastName,
      email: email,
      typeCard: _cardType,
      description: widget.description,
      customId: widget.customId ?? randomAlphaNumeric(15),
      paymentType: widget.paymentType,
      duree: widget.duree,
      publiciteId: widget.publiciteId,
      achatId: widget.achatId,
      sessionId: session,
    );

    _handlePaymentResult(result);
  }

  void _handlePaymentResult(FeexPayV2PaymentResult result) {
    if (!mounted) return;
    if (result.cancelled) {
      setState(() {
        _processing = false;
        _waitingCardReturn = false;
        _paymentSession = null;
      });
      return;
    }
    if (result.success) {
      Navigator.pop(context, result);
      return;
    }
    setState(() {
      _processing = false;
      _waitingCardReturn = false;
      _paymentSession = null;
      _error = result.errorMessage ?? 'Paiement non confirmé.';
    });
  }

  Future<bool> _confirmLeaveWhileProcessing() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter le paiement ?'),
        content: Text(
          _waitingCardReturn
              ? 'La page de paiement est ouverte dans votre navigateur. '
                  'Si vous quittez, la vérification s\'arrêtera.'
              : 'Une demande a été envoyée sur votre téléphone. '
                  'Si vous quittez, la vérification s\'arrêtera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Rester'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    return leave == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_processing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_processing) return;
        final leave = await _confirmLeaveWhileProcessing();
        if (!leave || !mounted) return;
        _cancelWaiting();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Text(
            l10n.mobileMoneyPayment,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            controller: _tabCtrl,
            labelColor: Colors.amber.shade800,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.phone_android), text: 'Mobile Money'),
              Tab(icon: Icon(Icons.credit_card), text: 'Carte bancaire'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabCtrl,
              children: [
                _buildMobileTab(l10n),
                _buildCardTab(l10n),
              ],
            ),
            if (_processing)
              _WaitingOverlay(
                isCard: _waitingCardReturn,
                onCancel: _cancelWaiting,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTab(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              _AmountHeader(
                amount: widget.amount,
                description: widget.description,
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Pays'),
              const SizedBox(height: 8),
              _CountrySelector(
                value: _countryCode,
                enabled: !_processing,
                onChanged: _onCountryChanged,
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Choisissez votre réseau'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: _country.networks
                    .map(
                      (n) => _NetworkCard(
                        option: n,
                        selected: _network == n.id,
                        enabled: !_processing,
                        onTap: () => _onNetworkSelected(n.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Numéro Mobile Money'),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: _phoneCtrl,
                enabled: !_processing,
                label: 'Numéro',
                hint: _country.phoneHint,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 6),
              Text(
                _country.phoneHelp,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (_selectedNetwork.twoStepOtp) ...[
                const SizedBox(height: 16),
                _CorisStepsBanner(otpSent: _corisOtpSent),
                if (_corisOtpSent) ...[
                  const SizedBox(height: 12),
                  _StyledTextField(
                    controller: _otpCtrl,
                    enabled: !_processing,
                    label: 'Code SMS Coris',
                    hint: 'Ex : 45243',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.sms_outlined,
                  ),
                ],
              ],
              if (_selectedNetwork.requiresOtpUpfront) ...[
                const SizedBox(height: 12),
                _StyledTextField(
                  controller: _otpCtrl,
                  enabled: !_processing,
                  label: 'Code OTP Orange',
                  hint: 'Obtenu via #144#391#',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_outline,
                ),
              ],
            ],
          ),
        ),
        _PaymentFooter(
          error: _error,
          buttonLabel: _mobileButtonLabel(l10n),
          processing: _processing,
          onPressed: _payMobile,
        ),
      ],
    );
  }

  String _mobileButtonLabel(AppLocalizations l10n) {
    if (_processing) return 'Vérification...';
    if (_selectedNetwork.twoStepOtp && !_corisOtpSent) {
      return 'Recevoir le code SMS';
    }
    if (_selectedNetwork.twoStepOtp) return 'Confirmer avec le code';
    return l10n.pay;
  }

  Widget _buildCardTab(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              _AmountHeader(
                amount: widget.amount,
                description: widget.description,
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Type de carte'),
              const SizedBox(height: 12),
              Row(
                children: kFeexPayCardTypes.entries.map((entry) {
                  final selected = _cardType == entry.key;
                  final logo = entry.key == 'VISA'
                      ? FeexPayV2Constants.visaLogo
                      : FeexPayV2Constants.mastercardLogo;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: entry.key == 'VISA' ? 6 : 0,
                        left: entry.key == 'MASTERCARD' ? 6 : 0,
                      ),
                      child: _CardTypeTile(
                        label: entry.value,
                        logoAsset: logo,
                        selected: selected,
                        enabled: !_processing,
                        onTap: () => setState(() => _cardType = entry.key),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StyledTextField(
                      controller: _firstNameCtrl,
                      enabled: !_processing,
                      label: 'Prénom',
                      hint: 'Jean',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StyledTextField(
                      controller: _lastNameCtrl,
                      enabled: !_processing,
                      label: 'Nom',
                      hint: 'Dupont',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StyledTextField(
                controller: _emailCtrl,
                enabled: !_processing,
                label: 'E-mail',
                hint: 'vous@exemple.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              const _SectionTitle('Pays'),
              const SizedBox(height: 8),
              _CountrySelector(
                value: _countryCode,
                enabled: !_processing,
                onChanged: _onCountryChanged,
              ),
              const SizedBox(height: 12),
              _StyledTextField(
                controller: _phoneCtrl,
                enabled: !_processing,
                label: 'Téléphone',
                hint: _country.phoneHint,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 8),
              Text(
                'Vous serez redirigé vers la page sécurisée FeexPay pour saisir votre carte.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        _PaymentFooter(
          error: _error,
          buttonLabel: _processing ? 'Ouverture...' : 'Payer par carte',
          processing: _processing,
          onPressed: _payCard,
        ),
      ],
    );
  }
}

// ─── Composants UI ───────────────────────────────────────────────────────────

class _AmountHeader extends StatelessWidget {
  final double amount;
  final String description;
  final IconData icon;

  const _AmountHeader({
    required this.amount,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: Colors.white),
          const SizedBox(height: 10),
          const Text(
            'Montant à payer',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  final FeexPayNetworkOption option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _NetworkCard({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.amber : Colors.grey.shade200,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: option.logoAsset != null
                    ? _FeexPaySvg(asset: option.logoAsset!, height: 28)
                    : _BrandBadge(option: option),
              ),
              const Spacer(),
              Text(
                option.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Text(
                option.subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  final FeexPayNetworkOption option;
  const _BrandBadge({required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: option.brandColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        option.label,
        style: TextStyle(
          color: option.accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _CardTypeTile extends StatelessWidget {
  final String label;
  final String logoAsset;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _CardTypeTile({
    required this.label,
    required this.logoAsset,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.amber : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                logoAsset,
                package: FeexPayV2Constants.svgPackage,
                height: 28,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _StyledTextField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _CorisStepsBanner extends StatelessWidget {
  final bool otpSent;
  const _CorisStepsBanner({required this.otpSent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE85D04).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paiement Coris en 2 étapes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _stepRow(1, 'Recevoir le code par SMS', !otpSent),
          _stepRow(2, 'Confirmer avec le code reçu', otpSent),
        ],
      ),
    );
  }

  Widget _stepRow(int n, String text, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: active ? const Color(0xFFE85D04) : Colors.grey.shade300,
            child: Text(
              '$n',
              style: TextStyle(
                fontSize: 11,
                color: active ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.black87 : Colors.grey.shade600,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelector extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _CountrySelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: kFeexPayCountries
          .map(
            (c) => DropdownMenuItem(
              value: c.code,
              child: Text('${c.flag} ${c.name}'),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _PaymentFooter extends StatelessWidget {
  final String? error;
  final String buttonLabel;
  final bool processing;
  final VoidCallback onPressed;

  const _PaymentFooter({
    required this.error,
    required this.buttonLabel,
    required this.processing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error != null) ...[
              _ErrorBanner(message: error!),
              const SizedBox(height: 12),
            ],
            _PrimaryButton(
              label: buttonLabel,
              processing: processing,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeexPaySvg extends StatelessWidget {
  final String asset;
  final double height;

  const _FeexPaySvg({required this.asset, required this.height});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      package: FeexPayV2Constants.svgPackage,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool processing;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.processing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: processing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.amber.shade200,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class _WaitingOverlay extends StatelessWidget {
  final bool isCard;
  final VoidCallback onCancel;

  const _WaitingOverlay({required this.isCard, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCard ? Icons.open_in_browser : Icons.phone_android,
                  size: 48,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  isCard ? 'Finalisez sur la page FeexPay' : 'Validez sur votre téléphone',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _StepIndicator(
                  steps: isCard
                      ? const [
                          'Page de paiement ouverte',
                          'Saisissez votre carte',
                          'Revenez ici — confirmation auto',
                        ]
                      : const [
                          'Demande envoyée',
                          'Entrez votre code PIN ou confirmez',
                          'Confirmation automatique',
                        ],
                  activeStep: isCard ? 1 : 1,
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vérification en cours (~2 min max)',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextButton(onPressed: onCancel, child: const Text('Annuler')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int activeStep;

  const _StepIndicator({required this.steps, required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final done = i < activeStep;
        final active = i == activeStep;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle
                    : active
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                size: 18,
                color: done || active ? Colors.amber : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? Colors.black87 : Colors.grey.shade600,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

Future<FeexPayV2PaymentResult?> openFeexPayV2Payment(
  BuildContext context, {
  required double amount,
  required String description,
  String? customId,
  String paymentType = 'achat',
  String? duree,
  String? publiciteId,
  String? achatId,
}) {
  return Navigator.push<FeexPayV2PaymentResult>(
    context,
    MaterialPageRoute(
      builder: (_) => FeexPayV2PaymentScreen(
        amount: amount,
        description: description,
        customId: customId,
        paymentType: paymentType,
        duree: duree,
        publiciteId: publiciteId,
        achatId: achatId,
      ),
    ),
  );
}
