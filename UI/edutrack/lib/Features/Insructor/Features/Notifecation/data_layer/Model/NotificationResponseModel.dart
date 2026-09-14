class NotificationResponseModel {
  final String status;
  final int userId;
  final List<NotificationModel> notifications;

  NotificationResponseModel({
    required this.status,
    required this.userId,
    required this.notifications,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      status: json['status'] ?? '',
      userId: json['user_id'] ?? 0,
      notifications: (json['data'] as List? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
    );
  }
}

class NotificationModel {
  final int notificationId;
  final String title;
  final String message;
  final String notificationType;
  bool isRead; // ليست final لنتمكن من تغيير حالتها محلياً عند القراءة
  final String createdAt;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? 'INFO',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}
