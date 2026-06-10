import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import '../services/feexpay_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
      final balanceResult = await FeexPayService.getAccountBalance();
      if (balanceResult['status'] == 'success') {
        setState(() {
          _accountBalance = balanceResult['data'];
        });
      }

      final transactions = await FeexPayService.getTransactionHistory(
        limit: 50,
        offset: 0,
      );

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.transactionsLoadError(e.toString());
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _showRefundDialog(Map<String, dynamic> transaction) async {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController(
      text: transaction['amount']?.toString() ?? '0',
    );
    final reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.processRefundTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.transactionWithId(
              transaction['transaction_id']?.toString() ?? '',
            )),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: l10n.refundAmountFcfa,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.refundReason,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _processRefund(
                transaction,
                amountController.text,
                reasonController.text,
              );
            },
            child: Text(l10n.refundAction),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        _showSnackBar(l10n.invalidAmount, isError: true);
        return;
      }

      final result = await FeexPayService.refund(
        transactionId: transaction['transaction_id'],
        amount: amount,
        reason: reason.isEmpty ? null : reason,
      );

      if (result['status'] == 'success') {
        _showSnackBar(l10n.refundSuccess);
        await _refreshData();
      } else {
        _showSnackBar(
          result['message'] ?? l10n.paymentFailed,
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(l10n.errorGeneric(e.toString()), isError: true);
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

  String _formatAmount(dynamic amount, AppLocalizations l10n) {
    if (amount == null) return l10n.valueAmountFcfa('0');
    final numAmount = double.tryParse(amount.toString()) ?? 0;
    return l10n.valueAmountFcfa(numAmount.toStringAsFixed(0));
  }

  String _formatDate(dynamic date, AppLocalizations l10n) {
    if (date == null) return l10n.unknownDate;
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feexpayTransactionsTitle),
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
              ? _buildErrorView(l10n)
              : _buildTransactionsView(l10n),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n) {
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
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsView(AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_accountBalance != null) _buildBalanceCard(l10n),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.transactionHistory,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                l10n.transactionCount(_transactions.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_transactions.isEmpty)
            _buildEmptyState(l10n)
          else
            ..._transactions.map(
              (transaction) => _buildTransactionCard(transaction, l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(AppLocalizations l10n) {
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
                  l10n.accountBalanceLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatAmount(_accountBalance!['balance'], l10n),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_accountBalance!['currency'] != null)
              Text(
                l10n.currencyWithValue(_accountBalance!['currency'].toString()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noTransactionsFound,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.transactionsEmptyHint,
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

  Widget _buildTransactionCard(
    Map<String, dynamic> transaction,
    AppLocalizations l10n,
  ) {
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
          transaction['description'] ?? l10n.transactionNoDescription,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(l10n.idWithValue(
              transaction['transaction_id']?.toString() ?? 'N/A',
            )),
            Text(l10n.dateWithValue(_formatDate(date, l10n))),
            if (transaction['payment_method'] != null)
              Text(l10n.methodWithValue(
                transaction['payment_method'].toString(),
              )),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatAmount(amount, l10n),
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
        onTap: () => _showTransactionDetails(transaction, l10n),
      ),
    );
  }

  void _showTransactionDetails(
    Map<String, dynamic> transaction,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactionDetailsTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                l10n.labelTransactionId,
                transaction['transaction_id']?.toString() ?? 'N/A',
              ),
              _buildDetailRow(
                l10n.amount,
                _formatAmount(transaction['amount'], l10n),
              ),
              _buildDetailRow(
                l10n.status,
                transaction['status']?.toString() ?? 'N/A',
              ),
              _buildDetailRow(
                l10n.description,
                transaction['description']?.toString() ?? 'N/A',
              ),
              _buildDetailRow(
                l10n.date,
                _formatDate(
                  transaction['created_at'] ?? transaction['date'],
                  l10n,
                ),
              ),
              if (transaction['payment_method'] != null)
                _buildDetailRow(
                  l10n.paymentMethod,
                  transaction['payment_method'].toString(),
                ),
              if (transaction['customer_email'] != null)
                _buildDetailRow(
                  l10n.customerEmailLabel,
                  transaction['customer_email'].toString(),
                ),
              if (transaction['customer_phone'] != null)
                _buildDetailRow(
                  l10n.phone,
                  transaction['customer_phone'].toString(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
          if (transaction['status']?.toString().toLowerCase() == 'success')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRefundDialog(transaction);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(l10n.refundAction),
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
