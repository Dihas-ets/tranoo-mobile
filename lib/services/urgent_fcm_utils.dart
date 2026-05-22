import 'package:firebase_messaging/firebase_messaging.dart';

bool isUrgentFcmMessage(RemoteMessage message) {
  final type = (message.data['type'] ?? '').toString();
  if (type == 'alerte' || type == 'proposition_alerte') return true;
  final action = (message.data['action'] ?? '').toString();
  if (action == 'view_proposal') return true;
  final rt = (message.data['requestType'] ?? '').toString();
  return rt == 'vehicle_search' || rt == 'piece_search';
}
