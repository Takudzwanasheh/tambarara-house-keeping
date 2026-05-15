// lib/data/models/room.dart
class Room {
  final int id;
  final String roomNumber;
  final String roomStatus;
  final String roomCapacity;
  final String roomPrice;
  final String roomType;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomStatus,
    required this.roomCapacity,
    required this.roomPrice,
    required this.roomType,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json["id"],
      roomNumber: json['roomNumber'].toString(),
      roomStatus: json['roomStatus'] as String,
      roomCapacity: json['roomCapacity'] as String,
      roomPrice: json['roomPrice'] as String,
      roomType: json['roomType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id":id,
      'roomNumber': roomNumber,
      'roomStatus': roomStatus,
      'roomCapacity': roomCapacity,
      'roomPrice': roomPrice,
      'roomType': roomType,
    };
  }

  // Helper for updating status (useful for local state changes before API call)
  Room copyWith({String? roomStatus}) {
    return Room(
      id: id,
      roomNumber: roomNumber,
      roomStatus: roomStatus ?? this.roomStatus,
      roomCapacity: roomCapacity,
      roomPrice: roomPrice,
      roomType: roomType,
    );
  }
}
