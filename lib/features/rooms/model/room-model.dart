import 'package:flutter/material.dart';

class DummyRooms {
  final String roomNumber;
  final String roomStatus;

  DummyRooms(this.roomNumber, this.roomStatus);
}


final List<DummyRooms> roomsList = [
  DummyRooms('A01', 'Available'),
  DummyRooms('A02', 'NotReady'),
  DummyRooms('A03', 'Maintenance'),
  DummyRooms('A04', 'Available'),
  DummyRooms('A05', 'Occupied'),
  DummyRooms('A06', 'Available'),
  DummyRooms('A07', 'Cleaning'),
  DummyRooms('B08', 'Occupied'),
  DummyRooms('B09', 'Available'),
  DummyRooms('B10', 'Maintenance'),
];
