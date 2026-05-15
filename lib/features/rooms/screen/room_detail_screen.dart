import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/data/models/room.dart';
import 'package:tambarara_house_keeping/data/repository/room_repository.dart';

import '../controller/roomController.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Room _room;
  final RoomRepository _roomRepository = RoomRepository();
  bool _isUpdating = false;
  bool _isLoading = false;
  late String _filterStatus;
  List<Room> _allRooms = [];

  // Sample data - in real app, this would come from API
  Map<String, dynamic> _roomDetails = {};
  List<Map<String, dynamic>> _activities = [];

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
  void initState() {
    super.initState();
    _room = widget.room;
    _filterStatus = 'All';
    _fetchRoomDetails();
  }

  Future<void> _fetchRoomDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch latest room data
      final updatedRoom = await _roomRepository.getRoomById(_room.roomNumber);
      setState(() {
        _room = updatedRoom;
      });

      // Fetch all rooms for the lists
      final allRooms = await _roomRepository.fetchRooms();
      setState(() {
        _allRooms = allRooms;
      });

      _setSampleData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading room details: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _setSampleData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setSampleData() {
    _roomDetails = {
      'roomType': _room.roomType,
      'capacity': _room.roomCapacity,
      'rate': '\$${_room.roomPrice.toString()}/night',
    };

    _activities = [
      {'title': 'Cleaning Completed', 'time': 'Today, 10:30 AM', 'user': 'by Sarah J.'},
      {'title': 'Maintenance Check', 'time': 'Yesterday, 04:15 PM', 'user': 'by Mike R.'},
      {'title': 'Linens Changed', 'time': '2 days ago', 'user': 'by Sarah J.'},
    ];
  }

  Future<void> _updateRoomStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedRoom = await _roomRepository.updateRoomStatus(_room.roomNumber, newStatus);

      setState(() {
        _room = updatedRoom;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room ${_room.roomNumber} status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the room details
        await _fetchRoomDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showEditRoomDialog() {
    final TextEditingController roomNumberController = TextEditingController(text: _room.roomNumber);
    final TextEditingController roomTypeController = TextEditingController(text: _room.roomType);
    final TextEditingController roomPriceController=TextEditingController(text:_room.roomNumber);
    final TextEditingController roomCapacityController= TextEditingController(text:_room.roomCapacity);
    final TextEditingController priceController = TextEditingController(text: _room.roomPrice.toString());
    String selectedStatus = _room.roomStatus;
    bool isLocalUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: !isLocalUpdating,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Room'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: roomNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Room Number',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomCapacityController,
                      decoration: const InputDecoration(
                        labelText: 'Room Capacity',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Room Type',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price per Night',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                        DropdownMenuItem(value: 'OCCUPIED', child: Text('Occupied')),
                        DropdownMenuItem(value: 'CLEAN', child: Text('Clean')),
                        DropdownMenuItem(value: 'DIRTY', child: Text('Dirty')),
                        DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStatus = value!;
                        });
                        print("Selected status updated to: $selectedStatus");
                      },
                    ),
                    if (isLocalUpdating)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLocalUpdating
                      ? null
                      : () async {
                    FocusScope.of(context).unfocus();
                    setDialogState(() {
                      isLocalUpdating = true;
                    });

                    try {
                      // Update room with all fields
                      final Map<String, dynamic> updatedData = {
                        'roomType': roomTypeController.text,
                        "roomNumber":roomNumberController.text,
                        "roomCapacity":roomCapacityController.text,
                        'roomPrice': double.parse(priceController.text),
                        'roomStatus': selectedStatus,
                      };

                      final updatedRoom = await _roomRepository.updateRoom(
                        _room.id.toString(),
                        updatedData,
                      );

                      setState(() {
                        _room = updatedRoom;
                        final index = _allRooms.indexWhere(
                                (r) => r.id == _room.id
                        );
                        if (index != -1) {
                          _allRooms[index] = updatedRoom;
                        }
                      });

                      // Close dialog
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Room updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      // Close dialog on error
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update room: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateRoom(Map<String, dynamic> updatedData) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedRoom = await _roomRepository.updateRoom(_room.roomNumber, updatedData);

      setState(() {
        _room = updatedRoom;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update room: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete Room ${_room.roomNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteRoom();
    }
  }

  Future<void> _deleteRoom() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _roomRepository.deleteRoom(_room.roomNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete room: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room ${_room.roomNumber} Details"),
        backgroundColor: _getRoomColor(_room.roomStatus),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showEditRoomDialog,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Room',
          ),
          IconButton(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Room',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getRoomColor(_room.roomStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRoomColor(_room.roomStatus), width: 2),
      ),
      child: Column(
        children: [
          if (_isUpdating)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                Icon(
                  _getStatusIcon(_room.roomStatus),
                  size: 64,
                  color: _getRoomColor(_room.roomStatus),
                ),
                const SizedBox(height: 12),
                Text(
                  _room.roomStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getRoomColor(_room.roomStatus),
                  ),
                ),
                const Text(
                  "Current Status",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Room Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow(Icons.king_bed, "Room Type", _room.roomType),
            _buildInfoRow(Icons.timelapse, "Ocupied At", "12:01 PM"),
            _buildInfoRow(Icons.watch, "Evacuated At", "00:00 AM"),
            _buildInfoRow(Icons.people, "Capacity", _roomDetails['capacity']?.toString() ?? 'N/A'),
            _buildInfoRow(Icons.attach_money, "Rate", "\$${_room.roomPrice.toString()}/night"),
            _buildInfoRow(Icons.code, "Room Number", _room.roomNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Housekeeping Activity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._activities.map((activity) => _buildActivityItem(
          activity['title']!,
          activity['time']!,
          activity['user']!,
        )),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, String user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$time • $user", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _updateRoomStatus('CLEAN'),
            icon: const Icon(Icons.cleaning_services),
            label: const Text("Mark Clean"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _updateRoomStatus('DIRTY'),
            icon: const Icon(Icons.warning),
            label: const Text("Mark Dirty"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _updateRoomStatus('MAINTENANCE'),
            icon: const Icon(Icons.build),
            label: const Text("Maintenance"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoomColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
      case 'CLEAN':
        return Colors.green;
      case 'DIRTY':
        return Colors.orange;
      case 'OCCUPIED':
        return Colors.red;
      case 'MAINTENANCE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
      case 'CLEAN':
        return Icons.check_circle;
      case 'DIRTY':
        return Icons.warning;
      case 'OCCUPIED':
        return Icons.person;
      case 'MAINTENANCE':
        return Icons.build;
      default:
        return Icons.help;
    }
  }
}