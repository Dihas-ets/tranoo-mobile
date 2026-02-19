import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String articleId;
  final String title;
  final String? imageUrl;
  final String priceLabel; // e.g. "120 000 f"
  final String? pieceType;
  final String? model;
  final String? fuelType;
  final String? modeLivraison; // consommation | transit
  final String? paysDestination;
  final String? detailsSupplementaires;
  final String? supplierId;
  final double? supplierLatitude;
  final double? supplierLongitude;
  final String? supplierName;
  int quantity;

  CartItem({
    required this.articleId,
    required this.title,
    required this.priceLabel,
    this.imageUrl,
    this.pieceType,
    this.model,
    this.fuelType,
    this.modeLivraison,
    this.paysDestination,
    this.detailsSupplementaires,
    this.supplierId,
    this.supplierLatitude,
    this.supplierLongitude,
    this.supplierName,
    this.quantity = 1,
  });

  double get unitPrice {
    final cleaned = priceLabel.replaceAll(' f', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'articleId': articleId,
    'title': title,
    'imageUrl': imageUrl,
    'priceLabel': priceLabel,
    'pieceType': pieceType,
    'model': model,
    'fuelType': fuelType,
    'modeLivraison': modeLivraison,
    'paysDestination': paysDestination,
    'detailsSupplementaires': detailsSupplementaires,
    'supplierId': supplierId,
    'supplierLatitude': supplierLatitude,
    'supplierLongitude': supplierLongitude,
    'supplierName': supplierName,
    'quantity': quantity,
  };

  static CartItem fromJson(Map<String, dynamic> json) => CartItem(
    articleId: json['articleId'] as String,
    title: json['title'] as String,
    imageUrl: json['imageUrl'] as String?,
    priceLabel: json['priceLabel'] as String,
    pieceType: json['pieceType'] as String?,
    model: json['model'] as String?,
    fuelType: json['fuelType'] as String?,
    modeLivraison: json['modeLivraison'] as String?,
    paysDestination: json['paysDestination'] as String?,
    detailsSupplementaires: json['detailsSupplementaires'] as String?,
    supplierId: json['supplierId'] as String?,
    supplierLatitude: (json['supplierLatitude'] as num?)?.toDouble(),
    supplierLongitude: (json['supplierLongitude'] as num?)?.toDouble(),
    supplierName: json['supplierName'] as String?,
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  );
}

class CartService extends ChangeNotifier {
  static const _storageKey = 'cart_items_v1';
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  bool _loaded = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.totalPrice);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list =
          (jsonDecode(raw) as List)
              .cast<Map<String, dynamic>>()
              .map(CartItem.fromJson)
              .toList();
      _items
        ..clear()
        ..addAll(list);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> addOrIncrement(CartItem item) async {
    await ensureLoaded();
    final index = _items.indexWhere((i) => i.articleId == item.articleId);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> updateQuantity(String articleId, int quantity) async {
    await ensureLoaded();
    final index = _items.indexWhere((i) => i.articleId == articleId);
    if (index >= 0) {
      _items[index].quantity = quantity.clamp(1, 9999);
      await _persist();
      notifyListeners();
    }
  }

  Future<void> remove(String articleId) async {
    await ensureLoaded();
    _items.removeWhere((i) => i.articleId == articleId);
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    await ensureLoaded();
    _items.clear();
    await _persist();
    notifyListeners();
  }
}

