/// Notification model representing a user notification
class NotificationModel {
  final String id;
  final String userId;
  final String? eventId;
  final String message;
  final String type; // 'event_update', 'general'
  final bool isRead;
  final DateTime createdAt;
  final String? eventName;

  NotificationModel({
    required this.id,
    required this.userId,
    this.eventId,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.eventName,
  });

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] is Map ? (json['user']['_id'] ?? '') : (json['user'] ?? ''),
      eventId: json['event'] is Map ? (json['event']['_id'] ?? '') : (json['event'] ?? ''),
      eventName: json['event'] is Map ? (json['event']['name'] ?? '') : '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'event': eventId,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    String? eventName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      eventName: eventName ?? this.eventName,
    );
  }
}
