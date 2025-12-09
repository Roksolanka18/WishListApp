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
  @override
  void initState() {
    super.initState();
    // Запускаємо завантаження при вході на екран
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
      // Для тестування помилки (Task 2b):
      // Provider.of<NotificationProvider>(context, listen: false).loadNotifications(shouldFail: true);
    });
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
              Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  if (provider.status == LoadingStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (provider.status == LoadingStatus.error) {
                    return Center(
                      child: Text('Error: ${provider.errorMessage}'),
                    );
                  } else if (provider.notifications.isEmpty) {
                    return const Center(child: Text("No new notifications."));
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: provider.notifications.length,
                        itemBuilder: (context, index) {
                          return _notificationItem(provider.notifications[index]);
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationItem(NotificationItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EAF0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.notifications_none, color: Color(0xFF9A4D73)),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        item.message,
        style: const TextStyle(color: Colors.black54),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        item.timeAgo,
        style: const TextStyle(color: Colors.black54),
      ),
      onTap: () {
        // Handle notification tap
      },
    );
  }
}