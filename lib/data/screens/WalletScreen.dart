import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'RetraitScreen.dart'; // Assure-toi que ce fichier existe bien

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<bool> _isStarSelectedList = [false, false, false, false];
  List<String> _transactionDates = ['', '', '', ''];

  // Fonction pour enregistrer la date d'un retrait
  void _onRetrait(int index) {
    setState(() {
      _isStarSelectedList[index] = true;
      _transactionDates[index] = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mon portefeuille",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {}, // Ajoute ton action ici
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Votre solde est de :",
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              "8.250.000 f",
              style: TextStyle(fontSize: 35, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // _actionButton(
                //   context,
                //   Icons.send,
                //   "Transfert",
                //   Colors.blue,
                //   null,
                // ),
                _actionButton(
                  context,
                  Icons.account_balance_wallet,
                  "Retrait",
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RetraitScreen()),
                    );
                  },
                ),
                // _actionButton(
                //   context,
                //   Icons.more_horiz,
                //   "Plus",
                //   Colors.green,
                //   null,
                // ),
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
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Transactions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          return _transactionItem(index);
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
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _transactionItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: GestureDetector(
        onTap: () {
          // Appelle _onRetrait pour enregistrer la date à chaque clic
          _onRetrait(index);
          _showRetraitPopup(index); // Afficher la pop-up avec la date
        },
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
              child: const Text(
                "R",
                style: TextStyle(
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
                  const Text(
                    "Retrait effectué",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Vous avez réussi votre paiement.",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_transactionDates[index].isNotEmpty)
                    Text(
                      _transactionDates[index],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.star,
              color: _isStarSelectedList[index] ? Colors.grey : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher une pop-up avec les détails du retrait
  void _showRetraitPopup(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Détails du retrait"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Votre retrait a été effectué avec succès."),
              const SizedBox(height: 10),
              Text(
                "Date : ${_transactionDates[index]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).pop(), // Fermer la pop-up
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }
}
