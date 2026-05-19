import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/data/models/room.dart';
import 'package:tambarara_house_keeping/features/rooms/screen/room_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:tambarara_house_keeping/utils/contants.dart';
import '../controller/roomController.dart';
import '../model/MaintenanceRequest Model.dart';

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
  bool _isSubmitting = false;

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
      debugPrint('Error fetching rooms: $_errorMessage');
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
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (_filterStatus != 'All')
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _filterStatus = 'All';
                });
              },
              tooltip: "Clear Filter",
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchRooms,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchRooms,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "AVAILABLE",
                              count: availableRooms.length,
                              color: Colors.green,
                              filterValue: 'CLEAN',
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              title: "OCCUPIED",
                              count: occupiedRooms.length,
                              color: Colors.blue,
                              filterValue: 'OCCUPIED',
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              title: "DIRTY",
                              count: dirtyRooms.length,
                              color: Colors.red,
                              filterValue: 'DIRTY',
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _filterStatus == 'All' 
                                  ? "Total Rooms: ${filteredRooms.length}" 
                                  : "$_filterStatus Rooms: ${filteredRooms.length}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(onPressed: _fetchaddRoomDialogue, icon: Icon(Icons.add), tooltip: "Add Room", color: Colors.blue[800])
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
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
                                ).then((_) => _fetchRooms());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getRoomColor(room.roomStatus),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showEditDialog(room);
                                              } else if (value == 'maintenance') {
                                                _requestMaintenance(room);
                                              }
                                            },
                                            itemBuilder: (BuildContext context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Update Status'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'maintenance',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.build, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Maintenance'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          room.roomStatus,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                          ),
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

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required String filterValue,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _filterStatus = _filterStatus == filterValue ? 'All' : filterValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: _filterStatus == filterValue 
                ? Border.all(color: Colors.white, width: 2) 
                : null,
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12, 
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$count",
                style: const TextStyle(
                  fontSize: 24, 
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Room room) {
    final TextEditingController roomNumberController = TextEditingController(text: room.roomNumber.toString());
    String selectedStatus = room.roomStatus;
    bool isUpdating = false;
    
    showDialog(
      context: context,
      barrierDismissible: !isUpdating,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
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
                          FocusScope.of(context).unfocus();
                          setDialogState(() {
                            isUpdating = true;
                          });

                          try {
                            final updatedRoom = await _roomRepository.updateRoomStatus(
                              room.id.toString(),
                              selectedStatus,
                            );
                            
                            setState(() {
                              final index = _allRooms.indexWhere(
                                (r) => r.id == room.id,
                              );
                              if (index != -1) {
                                _allRooms[index] = updatedRoom;
                              }
                            });
                            
                            Navigator.pop(context);
                            _showSnackBar("Room ${room.roomNumber} status updated to $selectedStatus!");
                          } catch (e) {
                            Navigator.pop(context);
                            _showSnackBar("Failed to update room: ${e.toString()}");
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

  void _requestMaintenance(Room room) {
    final TextEditingController issueController = TextEditingController();
    String selectedPriority = 'Medium';
    String selectedType = 'Other';
    File? selectedImage;
    
    final ImagePicker picker = ImagePicker();
    
    Future<void> pickImageFromCamera() async {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage = File(image.path);
      }
    }
    
    Future<void> pickImageFromGallery() async {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage = File(image.path);
      }
    }

    Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
      try {
        final response = await http.get(
          Uri.parse('${Constants.baseUrl}/api/maintenance/requests'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ',
          },
        ).timeout(const Duration(seconds: 30));

        print('GET MAINTENANCE REQUESTS - Status: ${response.statusCode}');
        print('GET MAINTENANCE REQUESTS - Body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => MaintenanceRequest.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load maintenance requests: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching maintenance requests: $e');
        throw Exception('Error fetching maintenance requests: ${e.toString()}');
      }
    }

// Get maintenance requests for a specific room
    Future<List<MaintenanceRequest>> getMaintenanceRequestsByRoom(int roomNumber) async {
      try {
        final response = await http.get(
          Uri.parse('${Constants.baseUrl}/api/maintenance/room/$roomNumber'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ',
          },
        ).timeout(const Duration(seconds: 30));

        print('GET MAINTENANCE REQUESTS BY ROOM - Status: ${response.statusCode}');
        print('GET MAINTENANCE REQUESTS BY ROOM - Body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => MaintenanceRequest.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load maintenance requests for room: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching maintenance requests by room: $e');
        throw Exception('Error fetching maintenance requests by room: ${e.toString()}');
      }
    }

// Get a single maintenance request by request number
    Future<MaintenanceRequest> getMaintenanceRequestByNumber(String requestNumber) async {
      try {
        final response = await http.get(
          Uri.parse('${Constants.baseUrl}/api/maintenance/request/$requestNumber'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer',
          },
        ).timeout(const Duration(seconds: 30));

        print('GET MAINTENANCE REQUEST BY NUMBER - Status: ${response.statusCode}');
        print('GET MAINTENANCE REQUEST BY NUMBER - Body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return MaintenanceRequest.fromJson(data);
        } else {
          throw Exception('Failed to load maintenance request: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching maintenance request: $e');
        throw Exception('Error fetching maintenance request: ${e.toString()}');
      }
    }

    Future<void> submitMaintenanceRequest() async {
      if (issueController.text.trim().isEmpty) {
        _showSnackBar("Please describe the issue");
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Constants.baseUrl}/api/maintenance/request'),
        );
        
        request.fields['roomNumber'] = room.roomNumber.toString();
        request.fields['issueDescription'] = issueController.text;
        request.fields['priority'] = selectedPriority;
        request.fields['type'] = selectedType;
        request.fields['requestedBy'] = 'Housekeeper';
        
      print("Submitting maintenance request for Room ${room.roomNumber} with issue: ${issueController.text}");

        if (selectedImage != null) {
          final stream = http.ByteStream(selectedImage!.openRead());
          final length = await selectedImage!.length();
          final multipartFile = http.MultipartFile(
            'images',
            stream,
            length,
            filename: path.basename(selectedImage!.path),
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        }
        
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          // Update room status locally
          setState(() {
            final index = _allRooms.indexWhere((r) => r.id == room.id);
            if (index != -1) {
              _allRooms[index] = room.copyWith(roomStatus: 'MAINTENANCE');
            }
          });
          
          _showSnackBar("Maintenance requested for Room ${room.roomNumber}!");
          Navigator.pop(context); // Close dialog
        } else {
          throw Exception('Failed to submit request');
        }
      } catch (e) {
        _showSnackBar("Error: ${e.toString()}");
        print("Error submitting maintenance request: ${e.toString()}");
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
    
    showDialog(
      context: context,
      barrierDismissible: !_isSubmitting,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Request Maintenance"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Room ${room.roomNumber}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: issueController,
                      decoration: const InputDecoration(
                        labelText: "Issue Description *",
                        border: OutlineInputBorder(),
                        hintText: "e.g., AC not working, Leaking pipe",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
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
                        setDialogState(() {
                          selectedPriority = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
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
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Image picker section
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Attach Photo (Optional: must be less than 2MB size)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(height: 0),
                          
                          if (selectedImage != null)
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(selectedImage!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                        onPressed: () {
                                          setDialogState(() {
                                            selectedImage = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await pickImageFromCamera();
                                      setDialogState(() {});
                                    },
                                    icon: const Icon(Icons.camera_alt, size: 15),
                                    label: const Text("Camera"),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await pickImageFromGallery();
                                      setDialogState(() {});
                                    },
                                    icon: const Icon(Icons.photo_library, size: 15),
                                    label: const Text("Gallery"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (_isSubmitting)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : submitMaintenanceRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getRoomColor(String status) {
    switch (status.toUpperCase()) {
      case 'CLEAN':
        return Colors.green;
      case 'DIRTY':
        return Colors.red;
      case 'OCCUPIED':
        return Colors.blue;
      case 'MAINTENANCE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _fetchaddRoomDialogue() {
    final TextEditingController roomNumberController = TextEditingController();
    final TextEditingController roomTypeController = TextEditingController();
    final TextEditingController roomCapacityController = TextEditingController();
    final TextEditingController roomPriceController = TextEditingController();
    String selectedStatus = 'AVAILABLE';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Room'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextField(
                      controller: roomNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Room Number',
                        hintText: 'e.g 101',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isSubmitting,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter room number';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: roomTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Room Type',
                        hintText: '',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bed),
                      ),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: roomCapacityController,
                      decoration: const InputDecoration(
                        labelText: 'Room Capacity',
                        hintText: '',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: roomPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Room Price',
                        hintText: '',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Room Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
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
                      },
                    ),
                    if (isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    // Validate fields
                    if (roomNumberController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter room number')),
                      );
                      return;
                    }
                    if (roomTypeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter room type')),
                      );
                      return;
                    }
                    if (roomCapacityController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter room capacity')),
                      );
                      return;
                    }
                    if (roomPriceController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter room price')),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSubmitting = true;
                    });

                    try {
                      final Map<String, dynamic> roomData = {
                        'roomNumber': roomNumberController.text.trim(),
                        'roomType': roomTypeController.text.trim(),
                        'roomCapacity': roomCapacityController.text.trim(),
                        'roomPrice': double.parse(roomPriceController.text.trim()),
                        'roomStatus': selectedStatus,
                      };

                      final newRoom = await _roomRepository.createRoom(roomData);

                      setState(() {
                        _allRooms.add(newRoom);
                      });

                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Room ${newRoom.roomNumber} created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        isSubmitting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create room: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Room'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}