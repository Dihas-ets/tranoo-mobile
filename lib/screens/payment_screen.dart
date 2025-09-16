import 'package:flutter/material.dart';
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
      // Générer un ID unique par défaut
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FeexPayService.initialize();
      setState(() {
        _isLoading = false;
        _successMessage = 'Service FeexPay initialisé avec succès';
      });
      
      // Effacer le message de succès après 3 secondes
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
        _errorMessage = 'Erreur lors de l\'initialisation: $e';
      });
    }
  }

  Future<void> _processPayment() async {
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
        callbackUrl: 'https://votre-site.com/success',
        errorCallbackUrl: 'https://votre-site.com/error',
      );

      if (result['status'] == 'success') {
        setState(() {
          _isLoading = false;
          _successMessage = 'Paiement initialisé avec succès!';
        });

        // Ouvrir la page de paiement
        final paymentUrl = result['payment_url'];
        if (paymentUrl != null) {
          await _openPaymentPage(paymentUrl);
        }

        // Afficher les détails de la transaction
        _showTransactionDetails(result);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Erreur lors du paiement';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  Future<void> _openPaymentPage(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        setState(() {
          _errorMessage = 'Impossible d\'ouvrir la page de paiement';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'ouverture: $e';
      });
    }
  }

  void _showTransactionDetails(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID Transaction: ${result['transaction_id']}'),
            const SizedBox(height: 8),
            Text('Montant: ${_amountController.text} FCFA'),
            const SizedBox(height: 8),
            Text('Description: ${_descriptionController.text}'),
            const SizedBox(height: 8),
            Text('Type: $_selectedPaymentType'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement FeexPay'),
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
              // Message de succès
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

              // Message d'erreur
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

              // Montant
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez saisir un montant valide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Le montant doit être supérieur à 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ID personnalisé
              TextFormField(
                controller: _customIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de commande',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un ID de commande';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type de paiement
              DropdownButtonFormField<String>(
                value: _selectedPaymentType,
                decoration: const InputDecoration(
                  labelText: 'Type de paiement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'MOBILE',
                    child: Text('Mobile Money (MTN, Moov, Orange)'),
                  ),
                  DropdownMenuItem(
                    value: 'CARD',
                    child: Text('Carte bancaire (VISA, Mastercard)'),
                  ),
                  DropdownMenuItem(
                    value: 'WALLET',
                    child: Text('Portefeuille FeexPay'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Bouton d'initialisation
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _initializeFeexPay,
                icon: const Icon(Icons.settings),
                label: const Text('Initialiser FeexPay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton de paiement
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _processPayment,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.payment),
                label: Text(_isLoading ? 'Traitement...' : 'Payer maintenant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Informations sur FeexPay
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
                          'À propos de FeexPay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'FeexPay est un agrégateur de paiement sécurisé qui accepte :',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• MTN Mobile Money, Moov Money, Orange Money\n'
                      '• Cartes VISA et Mastercard\n'
                      '• Portefeuilles numériques',
                      style: TextStyle(fontSize: 12),
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
