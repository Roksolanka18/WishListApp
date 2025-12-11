// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../notification_repository.dart'; // << НОВИЙ ІМПОРТ
import 'dart:async';

// Використовуємо Вашу назву enum
enum LoadingStatus { initial, loading, loaded, error }

class NotificationProvider with ChangeNotifier {
  // Залежність від репозиторію
  final BaseNotificationRepository _notificationRepository; 

  LoadingStatus _status = LoadingStatus.initial;
  List<NotificationItem> _notifications = []; // Тепер дані з Firestore
  String _errorMessage = ''; // Поле для зберігання повідомлення про помилку

  // Конструктор, що приймає репозиторій
  NotificationProvider(this._notificationRepository) {
    // Автоматичний виклик завантаження при створенні провайдера
    fetchNotifications(); 
  }

  // Геттери
  LoadingStatus get status => _status;
  List<NotificationItem> get notifications => _notifications;
  String get errorMessage => _errorMessage; // Виправлення помилки
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // --- Методи для роботи з Firebase (Завдання 5) ---

  // Завантаження списку сповіщень
  Future<void> fetchNotifications() async {
    _status = LoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Виклик репозиторію для отримання даних з Firestore
      _notifications = await _notificationRepository.getNotifications();
      _status = LoadingStatus.loaded;
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
    }
    notifyListeners();
  }

  // Позначити сповіщення як прочитане
  void markAsRead(String id) async {
    try {
      await _notificationRepository.markAsRead(id);
      
      // Ручне оновлення списку після зміни даних (компенсація відсутності Stream)
      await fetchNotifications(); 
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = 'Error marking notification $id as read: ${e.toString()}';
      notifyListeners();
    }
  }
}