// lib/models/notification_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime sentAt; 
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.sentAt,
    this.isRead = false,
  });

  // 1. Конвертація З Firestore-документа
  factory NotificationItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return NotificationItem(
      id: snapshot.id,
      title: data['title'] as String,
      message: data['message'] as String,
      sentAt: (data['sent_at'] as Timestamp).toDate(),
      isRead: data['is_read'] as bool,
    );
  }

  // 2. Конвертація В Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'sent_at': Timestamp.fromDate(sentAt),
      'is_read': isRead,
    };
  }
}