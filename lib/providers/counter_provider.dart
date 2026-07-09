import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';
import '../services/cart_service.dart';

class CounterProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final NotificationService _notificationService = NotificationService();
  final CartService _cartService = CartService();

  int _unreadMessagesCount = 0;
  int _unreadNotificationsCount = 0;

  int get unreadMessagesCount => _unreadMessagesCount;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  
  // Getter pour le nombre d'articles dans le panier
  int get cartItemCount => _cartService.totalQuantity;

  // Charger les compteurs
  Future<void> loadCounters() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        _unreadMessagesCount = 0;
        _unreadNotificationsCount = 0;
        notifyListeners();
        return;
      }

      final messagesCount = await _chatService.getTotalUnreadCount();
      final notificationsCount = await _notificationService.getUnreadCount();

      _unreadMessagesCount = messagesCount;
      _unreadNotificationsCount = notificationsCount;

      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des compteurs: $e');
    }
  }

  // Mettre à jour le compteur de messages
  void updateMessagesCount(int count) {
    _unreadMessagesCount = count;
    notifyListeners();
  }

  // Mettre à jour le compteur de notifications
  void updateNotificationsCount(int count) {
    _unreadNotificationsCount = count;
    notifyListeners();
  }

  // Incrémenter le compteur de messages
  void incrementMessagesCount() {
    _unreadMessagesCount++;
    notifyListeners();
  }

  // Incrémenter le compteur de notifications
  void incrementNotificationsCount() {
    _unreadNotificationsCount++;
    notifyListeners();
  }

  // Réinitialiser le compteur de messages
  void resetMessagesCount() {
    _unreadMessagesCount = 0;
    notifyListeners();
  }

  // Réinitialiser le compteur de notifications
  void resetNotificationsCount() {
    _unreadNotificationsCount = 0;
    notifyListeners();
  }

  // Vider le panier et mettre à jour le compteur
  void clearCart() {
    _cartService.clear();
    notifyListeners();
  }
}
