// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Constants for styling
  static const Color primaryPink = Color(0xFFF72585);
  static const Color softBackground = Color(0xFFF7EAF0);

  @override
  void initState() {
    super.initState();
    // Сповіщення завантажуються в конструкторі провайдера, 
    // але ми можемо додати load/fetch тут для ручного виклику, якщо потрібно.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Викликаємо fetchNotifications() для ручного оновлення/перезавантаження
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    // Мінімальний формат: Month/Day
    return '${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back), // Back arrow
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Consumer для відображення стану
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    final status = provider.status;
                    final notifications = provider.notifications;
                    
                    if (status == LoadingStatus.loading) {
                      return const Center(child: CircularProgressIndicator(color: primaryPink));
                    } else if (status == LoadingStatus.error) {
                      // Виправлення: Використовуємо provider.errorMessage
                      return Center(
                        child: Text('Error: ${provider.errorMessage}'),
                      );
                    } else if (notifications.isEmpty) {
                      return const Center(child: Text("No new notifications."));
                    } else {
                      // Додаємо RefreshIndicator для ручного оновлення
                      return RefreshIndicator(
                        onRefresh: provider.fetchNotifications,
                        color: primaryPink,
                        child: ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(context, notifications[index], provider);
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem item, NotificationProvider provider) {
    final bool isRead = item.isRead;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isRead ? Colors.grey.shade200 : softBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
            isRead ? Icons.notifications_none : Icons.notifications_active, 
            color: isRead ? Colors.grey : primaryPink
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        item.message,
        style: const TextStyle(color: Colors.black54),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      // Виправлення: Використовуємо item.sentAt з форматуванням
      trailing: Text(
        _formatDate(item.sentAt), 
        style: const TextStyle(color: Colors.black54),
      ),
      onTap: () {
        // Обробка натискання: позначити як прочитане
        if (!isRead) {
          provider.markAsRead(item.id);
        }
      },
    );
  }
}