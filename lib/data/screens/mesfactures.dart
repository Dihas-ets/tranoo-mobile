import 'package:flutter/material.dart';

class MesFacturesPage extends StatelessWidget {
  final List<Map<String, String>> factures = [
    {
      "numero": "FCT1001",
      "date": "02 mars",
      "montant": "4 500 000 XOF",
      "paiement": "Carte bancaire",
      "statut": "Payée",
    },
    {
      "numero": "FCT1002",
      "date": "06 mars",
      "montant": "300 000 XOF",
      "paiement": "Mobile Money",
      "statut": "En attente",
    },
    {
      "numero": "FCT1003",
      "date": "10 mars",
      "montant": "150 000 XOF",
      "paiement": "Espèces",
      "statut": "Payée",
    },
    {
      "numero": "FCT1004",
      "date": "15 mars",
      "montant": "85 000 XOF",
      "paiement": "PayPal",
      "statut": "Remboursée",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        title: const Text("Mes Factures"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: factures.length,
        itemBuilder: (context, index) {
          final f = factures[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFF8BF13),
              ),
              title: Text("Facture ${f['numero']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date : ${f['date']}"),
                  Text("Montant : ${f['montant']}"),
                  Text("Mode de paiement : ${f['paiement']}"),
                  Text("Statut : ${f['statut']}"),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
