import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../notification_repository.dart'; 
import 'dart:async';

enum LoadingStatus { initial, loading, loaded, error }

class NotificationProvider with ChangeNotifier {
  final BaseNotificationRepository _notificationRepository; 

  LoadingStatus _status = LoadingStatus.initial;
  List<NotificationItem> _notifications = []; 
  String _errorMessage = ''; // 

  NotificationProvider(this._notificationRepository) {
    // автоматичний виклик завантаження при створенні провайдера
    fetchNotifications(); 
  }

  LoadingStatus get status => _status;
  List<NotificationItem> get notifications => _notifications;
  String get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;


  // завантаження списку сповіщень
  Future<void> fetchNotifications() async {
    _status = LoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // виклик репозиторію для отримання даних з Firestore
      _notifications = await _notificationRepository.getNotifications();
      _status = LoadingStatus.loaded;
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
    }
    notifyListeners();
  }

  void markAsRead(String id) async {
    try {
      await _notificationRepository.markAsRead(id);
      await fetchNotifications(); 
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = 'Error marking notification $id as read: ${e.toString()}';
      notifyListeners();
    }
  }
}