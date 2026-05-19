import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/auth/controller/authController.dart';
import 'package:tambarara_house_keeping/auth/screen/login.dart';
import 'package:tambarara_house_keeping/features/housekeeping/controllers/dashboardController.dart';
import 'package:tambarara_house_keeping/features/housekeeping/model/inventorymodel.dart';
import 'package:tambarara_house_keeping/features/housekeeping/screen/NotificationsScreen.dart';
import 'package:tambarara_house_keeping/features/housekeeping/widgets/table.dart';
import 'package:tambarara_house_keeping/features/rooms/controller/roomController.dart';
import 'package:tambarara_house_keeping/features/rooms/screen/rooms.dart';
import 'package:tambarara_house_keeping/features/staff/screen/staff-members.dart';
import 'package:tambarara_house_keeping/data/models/room.dart';
import 'package:tambarara_house_keeping/data/repository/room_repository.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAdmin;
  final String username;
  final String userRole;

  const DashboardScreen({
    super.key,
    this.isAdmin = false,
    this.username = '',
    this.userRole = 'staff',
  });
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;
  final AuthController _authController = AuthController();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // State for dashboard rooms
  List<Room> _dashboardRooms = [];
  List<Inventorymodel> _inventoryItems = [];
  bool _isDashboardLoading = true;
  String? _dashboardErrorMessage;
  final RoomRepository _roomRepository = RoomRepository();

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _loadUserData();
    _getInventoryData();
    _fetchDashboardRooms();
  }

  Future<void> _getInventoryData() async {
    try {
      _inventoryItems = await DashboardController().fetchInventoryData();
      print("INVENTORY ITEMS FETCHED: ${_inventoryItems.length} items");
      setState(() {});
    } catch (e) {
      print("Error fetching inventory: $e");
    }
  }

  Future<void> _loadUserData() async {
    final userData = await _authController.getCurrentUser();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _fetchDashboardRooms() async {
    setState(() {
      _isDashboardLoading = true;
      _dashboardErrorMessage = null;
    });
    try {
      _dashboardRooms = await _roomRepository.fetchRooms();
      print("DASHBOARD ROOMS FETCHED: ${_dashboardRooms.length} rooms");
    } catch (e) {
      _dashboardErrorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error fetching dashboard rooms: $_dashboardErrorMessage');
    } finally {
      setState(() {
        _isDashboardLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authController.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final displayName = widget.username.isNotEmpty
        ? widget.username
        : (_userData?['username'] ?? 'USER');
    final isAdmin = widget.isAdmin || (_userData?['isAdmin'] ?? false);
    final role = widget.userRole.isNotEmpty
        ? widget.userRole
        : (_userData?['role'] ?? 'USER');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, displayName, isAdmin),
      drawer: _buildDrawer(context, isAdmin, displayName, role),
      body: _buildBody(context, isAdmin),
      bottomNavigationBar: isAdmin
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue[800],
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.meeting_room_rounded),
                  label: 'Rooms',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_rounded),
                  label: 'Staff',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: 'Inventory',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, bool isAdmin) {
    if (!isAdmin) {
      return const RoomsScreen();
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome(context);
      case 1:
        return const RoomsScreen();
      case 2:
        return const StaffMembers();
      case 3:
        return Scaffold(
          appBar: AppBar(
            title: const Text("Inventory Supplies"),
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            actions: [
              IconButton(onPressed: (){}, icon: Icon(Icons.add))
            ],
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: AdminTable(),
          ),
        );
      default:
        return _buildDashboardHome(context);
    }
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String username, bool isAdmin) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[800],
      centerTitle: false,
      title: const Text(
        "TAMBARARA",
        style: TextStyle(
          fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Colors.white),
      ),
      actions: [
        if (isAdmin)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                },
                icon: const Icon(Icons.notifications_none_rounded),
                color: Colors.white,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue[800]!, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    "3",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(
      BuildContext context, bool isAdmin, String username, String role) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[800]!, Colors.blue[600]!],
              ),
            ),
            accountName: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              isAdmin ? "Administrator" : "Staff Member",
              style: const TextStyle(fontSize: 12),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (isAdmin) ...[
            _buildDrawerItem(Icons.dashboard_rounded, "Dashboard", () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            }, isSelected: _selectedIndex == 0),
            _buildDrawerItem(Icons.meeting_room_rounded, "Rooms Status", () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
            }, isSelected: _selectedIndex == 1),
            _buildDrawerItem(Icons.people_alt_rounded, "Staff Members", () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            }, isSelected: _selectedIndex == 2),
            _buildDrawerItem(Icons.inventory_2_rounded, "Inventory", () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
            }, isSelected: _selectedIndex == 3),

            _buildDrawerItem(Icons.meeting_room_rounded, "Place Order", () {
              Navigator.pop(context);
            }, isSelected: true),
          ] else ...[
            _buildDrawerItem(Icons.meeting_room_rounded, "Rooms Status", () {
              Navigator.pop(context);
            }, isSelected: true),

            _buildDrawerItem(Icons.meeting_room_rounded, "Place Order", () {
              Navigator.pop(context);
            }, isSelected: true),
          ],
          const Divider(),
          _buildDrawerItem(Icons.logout_rounded, "Logout", _handleLogout),
        ],
      ),
    );
  }

  Widget _buildDashboardHome(BuildContext context) {
    if (_isDashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboardErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_dashboardErrorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDashboardRooms,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final int cleanedRooms =
        _dashboardRooms.where((room) => room.roomStatus == 'CLEAN').length;
    final int dirtyRooms = _dashboardRooms
        .where((room) =>
            room.roomStatus == 'NotReady' || room.roomStatus == 'DIRTY')
        .length;
    final int occupiedRoomsCount =
        _dashboardRooms.where((room) => room.roomStatus == 'OCCUPIED').length;
    final int maintenanceRooms = _dashboardRooms
        .where((room) => room.roomStatus == 'MAINTENANCE')
        .length;

    return RefreshIndicator(
      onRefresh: _fetchDashboardRooms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                widget.username.isNotEmpty ? widget.username : "Supervisor",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    "CLEAN",
                    cleanedRooms.toString(),
                    Icons.check_circle_rounded,
                    Colors.green,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                    },
                  ),
                  _buildStatCard(
                    "DIRTY",
                    dirtyRooms.toString(),
                    Icons.warning_rounded,
                    Colors.orange,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                    },
                  ),
                  _buildStatCard(
                    "OCCUPIED",
                    occupiedRoomsCount.toString(),
                    Icons.person_pin_rounded,
                    Colors.blue,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                    },
                  ),
                  _buildStatCard(
                    "MAINTENANCE",
                    maintenanceRooms.toString(),
                    Icons.build_rounded,
                    Colors.red,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Inventory Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedIndex = 3);
                    },
                    child: const Text("View All"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _inventoryItems.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No inventory items found'),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowColor:
                                MaterialStateProperty.all(Colors.grey[100]),
                            columns: const [
                              DataColumn(
                                label: Text('Item Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              // DataColumn(
                              //   label: Text('Category',
                              //       style: TextStyle(
                              //           fontWeight: FontWeight.bold)),
                              // ),
                              DataColumn(
                                label: Text('Stock',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('Status',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('Actions',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                            rows: _inventoryItems
                                .map((item) => _buildDataRow(item))
                                .toList(),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FIXED METHODS ====================

  DataRow _buildDataRow(Inventorymodel item) {
    // Determine stock status based on currentStock
    String stockStatus = _getStockStatus(item.currentStock as double?, item.reorderLevel as double?);

    return DataRow(
      cells: [
        DataCell(Text(item.productName)),
        // DataCell(Text(item.category)),
        DataCell(Text('${item.currentStock?.toString() ?? '0'} ${item.unit ?? ''}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(stockStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stockStatus,
              style: TextStyle(
                color: _getStatusColor(stockStatus),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.blue, size: 20),
                onPressed: () => _showRestockDialog(item),
                tooltip: 'Restock',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to determine stock status
  String _getStockStatus(double? currentStock, double? reorderLevel) {
    if (currentStock == null) return 'Unknown';
    if (currentStock <= 0) return 'Out of Stock';
    if (reorderLevel != null && currentStock <= reorderLevel) return 'Low Stock';
    return 'In Stock';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Stock':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Out of Stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showRestockDialog(Inventorymodel item) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${item.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Current Stock: ${item.currentStock?.toString() ?? '0'} ${item.unit ?? ''}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity to add',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                Navigator.pop(context);

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Adding ${quantity.toStringAsFixed(0)} ${item.unit} to ${item.productName}...')),
                );

                try {
                  // TODO: Call API to add stock
                  // await DashboardController().addStock(item.id, quantity);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Successfully added ${quantity.toStringAsFixed(0)} ${item.unit} to ${item.productName}'),
                        backgroundColor: Colors.green),
                  );

                  // Refresh inventory data
                  await _getInventoryData();
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to add stock: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid quantity'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 28),
              ],
            ),
            Text(title,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {bool isSelected = false}) {
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? Colors.blue[800] : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue[800] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}