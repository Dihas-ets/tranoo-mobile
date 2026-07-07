import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/widgets/feexpay_v2_payment_screen.dart';

import '../config/backend_config.dart';
import '../main.dart';

/// Popup global (peu importe l'écran) déclenché via FCM.
class InAppDeliveryPopup {
  static bool _isShowing = false;

  static Future<void> showLivreurArrived({required String deliveryId}) async {
    if (_isShowing) return;
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;

    final ctx = nav.overlay?.context;
    if (ctx == null) return;

    _isShowing = true;
    try {
      final details = await _fetchDelivery(deliveryId);
      final totalCommande = details['totalCommande'] ?? 0.0;
      final fraisLivraison = details['fraisLivraison'] ?? 0.0;

      await showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetCtx) {
          final l10n = AppLocalizations.of(sheetCtx)!;
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.green, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.driverArrivedTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.chooseAnAction,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 14),
                  _amountBox(
                    l10n: l10n,
                    totalCommande: totalCommande,
                    fraisLivraison: fraisLivraison,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(sheetCtx);
                            await _returnFlow(ctx, deliveryId, fraisLivraison);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.returnPackage),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(sheetCtx);
                            await _startFeexpayPayment(
                              ctx,
                              amount: totalCommande,
                              label: l10n.partsOrderPaymentLabel,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.payMyOrder),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      _isShowing = false;
    }
  }

  static Widget _amountBox({
    required AppLocalizations l10n,
    required double totalCommande,
    required double fraisLivraison,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _amountRow(
            l10n.orderTotalLabel,
            l10n.valueAmountFcfa(totalCommande.toStringAsFixed(0)),
          ),
          const SizedBox(height: 6),
          _amountRow(
            l10n.deliveryFeesLabel,
            l10n.valueAmountFcfa(fraisLivraison.toStringAsFixed(0)),
          ),
        ],
      ),
    );
  }

  static Widget _amountRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }

  static Future<Map<String, double>> _fetchDelivery(String deliveryId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) return {'totalCommande': 0.0, 'fraisLivraison': 0.0};

    final res = await Dio().get(
      '${getApiBaseUrl()}/deliveries/$deliveryId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = res.data;
    final delivery = (data is Map && data['delivery'] is Map) ? data['delivery'] as Map : data as Map;
    final total = (delivery['totalCommande'] as num?)?.toDouble() ?? double.tryParse('${delivery['totalCommande'] ?? 0}') ?? 0.0;
    final frais = (delivery['fraisLivraison'] as num?)?.toDouble() ?? double.tryParse('${delivery['fraisLivraison'] ?? 0}') ?? 0.0;
    return {'totalCommande': total, 'fraisLivraison': frais};
  }

  static Future<void> _returnFlow(BuildContext ctx, String deliveryId, double fraisLivraison) async {
    final l10n = AppLocalizations.of(ctx)!;
    final reasonController = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final sheetL10n = AppLocalizations.of(sheetCtx)!;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 12,
              top: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sheetL10n.returnReasonRequiredTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: sheetL10n.returnReasonHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetCtx, false),
                          child: Text(sheetL10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(sheetCtx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(sheetL10n.send),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (confirmed != true) return;

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(l10n.reasonRequired)),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('Token manquant');
      final res = await Dio().post(
        '${getApiBaseUrl()}/deliveries/$deliveryId/request-return',
        data: jsonEncode({'reason': reason}),
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(l10n.returnReportedPaymentRequired)),
        );
        await _startFeexpayPayment(
          ctx,
          amount: fraisLivraison,
          label: l10n.deliveryFeePaymentLabel,
        );
      } else {
        throw Exception('Erreur serveur (${res.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(l10n.returnError(e.toString()))),
      );
    }
  }

  static Future<void> _startFeexpayPayment(
    BuildContext ctx, {
    required double amount,
    required String label,
  }) async {
    final transKey = '${label}_${randomAlphaNumeric(12)}';
    await openFeexPayV2Payment(
      ctx,
      amount: amount,
      description: label,
      customId: transKey,
      paymentType: 'achat',
    );
  }
}
