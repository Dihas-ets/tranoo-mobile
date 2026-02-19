import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/config/backend_config.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: getApiBaseUrl(),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<List<dynamic>> getUserOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final token = await user.getIdToken();
      final response = await _dio.get(
        '/orders/my-orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['orders'] ?? [];
      } else {
        throw Exception('Erreur lors du chargement des commandes');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<bool> hasPendingOrders() async {
    try {
      final orders = await getUserOrders();
      // Vérifier s'il y a des commandes en attente
      return orders.any((order) => 
        order['status'] == 'pending' || 
        order['status'] == 'commandé' ||
        order['status'] == 'en_cours' ||
        order['status'] == 'assigné'
      );
    } catch (e) {
      // En cas d'erreur réseau, on suppose qu'il n'y a pas de commandes en attente
      // pour éviter d'afficher le point vert incorrectement
      print('Erreur vérification commandes en attente: $e');
      return false;
    }
  }
}
