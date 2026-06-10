import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/l10n/app_localizations.dart';

import 'RetraitScreen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  double? _balance;
  String _currency = 'XOF';
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.myWallet,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.yourBalanceIs,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            _loading
                ? const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                )
                : Text(
                  _balance == null
                      ? '--'
                      : NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: '$_currency ',
                      ).format(_balance),
                  style: const TextStyle(fontSize: 35, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  context,
                  Icons.account_balance_wallet,
                  l10n.withdrawal,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RetraitScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n.transactions,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _transactions.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          return _transactionItem(index, l10n);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Color.fromRGBO(
              color.r.toInt(),
              color.g.toInt(),
              color.b.toInt(),
              0.2,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _transactionItem(int index, AppLocalizations l10n) {
    final tx = _transactions[index];
    final dateStr =
        tx['date'] != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(tx['date']))
            : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Text(
                (tx['type'] == 'in' ? 'E' : 'R'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['label'] ??
                        (tx['type'] == 'in' ? l10n.entry : l10n.withdrawal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: '${tx['currency'] ?? _currency} ',
                    ).format(tx['amount'] ?? 0),
                  ),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) throw Exception('Token manquant');
      final baseUrl = getBaseUrl().replaceAll('/api', '');
      final walletRes = await http.get(
        Uri.parse('$baseUrl/api/wallet/me'),
        headers: {'Authorization': 'Bearer $idToken'},
      );
      final txRes = await http.get(
        Uri.parse('$baseUrl/api/wallet/me/transactions'),
        headers: {'Authorization': 'Bearer $idToken'},
      );
      if (walletRes.statusCode == 200) {
        final data = jsonDecode(walletRes.body);
        _balance = (data['balance'] ?? 0).toDouble();
        _currency = data['currency'] ?? 'XOF';
      }
      if (txRes.statusCode == 200) {
        final data = jsonDecode(txRes.body);
        final List list = data['transactions'] ?? [];
        _transactions = list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }
}
