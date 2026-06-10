import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class PaymentForm extends StatelessWidget {
  final String pieceName;
  final String pieceImage;

  const PaymentForm({
    super.key,
    required this.pieceName,
    required this.pieceImage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentFormFor(pieceName))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(pieceImage),
            const SizedBox(height: 20),
            Text(
              l10n.partNameLabelShort(pieceName),
              style: const TextStyle(fontSize: 18),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.nameOnCard,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text(l10n.pay),
            ),
          ],
        ),
      ),
    );
  }
}
