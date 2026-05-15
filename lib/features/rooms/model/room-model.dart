import 'package:flutter/material.dart';

class RoomModel {
  final String roomNumber;
  final String roomStatus;
  final String roomCapacity;
  final String roomPrice;
  final String roomType;

  RoomModel(
    this.roomNumber,
    this.roomStatus,
    this.roomCapacity,
    this.roomPrice,
    this.roomType,
  );

  factory RoomModel.fromMap(Map<String, dynamic> roomList) {
    return RoomModel(
        roomList["roomNumber"],
        roomList["roomStatus"],
        roomList["roomCapacity"],
        roomList["roomPrice"],
        roomList["roomType"]);
  }

}
