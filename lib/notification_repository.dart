// lib/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/notification_item.dart';

abstract class BaseNotificationRepository {
  // Отримання всіх сповіщень (Future)
  Future<List<NotificationItem>> getNotifications();
  // Позначити сповіщення як прочитане
  Future<void> markAsRead(String notificationId);
}

class NotificationRepository implements BaseNotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User is not authenticated. Cannot access notifications.");
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _notificationsCollection {
    final uid = _currentUserId;
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  // Отримання списку сповіщень
  @override
  Future<List<NotificationItem>> getNotifications() async {
    final snapshot = await _notificationsCollection
        .orderBy('sent_at', descending: true) 
        .get(); 
        
    return snapshot.docs.map((doc) => NotificationItem.fromFirestore(doc)).toList();
  }

  // Оновлення статусу сповіщення
  @override
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'is_read': true,
    });
  }
}