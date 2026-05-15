import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/data/models/room.dart'; // Use the new Room model
import 'package:tambarara_house_keeping/features/rooms/screen/room_detail_screen.dart';

import '../controller/roomController.dart';

class RoomsScreen extends StatefulWidget {
  final String initialFilter;
  const RoomsScreen({super.key, this.initialFilter = 'All'});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late String _filterStatus;
  List<Room> _allRooms = [];
  List<Room> _roomsOccupied = [];
  bool _isLoading = true;
  String? _errorMessage;
  final RoomRepository _roomRepository = RoomRepository();

  @override
  void initState() {
    super.initState();
    _filterStatus = widget.initialFilter;
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _allRooms = await _roomRepository.fetchRooms();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error fetching rooms: $_errorMessage'); // Debug print
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Room> get filteredRooms {
    if (_filterStatus == 'All') {
      return _allRooms;
    }
    if (_filterStatus == 'Dirty'.toUpperCase()) {
      return _allRooms.where((room) => room.roomStatus == 'DIRTY').toList();
    }
    return _allRooms.where((room) => room.roomStatus == _filterStatus).toList();
  }

  List<Room> get availableRooms {
    return _allRooms.where((room) => room.roomStatus == "CLEAN").toList();
  }

  List<Room> get dirtyRooms {
    return _allRooms.where((room) => room.roomStatus == "DIRTY").toList();
  }

  List<Room> get occupiedRooms {
    return _allRooms.where((room) => room.roomStatus == "OCCUPIED").toList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
        actions: [
          if (_filterStatus != 'All')
            IconButton(
              icon: const Icon(Icons.clear,color: Colors.white,),
              onPressed: () {
                setState(() {
                  _filterStatus = 'All';
                });
              },
              tooltip: "Clear Filter",
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _filterStatus = _filterStatus == 'Available' ? 'All' : 'Available';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                          border: _filterStatus == 'CLEAN' ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "ROOMS AVAILABLE",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${availableRooms.length}",
                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _filterStatus = _filterStatus == 'Occupied' ? 'All' : 'Occupied';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                          border: _filterStatus == 'OCCUPIED' ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "ROOMS OCCUPIED",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${occupiedRooms.length}",
                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _filterStatus = _filterStatus == 'Dirty' ? 'All' : 'Dirty';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                          border: _filterStatus == 'DIRTY' ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "ROOMS DIRTY",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${dirtyRooms.length}",
                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                _filterStatus == 'All' ? "Total Rooms: ${filteredRooms.length}" : "$_filterStatus Rooms: ${filteredRooms.length}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomDetailScreen(room: room),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getRoomColor(room.roomStatus),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Room ${room.roomNumber}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditDialog(room); // Pass the room object
                                      }
                                      if(value=="clean")
                                        _requestCleaning(room);
                                    },

                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'clean',
                                        child: Row(
                                          children: [
                                            Icon(Icons.cleaning_services, size: 18),
                                            SizedBox(width: 8),
                                            Text('Clean'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'maintenance',
                                        child: Row(
                                          children: [
                                            Icon(Icons.build, size: 18),
                                            SizedBox(width: 8),
                                            Text('Repair'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                room.roomStatus,
                                style: TextStyle(
                                  color: _getStatusColor(room.roomStatus),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }

  // Handle menu actions
  void _handleMenuAction(String action, Room room) {
    switch (action) {
      case 'edit':
        _showEditDialog(room);
        break;
      case 'clean':
        _requestCleaning(room);
        break;
      case 'maintenance':
        _requestMaintenance(room);
        break;
    }
  }
  // Method to edit room
  void _showEditDialog(Room room) {
    final TextEditingController roomNumberController = TextEditingController(text: room.roomNumber);
    String selectedStatus = room.roomStatus;
    bool isUpdating = false;
    showDialog(
      context: context,
      barrierDismissible: !isUpdating,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Room"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomNumberController,
                decoration: const InputDecoration(
                  labelText: "Room Number",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: "Room Status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'CLEAN', child: Text('CLEAN')),
                  DropdownMenuItem(value: 'DIRTY', child: Text('DIRTY')),
                  DropdownMenuItem(value: 'MAINTENANCE', child: Text('MAINTENANCE')),
                  DropdownMenuItem(value: 'OCCUPIED', child: Text('OCCUPIED')),
                  DropdownMenuItem(value: 'AVAILABLE', child: Text('AVAILABLE')),
                ],
                onChanged: (value) {
                  selectedStatus = value!;
                  print("Selected status updated to: $selectedStatus");
                }),
              if (isUpdating)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                // Close keyboard if open
                FocusScope.of(context).unfocus();

                // Show loading state
                setDialogState() {
                  isUpdating = true;
                };

                try {
                  final updatedRoom = await _roomRepository.updateRoomStatus(
                      room.id.toString(),
                      selectedStatus
                  );
                  setState(() {
                    final index = _allRooms.indexWhere(
                            (r) => r.roomNumber == room.roomNumber
                    );
                    if (index != -1) {
                      _allRooms[index] = updatedRoom;
                    }
                  });
                  // Close dialog
                  Navigator.pop(context);

                  // Show success message
                  _showSnackBar(
                      "Room ${room.roomNumber} status updated to $selectedStatus!"
                  );
                } catch (e) {
                  // Close dialog
                  Navigator.pop(context);

                  // Show error message
                  _showSnackBar(
                      "Failed to update room: ${e.toString()}",
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Method to request cleaning
  void _requestCleaning(Room room) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Request Cleaning"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Room ${room.roomNumber}"),
              const SizedBox(height: 10),
              const Text("Do you want to request cleaning for this room?"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Priority",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (value) {
                  // Handle priority selection if needed
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                if (room.roomStatus == 'Available' || room.roomStatus == 'NotReady') {
                  setState(() {
                    final index = _allRooms.indexWhere((r) => r.roomNumber == room.roomNumber);
                    if (index != -1) {
                      _allRooms[index] = room.copyWith(roomStatus: 'Cleaning');
                    }
                  });
                }

                _showSnackBar("Cleaning requested for Room ${room.roomNumber}!");
                _sendNotification("Cleaning request for Room ${room.roomNumber}");
                // TODO: Implement API call to update room status on backend
              },
              child: const Text("Submit Request"),
            ),
          ],
        );
      },
    );
  }

  // Method to request maintenance
  void _requestMaintenance(Room room) {
    final TextEditingController issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Request Maintenance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Room ${room.roomNumber}"),
                const SizedBox(height: 10),
                TextField(
                  controller: issueController,
                  decoration: const InputDecoration(
                    labelText: "Issue Description",
                    border: OutlineInputBorder(),
                    hintText: "e.g., AC not working",
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Priority",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                  ],
                  onChanged: (value) {
                    // Handle priority selection if needed
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Type",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                    DropdownMenuItem(value: 'Electrical', child: Text('Electrical')),
                    DropdownMenuItem(value: 'HVAC', child: Text('HVAC')),
                    DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    // Handle type selection if needed
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  final index = _allRooms.indexWhere((r) => r.roomNumber == room.roomNumber);
                  if (index != -1) {
                    _allRooms[index] = room.copyWith(roomStatus: 'Maintenance');
                  }
                });

                _showSnackBar("Maintenance requested for Room ${room.roomNumber}!");
                _sendNotification(
                    "Maintenance request for Room ${room.roomNumber}\n"
                        "Issue: ${issueController.text}"
                );
                // TODO: Implement API call to update room status on backend
              },
              child: const Text("Submit Request"),
            ),
          ],
        );
      },
    );
  }

  // Helper method to show snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
        ),
      ),
    );
  }

  void _sendNotification(String message) {
    debugPrint("Notification: $message");
  }

  Color _getRoomColor(String status) {
    switch (status) {
      case 'CLEAN':
        return Colors.green;
      case 'DIRTY':
        return Colors.red;
      case 'INPROGRESS':
        return Colors.orange;
      case 'INPROGRESS':
        return Colors.purple;
      case 'OCCUPIED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.white;
      case 'NotReady':
        return Colors.yellow;
      case 'Occupied':
        return Colors.white70;
      default:
        return Colors.white;
    }
  }
}