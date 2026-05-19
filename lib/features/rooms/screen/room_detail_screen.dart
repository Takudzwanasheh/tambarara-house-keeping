import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/data/models/room.dart';
import 'package:tambarara_house_keeping/data/repository/room_repository.dart';
import 'package:tambarara_house_keeping/features/housekeeping/controllers/dashboardController.dart';
import 'package:tambarara_house_keeping/features/housekeeping/model/inventorymodel.dart';
import 'package:tambarara_house_keeping/features/rooms/controller/roomController.dart';
import 'package:http/http.dart' as http;

import '../../../utils/contants.dart';
import '../model/ProductUsageModel.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Room _room;
  final RoomRepository _roomRepository = RoomRepository();
  final DashboardController _dashboardController = DashboardController();
  bool _isUpdating = false;
  bool _isLoading = false;
  late String _filterStatus;
  List<Room> _allRooms = [];

  // Cart items for POS system
  List<CartItem> _cartItems = [];
  List<Inventorymodel> _availableProducts = [];
  bool _isLoadingProducts = false;

  // Sample data - in real app, this would come from API
  Map<String, dynamic> _roomDetails = {};
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _filterStatus = 'All';
    _fetchRoomDetails();
    _loadProducts();
    _fetchProductUsageHistory();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });
    try {
      _availableProducts = await _dashboardController.fetchInventoryData();
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      setState(() {
        _isLoadingProducts = false;
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

  Future<void> _fetchRoomDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedRoom = await _roomRepository.getRoomById(_room.roomNumber.toString());
      setState(() {
        _room = updatedRoom;
      });

      final allRooms = await _roomRepository.fetchRooms();
      setState(() {
        _allRooms = allRooms;
      });

      _setSampleData();
      await _fetchRoomUsageHistory();
    } catch (e) {
      _setSampleData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRoomUsageHistory() async {
    try {
      // Fetch usage history for this room
      // This would call your API endpoint: /api/cleaning/room/{roomId}/usage
      // For now, we'll keep sample data
    } catch (e) {
      print("Error fetching usage history: $e");
    }
  }

  void _setSampleData() {
    _roomDetails = {
      'roomType': _room.roomType,
      'capacity': _room.roomCapacity,
      'rate': '\$${_room.roomPrice.toString()}/night',
    };
  }

  Future<void> _updateRoomStatus(  String newStatus) async {
     print('=== UPDATING ROOM STATUS ===');
    print('Room Number: ${_room.roomNumber}');
    print('New Status: $newStatus');
    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedRoom = await _roomRepository.updateRoomStatus(_room.id.toString(), newStatus);

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

  // ==================== POS SYSTEM METHODS ====================

  void _showProductUsageDialog() {
    _cartItems.clear();
    _showPOSDialog();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _showPOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Room ${_room.roomNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Two-column layout: Products on left, Cart on right
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Product List
                          Expanded(
                            flex: 1,
                            child: _buildProductList(context, setDialogState),
                          ),
                          const SizedBox(width: 16),

                          // Right: Shopping Cart
                          Expanded(
                            flex: 2,
                            child: _buildShoppingCart(context, setDialogState),
                          ),
                        ],
                      ),
                    ),

                    const Divider(),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _cartItems.isEmpty ? null : () => _submitUsage(context),
                          icon: const Icon(Icons.check),
                          label: const Text('Record Usage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductList(BuildContext context, StateSetter setDialogState) {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group products by category
    final Map<String, List<Inventorymodel>> groupedProducts = {};
    for (var product in _availableProducts) {
      if (!groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]!.add(product);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Products',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : groupedProducts.isEmpty
                  ? const Center(child: Text('No products available'))
                  : ListView(
                      children: groupedProducts.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.value.map((product) {
                                return _buildProductCard(product, setDialogState);
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Inventorymodel product, StateSetter setDialogState) {
    bool isLowStock = product.currentStock! <= product.reorderLevel!;
    bool isOutOfStock = product.currentStock! <= 0;

    return Container(
      width: 100,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: isOutOfStock
              ? null
              : () {
                  _addToCart(product);
                  setDialogState(() {});
                },
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Container(
              width: 140,
              height: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [

                  const SizedBox(height: 8),
                  Text(
                    product.productName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.currentStock?.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isLowStock ? Colors.orange : Colors.grey,
                      fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isOutOfStock)
                    const Chip(
                      label: Text('Out', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.red,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingCart(BuildContext context, StateSetter setDialogState) {
    double totalCost = _cartItems.fold(0, (sum, item) => sum + item.totalCost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Selection',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No items selected'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    _removeFromCart(index);
                                    setDialogState(() {});
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Qty:', style: TextStyle(fontSize: 12),),
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      _updateCartQuantity(index, item.quantity - 1);
                                      setDialogState(() {});
                                    }
                                  },
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () {
                                    _updateCartQuantity(index, item.quantity + 1);
                                    setDialogState(() {});
                                  },
                                ),
                                
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const Divider(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_cartItems.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addToCart(Inventorymodel product) {
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
      _cartItems[existingIndex].totalCost = 
          _cartItems[existingIndex].quantity * (product.unitPrice ?? 0);
    } else {
      _cartItems.add(CartItem(
        productId: product.id!,
        productName: product.productName,
        quantity: 1,
        unitPrice: product.unitPrice ?? 0,
        unit: product.unit ?? 'unit',
      ));
    }
    setState(() {});
  }

  void _removeFromCart(int index) {
    _cartItems.removeAt(index);
    setState(() {});
  }

  void _updateCartQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index].quantity = newQuantity;
      _cartItems[index].totalCost = _cartItems[index].quantity * _cartItems[index].unitPrice;
    }
    setState(() {});
  }

  Future<void> _submitUsage(BuildContext context) async {
    if (_cartItems.isEmpty) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Record each product usage
      for (var item in _cartItems) {
        await _dashboardController.recordProductUsage(
          roomNumber: _room.roomNumber,
          productId: item.productId,
          quantityUsed: item.quantity.toDouble(),
          cleanedBy: 'Housekeeper',
          notes: 'Cleaning supplies for Room ${_room.roomNumber}',
        );
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplies recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear cart and close dialog
        _cartItems.clear();
        Navigator.pop(context);

        // Refresh data
        await _loadProducts();
        await _fetchRoomDetails();
        await _fetchProductUsageHistory(); // Add this line to refresh product list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record supplies: ${e.toString()}'),
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

  IconData _getProductIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'detergent':
        return Icons.cleaning_services;
      case 'linen':
        return Icons.bed;
      case 'supplies':
        return Icons.inventory;
      default:
        return Icons.production_quantity_limits;
    }
  }

  void _showEditRoomDialog() {
    final TextEditingController roomNumberController = TextEditingController(text: _room.roomNumber.toString());
    final TextEditingController roomTypeController = TextEditingController(text: _room.roomType);
    final TextEditingController roomPriceController = TextEditingController(text: _room.roomNumber.toString());
    final TextEditingController roomCapacityController = TextEditingController(text: _room.roomCapacity);
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
                        DropdownMenuItem(value: 'AVAILABLE', child: Text('AVAILABLE')),
                        DropdownMenuItem(value: 'OCCUPIED', child: Text('OCCUPIED')),
                        DropdownMenuItem(value: 'CLEAN', child: Text('CLEAN')),
                        DropdownMenuItem(value: 'DIRTY', child: Text('DIRTY')),
                        DropdownMenuItem(value: 'MAINTENANCE', child: Text('MAINTENANCE')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStatus = value!;
                        });
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
                            final Map<String, dynamic> updatedData = {
                              'roomType': roomTypeController.text,
                              "roomNumber": roomNumberController.text,
                              "roomCapacity": roomCapacityController.text,
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

  Future<void> _deleteRoom() async {
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

    if (confirm != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _roomRepository.deleteRoom(_room.roomNumber.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
            onPressed: _showProductUsageDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Record Supplies Used',
          ),
          IconButton(
            onPressed: _showEditRoomDialog,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Room',
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

  // Add this list to store product usage history
  List<ProductUsage> _productUsageHistory = [];


  Future<void> _fetchProductUsageHistory() async {
    try {
      // Fetch usage history for this room from your API
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/cleaning/room/${_room.roomNumber}/usage'),
        headers: {'Accept': 'application/json'},
      );

      print('Product Usage Response Status: ${response.statusCode}');
      print('Product Usage Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _productUsageHistory = data.map((json) => ProductUsage.fromJson(json)).toList();
        });
      } else if (response.statusCode == 404) {
        // No usage history found
        setState(() {
          _productUsageHistory = [];
        });
      } else {
        throw Exception('Failed to load product usage history');
      }
    } catch (e) {
      print("Error fetching product usage: $e");
      setState(() {
        _productUsageHistory = [];
      });
    }
  }

  void _loadSampleProductUsage() {
    _productUsageHistory = [
      ProductUsage(
        productName: "Bleach",
        quantityUsed: 2,
        unit: "Liters",
        usedAt: DateTime.now().subtract(const Duration(days: 1)),
        totalCost: 5.00,
      ),
      ProductUsage(
        productName: "Towels",
        quantityUsed: 4,
        unit: "Pieces",
        usedAt: DateTime.now().subtract(const Duration(days: 1)),
        totalCost: 20.00,
      ),
      ProductUsage(
        productName: "Shampoo",
        quantityUsed: 2,
        unit: "Bottles",
        usedAt: DateTime.now().subtract(const Duration(days: 2)),
        totalCost: 4.00,
      ),
    ];
  }

// New method to build the products used section
  Widget _buildProductsUsedSection() {
    if (_productUsageHistory.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.inventory, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                "No products used yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _showProductUsageDialog,
                icon: const Icon(Icons.add),
                label: const Text("Record Product Usage"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Products Used",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: _showProductUsageDialog,
                  tooltip: "Record Usage",
                ),
              ],
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _productUsageHistory.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final usage = _productUsageHistory[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory, color: Colors.blue),
                  ),
                  title: Text(
                    usage.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: ${usage.quantityUsed} ${usage.unit}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Used: ${_formatDate(usage.usedAt)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${usage.totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Cost:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$${_getTotalCost().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getTotalCost() {
    return _productUsageHistory.fold(0.0, (sum, usage) => sum + usage.totalCost);
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
    if (_productUsageHistory.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Housekeeping Activity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "No housekeeping activities yet",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Housekeeping Activity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _productUsageHistory.length,
          itemBuilder: (context, index) {
            final usage = _productUsageHistory[index];
            return _buildActivityItem(usage);
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(ProductUsage usage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cleaning_services,
              size: 20,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ISSUED:  ${usage.productName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${usage.quantityUsed.toStringAsFixed(0)} ${usage.unit}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(usage.usedAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    if (usage.cleanedBy != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.person, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        usage.cleanedBy!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
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
            // icon: const Icon(Icons.cleaning_services),
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
            // icon: const Icon(Icons.warning),
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
            // icon: const Icon(Icons.build),
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

// Cart Item Model
class CartItem {
  int productId;
  String productName;
  int quantity;
  double unitPrice;
  String unit;
  double totalCost;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
  }) : totalCost = quantity * unitPrice;
}