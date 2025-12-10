import 'package:flutter/material.dart';
import 'package:wishlist_app/models/notification_item.dart';
import 'dart:async';

enum LoadingStatus { initial, loading, loaded, error }

class NotificationProvider with ChangeNotifier {
  LoadingStatus _status = LoadingStatus.initial;
  List<NotificationItem> _notifications = [];
  String _errorMessage = '';

  LoadingStatus get status => _status;
  List<NotificationItem> get notifications => _notifications;
  String get errorMessage => _errorMessage;

  final List<NotificationItem> _hardcodedData = [
    NotificationItem(
      id: '1',
      title: 'Login attempt',
      message: 'Unusual login attempt detected from new location.',
      timeAgo: '10m',
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'New Feature',
      message: 'We\'ve added a new feature to help you organize your wishlists.',
      timeAgo: '3h',
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Update to Privacy Policy',
      message: 'Our Privacy Policy has been updated. Please review the changes.',
      timeAgo: '1d',
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Item Purchased',
      message: 'Great news! Your "New Laptop" item has been marked as purchased.',
      timeAgo: '3d',
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'App Maintenance',
      message: 'Scheduled maintenance will occur on Jan 5th, 2026.',
      timeAgo: '2h',
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: 'Welcome!',
      message: 'Thanks for joining our Wishlist App community.',
      timeAgo: '1w',
      isRead: true,
    ),
  ];


  Future<void> loadNotifications({bool shouldFail = false}) async {
    _status = LoadingStatus.loading;
    _errorMessage = '';
    notifyListeners(); // сповіщає всі віджети в інтерфейсі, які "слухають" цей провайдер

    await Future.delayed(const Duration(seconds: 1)); // імітує затримку, яка виникає при реальному завантаженні даних

    if (shouldFail) {
      _status = LoadingStatus.error;
      _errorMessage = 'Failed to load notifications.';
    } else {
      _status = LoadingStatus.loaded;
      _notifications = _hardcodedData;
    }
    notifyListeners(); // повідомляє UI про завершення асинхронної операції
  }

  void markAsRead(String id) {
    // реалізувати пізніше
  }
}