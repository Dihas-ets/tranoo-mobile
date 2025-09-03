import 'package:flutter/material.dart';
import '../services/feexpay_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _accountBalance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger le solde du compte
      final balanceResult = await FeexPayService.getAccountBalance();
      if (balanceResult['status'] == 'success') {
        setState(() {
          _accountBalance = balanceResult['data'];
        });
      }

      // Charger l'historique des transactions
      final transactions = await FeexPayService.getTransactionHistory(
        limit: 50,
        offset: 0,
      );

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement: $e';
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _showRefundDialog(Map<String, dynamic> transaction) async {
    final amountController = TextEditingController(
      text: transaction['amount']?.toString() ?? '0',
    );
    final reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effectuer un reversement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transaction: ${transaction['transaction_id']}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Montant à rembourser (FCFA)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du remboursement',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _processRefund(transaction, amountController.text, reasonController.text);
            },
            child: const Text('Rembourser'),
          ),
        ],
      ),
    );
  }

  Future<void> _processRefund(
    Map<String, dynamic> transaction,
    String amountText,
    String reason,
  ) async {
    try {
      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        _showSnackBar('Montant invalide', isError: true);
        return;
      }

      final result = await FeexPayService.refund(
        transactionId: transaction['transaction_id'],
        amount: amount,
        reason: reason.isEmpty ? null : reason,
      );

      if (result['status'] == 'success') {
        _showSnackBar('Remboursement effectué avec succès');
        await _refreshData(); // Recharger les données
      } else {
        _showSnackBar(result['message'] ?? 'Erreur lors du remboursement', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0 FCFA';
    final numAmount = double.tryParse(amount.toString()) ?? 0;
    return '${numAmount.toStringAsFixed(0)} FCFA';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Date inconnue';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions FeexPay'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildTransactionsView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsView() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Solde du compte
          if (_accountBalance != null) _buildBalanceCard(),
          const SizedBox(height: 16),

          // En-tête des transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique des transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${_transactions.length} transaction(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Liste des transactions
          if (_transactions.isEmpty)
            _buildEmptyState()
          else
            ..._transactions.map((transaction) => _buildTransactionCard(transaction)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Solde du compte',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatAmount(_accountBalance!['balance']),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_accountBalance!['currency'] != null)
              Text(
                'Devise: ${_accountBalance!['currency']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction trouvée',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les transactions apparaîtront ici après vos premiers paiements',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final status = transaction['status']?.toString() ?? 'unknown';
    final amount = transaction['amount'];
    final date = transaction['created_at'] ?? transaction['date'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(
            status.toLowerCase() == 'success' ? Icons.check : Icons.payment,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction['description'] ?? 'Transaction sans description',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${transaction['transaction_id'] ?? 'N/A'}'),
            Text('Date: ${_formatDate(date)}'),
            if (transaction['payment_method'] != null)
              Text('Méthode: ${transaction['payment_method']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatAmount(amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la transaction'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', transaction['transaction_id'] ?? 'N/A'),
              _buildDetailRow('Montant', _formatAmount(transaction['amount'])),
              _buildDetailRow('Statut', transaction['status'] ?? 'N/A'),
              _buildDetailRow('Description', transaction['description'] ?? 'N/A'),
              _buildDetailRow('Date', _formatDate(transaction['created_at'] ?? transaction['date'])),
              if (transaction['payment_method'] != null)
                _buildDetailRow('Méthode', transaction['payment_method']),
              if (transaction['customer_email'] != null)
                _buildDetailRow('Email client', transaction['customer_email']),
              if (transaction['customer_phone'] != null)
                _buildDetailRow('Téléphone', transaction['customer_phone']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          if (transaction['status']?.toString().toLowerCase() == 'success')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRefundDialog(transaction);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Rembourser'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
