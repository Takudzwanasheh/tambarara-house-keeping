import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/auth/screen/login.dart';
import 'package:tambarara_house_keeping/features/housekeeping/screen/NotificationsScreen.dart';
import 'package:tambarara_house_keeping/features/housekeeping/widgets/table.dart';
import 'package:tambarara_house_keeping/features/rooms/model/room-model.dart';
import 'package:tambarara_house_keeping/features/rooms/screen/rooms.dart';
import 'package:tambarara_house_keeping/features/staff/screen/staff-members.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAdmin;
  const DashboardScreen({super.key, this.isAdmin = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      bottomNavigationBar: widget.isAdmin
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

  Widget _buildBody(BuildContext context) {
    if (!widget.isAdmin) {
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
          appBar: AppBar(title: const Text("Inventory Supplies"), backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: AdminTable(),
          ),
        );
      default:
        return _buildDashboardHome(context);
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[800],
      centerTitle: false,
      title: const Text(
        "TAMBARARA",
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white),
      ),
      actions: [
        if (widget.isAdmin)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
                icon: const Icon(Icons.notifications_none_rounded),
                color: Colors.white,
              ),
              Positioned(
                right: 12,
                top: 12,
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
                    '3',
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
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[800]),
            accountName: Text(widget.isAdmin ? "Admin User" : "Staff Member", style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(widget.isAdmin ? "admin@tambarara.co.zw" : "staff@tambarara.co.zw"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.hotel, color: Colors.blue, size: 40),
            ),
          ),
          if (widget.isAdmin) ...[
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
          ] else ...[
            _buildDrawerItem(Icons.meeting_room_rounded, "Rooms Status", () {
              Navigator.pop(context);
            }, isSelected: true),
          ],
          const Divider(),
          _buildDrawerItem(Icons.logout_rounded, "Logout", () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDashboardHome(BuildContext context) {
    final int cleanedRooms = roomsList.where((room) => room.roomStatus == 'Available').length;
    final int dirtyRooms = roomsList.where((room) => room.roomStatus == 'NotReady' || room.roomStatus == 'Cleaning').length;
    final int occupiedRoomsCount = roomsList.where((room) => room.roomStatus == 'Occupied').length;
    final int maintenanceRooms = roomsList.where((room) => room.roomStatus == 'Maintenance').length;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back,",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Text(
              "Supervisor Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
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
                  "Cleaned",
                  cleanedRooms.toString(),
                  Icons.check_circle_rounded,
                  Colors.green,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
                _buildStatCard(
                  "Dirty",
                  dirtyRooms.toString(),
                  Icons.warning_rounded,
                  Colors.orange,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
                _buildStatCard(
                  "Occupied",
                  occupiedRoomsCount.toString(),
                  Icons.person_pin_rounded,
                  Colors.blue,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
                _buildStatCard(
                  "Maintenance",
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
            const Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(0.0),
                child: AdminTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
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
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 28),
              ],
            ),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isSelected = false}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue[800] : Colors.grey[700]),
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
