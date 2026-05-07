

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}