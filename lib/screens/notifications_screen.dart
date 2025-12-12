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
  static const Color primaryPink = Color(0xFFF72585);
  static const Color softBackground = Color(0xFFF7EAF0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  String _formatDate(DateTime date) {
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
                    child: const Icon(Icons.arrow_back), 
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

              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    final status = provider.status;
                    final notifications = provider.notifications;
                    
                    if (status == LoadingStatus.loading) {
                      return const Center(child: CircularProgressIndicator(color: primaryPink));
                    } else if (status == LoadingStatus.error) {
                      return Center(
                        child: Text('Error: ${provider.errorMessage}'),
                      );
                    } else if (notifications.isEmpty) {
                      return const Center(child: Text("No new notifications."));
                    } else {
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
      trailing: Text(
        _formatDate(item.sentAt), 
        style: const TextStyle(color: Colors.black54),
      ),
      onTap: () {
        if (!isRead) {
          provider.markAsRead(item.id);
        }
      },
    );
  }
}