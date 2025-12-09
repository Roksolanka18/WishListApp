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

  // --- Static/Hardcoded Data: ОНОВЛЕНО ---
  final List<NotificationItem> _hardcodedData = [
    NotificationItem(
      id: '1',
      title: 'New Feature',
      message: 'We\'ve added a new feature to help you organize your wishlists.',
      timeAgo: '3d',
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Welcome!',
      message: 'Thanks for joining our Wishlist App community.',
      timeAgo: '1w',
      isRead: true,
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
      timeAgo: '5h',
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'App Maintenance',
      message: 'Scheduled maintenance will occur on Jan 5th, 2026.',
      timeAgo: '2h',
      isRead: false,
    ),
    NotificationItem(
      id: '6',
      title: 'Login attempt',
      message: 'Unusual login attempt detected from new location.',
      timeAgo: '10m',
      isRead: false,
    ),
  ];

  // --- Methods for loading/error simulation (Task 2) ---

  Future<void> loadNotifications({bool shouldFail = false}) async {
    _status = LoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (shouldFail) {
      _status = LoadingStatus.error;
      _errorMessage = 'Failed to load notifications.';
    } else {
      _status = LoadingStatus.loaded;
      _notifications = _hardcodedData;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    // Logic to mark as read
  }
}