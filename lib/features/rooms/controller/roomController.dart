// lib/data/repository/room_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tambarara_house_keeping/data/models/room.dart'; // Import the Room model
import 'package:tambarara_house_keeping/features/rooms/model/room-model.dart';
import 'package:tambarara_house_keeping/utils/contants.dart';

class RoomRepository {

  final baseUrl = Constants.baseUrl;
  static const int _timeoutSeconds = 10;

  Future<List<Room>> fetchRooms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/room/all'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> roomJsonList = jsonDecode(response.body);
        print(" ROOMS AVAILABLE , $roomJsonList");
        return roomJsonList.map((json) => Room.fromJson(json)).toList();
      } else {
        String errorMessage = 'Failed to load rooms. Status code: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON or message key is missing
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection or server is unreachable.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  // NEW: Edit/Update a room
  Future<Room> updateRoom(String roomId, Map<String, dynamic> roomData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/room/update/$roomId'),  // Fixed: use roomId, not roomNumber
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(roomData),  // roomData contains the fields to update
      ).timeout(const Duration(seconds: _timeoutSeconds));

      print("Update Room Response Status: ${response.statusCode}");
      print("Update Room Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Handle different response structures
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          return Room.fromJson(responseData['data']);
        } else if (responseData.containsKey('room')) {
          return Room.fromJson(responseData['room']);
        } else {
          return Room.fromJson(responseData);
        }
      } else {
        String errorMessage = 'Failed to update room. Status code: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection. Cannot update room.');
    } on TimeoutException {
      throw Exception('Update request timed out. Please try again.');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to update room: ${e.toString()}');
    }
  }

  //update roomStatus
  Future<Room> updateRoomStatus(String id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/room/edit/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'roomStatus': status,
          // or 'status': status depending on your API
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));
      print("Room ID $id");
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is Map) {
          return Room.fromJson(responseData['data']);
        } else {
          return Room.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to update room status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating room status: ${e.toString()}');
    }
  }
  // NEW: Create/Add a new room
  Future<Room> createRoom(Map<String, dynamic> roomData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/room/add'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(roomData),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Handle different response structures
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          return Room.fromJson(responseData['data']);
        } else if (responseData.containsKey('room')) {
          return Room.fromJson(responseData['room']);
        } else {
          return Room.fromJson(responseData);
        }
      } else {
        String errorMessage = 'Failed to create room. Status code: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection. Cannot create room.');
    } on TimeoutException {
      throw Exception('Create request timed out. Please try again.');
    } catch (e) {
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }

  Future<bool> deleteRoom(String roomNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/room/$roomNumber'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        String errorMessage = 'Failed to delete room. Status code: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection. Cannot delete room.');
    } on TimeoutException {
      throw Exception('Delete request timed out. Please try again.');
    } catch (e) {
      throw Exception('Failed to delete room: ${e.toString()}');
    }
  }

  // NEW: Get single room by ID
  Future<Room> getRoomById(String roomNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/room/$roomNumber'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Handle different response structures
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          return Room.fromJson(responseData['data']);
        } else if (responseData.containsKey('room')) {
          return Room.fromJson(responseData['room']);
        } else {
          return Room.fromJson(responseData);
        }
      } else {
        throw Exception('Room not found or failed to load.');
      }
    } catch (e) {
      throw Exception('Failed to fetch room: ${e.toString()}');
    }
  }

  // NEW: Get rooms by status
  Future<List<Room>> getRoomsByStatus(String roomStatus) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/room/status/$roomStatus'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> roomJsonList = jsonDecode(response.body);

        // Handle if response has a data wrapper
        if (roomJsonList.isNotEmpty && roomJsonList[0] is Map && roomJsonList[0].containsKey('data')) {
          final List<dynamic> nestedList = roomJsonList[0]['data'];
          return nestedList.map((json) => Room.fromJson(json)).toList();
        }

        return roomJsonList.map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rooms with status: $roomStatus');
      }
    } catch (e) {
      throw Exception('Failed to fetch rooms by status: ${e.toString()}');
    }
  }

  // NEW: Bulk update room statuses (for housekeeping tasks)
  Future<bool> bulkUpdateRoomStatus(Map<String, String> roomStatusUpdates) async {
    // roomStatusUpdates example: {'room_id_1': 'Cleaned', 'room_id_2': 'Dirty'}
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/room/bulk-status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'updates': roomStatusUpdates,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to bulk update room statuses: ${e.toString()}');
    }
  }

  // Helper method to generate headers with auth token if needed
  Map<String, String> _getHeaders({String? token}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}