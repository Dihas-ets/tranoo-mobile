import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String installmentDemoUserUid = '1ZMS5d0h0ohMJsX4Xx5457kMuEH3';

class InstallmentDemoVehicle {
  const InstallmentDemoVehicle({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.type,
    this.make,
    this.model,
    this.year,
    this.condition,
    this.location,
    this.description,
    this.details = const {},
    this.additionalCosts = const {},
  });

  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String type;
  final String? make;
  final String? model;
  final String? year;
  final String? condition;
  final String? location;
  final String? description;
  final Map<String, String> details;
  final Map<String, int> additionalCosts;

  int get totalPrice =>
      price + additionalCosts.values.fold(0, (sum, amount) => sum + amount);

  InstallmentDemoVehicle withAdditionalCosts(Map<String, int> costs) {
    return InstallmentDemoVehicle(
      id: id,
      title: title,
      price: price,
      imageUrl: imageUrl,
      type: type,
      make: make,
      model: model,
      year: year,
      condition: condition,
      location: location,
      description: description,
      details: details,
      additionalCosts: costs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'imageUrl': imageUrl,
        'type': type,
        'make': make,
        'model': model,
        'year': year,
        'condition': condition,
        'location': location,
        'description': description,
        'details': details,
        'additionalCosts': additionalCosts,
      };

  factory InstallmentDemoVehicle.fromJson(Map<String, dynamic> json) {
    return InstallmentDemoVehicle(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Véhicule',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      type: json['type'] as String? ?? 'Véhicule',
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      condition: json['condition'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      details: (json['details'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      additionalCosts: (json['additionalCosts'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          ) ??
          const {},
    );
  }
}

enum InstallmentDemoFrequency { days, weeks, months, tranche }

class InstallmentDemoPayment {
  const InstallmentDemoPayment({
    required this.dueDate,
    required this.amount,
    this.paid = false,
  });

  final DateTime dueDate;
  final int amount;
  final bool paid;

  Map<String, dynamic> toJson() => {
        'dueDate': dueDate.toIso8601String(),
        'amount': amount,
        'paid': paid,
      };

  factory InstallmentDemoPayment.fromJson(Map<String, dynamic> json) {
    return InstallmentDemoPayment(
      dueDate: DateTime.parse(json['dueDate'] as String),
      amount: (json['amount'] as num).toInt(),
      paid: json['paid'] as bool? ?? false,
    );
  }
}

class InstallmentDemoPlan {
  const InstallmentDemoPlan({
    required this.ownerUid,
    required this.vehicle,
    required this.frequency,
    required this.startDate,
    required this.payments,
  });

  final String ownerUid;
  final InstallmentDemoVehicle vehicle;
  final InstallmentDemoFrequency frequency;
  final DateTime startDate;
  final List<InstallmentDemoPayment> payments;

  int get totalPaid => payments
      .where((payment) => payment.paid)
      .fold(0, (sum, payment) => sum + payment.amount);

  int get remainingAmount => vehicle.totalPrice - totalPaid;
  int get paidCount => payments.where((payment) => payment.paid).length;

  InstallmentDemoPlan copyWithPayments(List<InstallmentDemoPayment> value) {
    return InstallmentDemoPlan(
      ownerUid: ownerUid,
      vehicle: vehicle,
      frequency: frequency,
      startDate: startDate,
      payments: value,
    );
  }

  Map<String, dynamic> toJson() => {
        'ownerUid': ownerUid,
        'vehicle': vehicle.toJson(),
        'frequency': frequency.name,
        'startDate': startDate.toIso8601String(),
        'payments': payments.map((payment) => payment.toJson()).toList(),
      };

  factory InstallmentDemoPlan.fromJson(Map<String, dynamic> json) {
    return InstallmentDemoPlan(
      ownerUid: json['ownerUid'] as String,
      vehicle: InstallmentDemoVehicle.fromJson(
        Map<String, dynamic>.from(json['vehicle'] as Map),
      ),
      frequency: InstallmentDemoFrequency.values.firstWhere(
        (frequency) => frequency.name == json['frequency'],
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      payments: (json['payments'] as List)
          .map(
            (payment) => InstallmentDemoPayment.fromJson(
              Map<String, dynamic>.from(payment as Map),
            ),
          )
          .toList(),
    );
  }
}

int parseInstallmentDemoPrice(String? value) {
  final normalized = (value ?? '').replaceAll(RegExp(r'[^0-9,.-]'), '');
  if (normalized.isEmpty) return 0;
  if (RegExp(r'^\d{1,3}([.,]\d{3})+$').hasMatch(normalized)) {
    return int.tryParse(normalized.replaceAll(RegExp(r'[.,]'), '')) ?? 0;
  }
  return (double.tryParse(normalized.replaceAll(',', '.')) ?? 0).round();
}

List<InstallmentDemoPayment> createInstallmentDemoPayments({
  required int price,
  required int count,
  required InstallmentDemoFrequency frequency,
  required DateTime startDate,
}) {
  final baseAmount = price ~/ count;
  final remainder = price % count;

  return List.generate(count, (index) {
    final paymentNumber = index + 1;
    final dueDate = switch (frequency) {
      InstallmentDemoFrequency.days =>
        startDate.add(Duration(days: paymentNumber)),
      InstallmentDemoFrequency.weeks =>
        startDate.add(Duration(days: paymentNumber * 7)),
      InstallmentDemoFrequency.months ||
      InstallmentDemoFrequency.tranche =>
        _addMonths(startDate, paymentNumber),
    };

    return InstallmentDemoPayment(
      dueDate: dueDate,
      amount: baseAmount + (index < remainder ? 1 : 0),
    );
  });
}

DateTime _addMonths(DateTime date, int months) {
  final monthIndex = date.month - 1 + months;
  final year = date.year + monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  return DateTime(
    year,
    month,
    date.day > lastDayOfMonth ? lastDayOfMonth : date.day,
  );
}

class InstallmentDemoStorage {
  static const _keyPrefix = 'installment_demo_plan_';

  static Future<void> save(InstallmentDemoPlan plan) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_keyPrefix${plan.ownerUid}',
      jsonEncode(plan.toJson()),
    );
  }

  static Future<InstallmentDemoPlan?> load(String uid) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString('$_keyPrefix$uid');
    if (value == null) return null;
    return InstallmentDemoPlan.fromJson(
      Map<String, dynamic>.from(jsonDecode(value) as Map),
    );
  }
}
