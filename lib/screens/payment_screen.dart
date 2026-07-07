import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/feexpay_service.dart';

class PaymentScreen extends StatefulWidget {
  final double? initialAmount;
  final String? orderId;
  final String? orderDescription;

  const PaymentScreen({
    Key? key,
    this.initialAmount,
    this.orderId,
    this.orderDescription,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customIdController = TextEditingController();
  
  String _selectedPaymentType = 'MOBILE';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toString();
    }
    if (widget.orderDescription != null) {
      _descriptionController.text = widget.orderDescription!;
    }
    if (widget.orderId != null) {
      _customIdController.text = widget.orderId!;
    } else {
      _customIdController.text = 'CMD_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _customIdController.dispose();
    super.dispose();
  }

  Future<void> _initializeFeexPay() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FeexPayService.initialize();
      setState(() {
        _isLoading = false;
        _successMessage = l10n.feexpayInitSuccess;
      });
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.feexpayInitError(e.toString());
      });
    }
  }

  Future<void> _processPayment() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final amount = double.parse(_amountController.text);
      final customId = _customIdController.text;
      final description = _descriptionController.text;

      final result = await FeexPayService.startPayment(
        amount: amount,
        customId: customId,
        description: description,
        paymentType: _selectedPaymentType,
      );

      if (result['status'] == 'success') {
        setState(() {
          _isLoading = false;
          _successMessage = l10n.paymentInitSuccess;
        });

        final paymentUrl = result['payment_url'];
        if (paymentUrl != null) {
          await _openPaymentPage(paymentUrl);
        }

        _showTransactionDetails(result);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? l10n.paymentFailed;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.errorGeneric(e.toString());
      });
    }
  }

  Future<void> _openPaymentPage(String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        setState(() {
          _errorMessage = l10n.cannotOpenPaymentPage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = l10n.errorOpening(e.toString());
      });
    }
  }

  void _showTransactionDetails(Map<String, dynamic> result) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactionDetailsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.labelTransactionId}: ${result['transaction_id']}'),
            const SizedBox(height: 8),
            Text('${l10n.amount}: ${l10n.valueAmountFcfa(_amountController.text)}'),
            const SizedBox(height: 8),
            Text('${l10n.description}: ${_descriptionController.text}'),
            const SizedBox(height: 8),
            Text('${l10n.typeLabel}: $_selectedPaymentType'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feexpayPaymentTitle),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.priceFcfa,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterAmount;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.enterValidAmount;
                  }
                  if (double.parse(value) <= 0) {
                    return l10n.amountMustBePositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterDescriptionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _customIdController,
                decoration: InputDecoration(
                  labelText: l10n.commandIdLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.receipt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterOrderId;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedPaymentType,
                decoration: InputDecoration(
                  labelText: l10n.paymentTypeLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'MOBILE',
                    child: Text(l10n.mobileMoneyProviders),
                  ),
                  DropdownMenuItem(
                    value: 'CARD',
                    child: Text(l10n.bankCardPayment),
                  ),
                  DropdownMenuItem(
                    value: 'WALLET',
                    child: Text(l10n.feexpayWallet),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _initializeFeexPay,
                icon: const Icon(Icons.settings),
                label: Text(l10n.initializeFeexpay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _processPayment,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.payment),
                label: Text(_isLoading ? l10n.processing : l10n.payNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          l10n.aboutFeexpay,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.feexpayAboutDescription,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.feexpayAcceptedMethods,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
