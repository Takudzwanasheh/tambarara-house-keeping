// maintenance_request_model.dart
class MaintenanceRequest {
  final int id;
  final String requestNumber;
  final RoomModels room;
  final String issueDescription;
  final String priority;
  final String type;
  final String status;
  final String requestedBy;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? notes;

  MaintenanceRequest({
    required this.id,
    required this.requestNumber,
    required this.room,
    required this.issueDescription,
    required this.priority,
    required this.type,
    required this.status,
    required this.requestedBy,
    required this.requestedAt,
    this.completedAt,
    this.notes,
  });

  // Helper getters for easier access
  int get roomNumber => room.roomNumber;
  String get roomStatus => room.roomStatus;
  String get roomType => room.roomType;
  String get roomCapacity => room.roomCapacity;
  String get roomPrice => room.roomPrice;

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] ?? 0,
      requestNumber: json['requestNumber'] ?? '',
      room: RoomModels.fromJson(json['room'] ?? {}),
      issueDescription: json['issueDescription'] ?? '',
      priority: json['priority'] ?? 'Medium',
      type: json['type'] ?? 'Other',
      status: json['status'] ?? 'PENDING',
      requestedBy: json['requestedBy'] ?? '',
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestNumber': requestNumber,
      'room': room.toJson(),
      'issueDescription': issueDescription,
      'priority': priority,
      'type': type,
      'status': status,
      'requestedBy': requestedBy,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

// Room Model
class RoomModels {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int roomNumber;
  final String roomStatus;
  final String roomCapacity;
  final String roomType;
  final String roomPrice;

  RoomModels({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.roomNumber,
    required this.roomStatus,
    required this.roomCapacity,
    required this.roomType,
    required this.roomPrice,
  });

  factory RoomModels.fromJson(Map<String, dynamic> json) {
    return RoomModels(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      roomNumber: json['roomNumber'] ?? 0,
      roomStatus: json['roomStatus'] ?? '',
      roomCapacity: json['roomCapacity'] ?? '',
      roomType: json['roomType'] ?? '',
      roomPrice: json['roomPrice']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'roomNumber': roomNumber,
      'roomStatus': roomStatus,
      'roomCapacity': roomCapacity,
      'roomType': roomType,
      'roomPrice': roomPrice,
    };
  }
}