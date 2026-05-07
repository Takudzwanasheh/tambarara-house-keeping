import 'package:flutter/material.dart';
import '../model/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<NotificationModel> notifications = [
      NotificationModel(
        title: "Room 101 Cleaned",
        message: "Housekeeper Sarah has finished cleaning Room 101.",
        time: "5 mins ago",
        isRead: false,
      ),
      NotificationModel(
        title: "Maintenance Alert",
        message: "Room 204 reported a leaky faucet. Needs attention.",
        time: "15 mins ago",
        isRead: false,
      ),
      NotificationModel(
        title: "New Task Assigned",
        message: "You have been assigned to supervise the 3rd floor.",
        time: "1 hour ago",
        isRead: true,
      ),
      NotificationModel(
        title: "Shift Update",
        message: "Night shift schedule for next week is now available.",
        time: "3 hours ago",
        isRead: true,
      ),
      NotificationModel(
        title: "Stock Low",
        message: "Cleaning supplies for floor 2 are running low.",
        time: "Yesterday",
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: notification.isRead ? Colors.grey[200] : Colors.blue[50],
                child: Icon(
                  notification.title.contains("Maintenance") ? Icons.build_rounded : Icons.notifications_rounded,
                  color: notification.isRead ? Colors.grey : Colors.blue[800],
                  size: 20,
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.time,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              trailing: !notification.isRead
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                // Handle notification click
              },
            ),
          );
        },
      ),
    );
  }
}
