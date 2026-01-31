/// Event model representing an event
class EventModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final int capacity;
  final int registeredCount;
  final int checkedInCount;
  final String? imageUrl;
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final String? category;
  final String organizerId;
  final String? organizerName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.capacity,
    this.registeredCount = 0,
    this.checkedInCount = 0,
    this.imageUrl,
    required this.status,
    this.category,
    required this.organizerId,
    this.organizerName,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create EventModel from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      capacity: json['capacity'] ?? 0,
      registeredCount: json['registeredCount'] ?? 0,
      checkedInCount: json['checkedInCount'] ?? 0,
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'upcoming',
      category: json['category'],
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert EventModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'capacity': capacity,
      'registeredCount': registeredCount,
      'checkedInCount': checkedInCount,
      'imageUrl': imageUrl,
      'status': status,
      'category': category,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  EventModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? capacity,
    int? registeredCount,
    int? checkedInCount,
    String? imageUrl,
    String? status,
    String? category,
    String? organizerId,
    String? organizerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      checkedInCount: checkedInCount ?? this.checkedInCount,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      category: category ?? this.category,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if event is full
  bool get isFull => registeredCount >= capacity;

  /// Check if event is upcoming
  bool get isUpcoming => status == 'upcoming' && startDate.isAfter(DateTime.now());

  /// Check if event is ongoing
  bool get isOngoing => status == 'ongoing' || 
      (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate));

  /// Check if event is completed
  bool get isCompleted => status == 'completed' || DateTime.now().isAfter(endDate);

  /// Get attendance rate
  double get attendanceRate {
    if (registeredCount == 0) return 0.0;
    return (checkedInCount / registeredCount) * 100;
  }

  /// Get available spots
  int get availableSpots => capacity - registeredCount;

  @override
  String toString() {
    return 'EventModel(id: $id, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
