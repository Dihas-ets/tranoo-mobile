import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'RetraitScreen.dart'; // Pour formater les dates

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<bool> _isStarSelectedList = [false, false, false, false];
  List<String> _transactionDates = ['', '', '', ''];

  // Fonction pour changer l'état de l'étoile pour un retrait spécifique
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
          onPressed: () => Navigator.pop(context), // Retour à l'écran précédent
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
              style: TextStyle(
                fontSize: 35,
                color: Colors.black, // Montant en noir
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  context,
                  Icons.send,
                  "Transfert",
                  Colors.blue,
                  null,
                ),
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

                _actionButton(
                  context,
                  Icons.more_horiz,
                  "Plus",
                  Colors.green,
                  null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Ajout d'un espace entre les sections
            SizedBox(height: 20),
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
                        ), // Espacement ajusté
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

  // Fonction qui prend un index pour chaque retrait et gère l'état de l'étoile
  Widget _transactionItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: GestureDetector(
        onTap: () => _onRetrait(index), // Change l'état sans redirection
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
                      _transactionDates[index], // Afficher la date et l'heure
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
}
