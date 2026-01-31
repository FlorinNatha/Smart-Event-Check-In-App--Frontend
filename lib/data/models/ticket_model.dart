/// Ticket model representing a user's event ticket
class TicketModel {
  final String id;
  final String eventId;
  final String userId;
  final String eventName;
  final String eventLocation;
  final DateTime eventDate;
  final String qrCode; // QR code data (usually ticket ID or unique identifier)
  final String status; // 'active', 'checked_in', 'expired', 'cancelled'
  final DateTime? checkedInAt;
  final String? checkedInBy;
  final DateTime registeredAt;
  final String? userName;
  final String? userEmail;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.eventName,
    required this.eventLocation,
    required this.eventDate,
    required this.qrCode,
    required this.status,
    this.checkedInAt,
    this.checkedInBy,
    required this.registeredAt,
    this.userName,
    this.userEmail,
  });

  /// Create TicketModel from JSON
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      eventName: json['eventName'] ?? '',
      eventLocation: json['eventLocation'] ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : DateTime.now(),
      qrCode: json['qrCode'] ?? '',
      status: json['status'] ?? 'active',
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'])
          : null,
      checkedInBy: json['checkedInBy'],
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'])
          : DateTime.now(),
      userName: json['userName'],
      userEmail: json['userEmail'],
    );
  }

  /// Convert TicketModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'eventName': eventName,
      'eventLocation': eventLocation,
      'eventDate': eventDate.toIso8601String(),
      'qrCode': qrCode,
      'status': status,
      'checkedInAt': checkedInAt?.toIso8601String(),
      'checkedInBy': checkedInBy,
      'registeredAt': registeredAt.toIso8601String(),
      'userName': userName,
      'userEmail': userEmail,
    };
  }

  /// Create a copy with updated fields
  TicketModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? eventName,
    String? eventLocation,
    DateTime? eventDate,
    String? qrCode,
    String? status,
    DateTime? checkedInAt,
    String? checkedInBy,
    DateTime? registeredAt,
    String? userName,
    String? userEmail,
  }) {
    return TicketModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      eventName: eventName ?? this.eventName,
      eventLocation: eventLocation ?? this.eventLocation,
      eventDate: eventDate ?? this.eventDate,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInBy: checkedInBy ?? this.checkedInBy,
      registeredAt: registeredAt ?? this.registeredAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  /// Check if ticket is active
  bool get isActive => status == 'active';

  /// Check if ticket is checked in
  bool get isCheckedIn => status == 'checked_in';

  /// Check if ticket is expired
  bool get isExpired => status == 'expired' || eventDate.isBefore(DateTime.now());

  /// Check if ticket is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if event is upcoming
  bool get isUpcoming => eventDate.isAfter(DateTime.now());

  /// Get days until event
  int get daysUntilEvent {
    final now = DateTime.now();
    if (eventDate.isBefore(now)) return 0;
    return eventDate.difference(now).inDays;
  }

  /// Get hours until event
  int get hoursUntilEvent {
    final now = DateTime.now();
    if (eventDate.isBefore(now)) return 0;
    return eventDate.difference(now).inHours;
  }

  @override
  String toString() {
    return 'TicketModel(id: $id, eventName: $eventName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
