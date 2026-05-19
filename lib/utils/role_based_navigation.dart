import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/auth/controller/authController.dart';
import 'package:tambarara_house_keeping/features/rooms/screen/rooms.dart';
import 'package:tambarara_house_keeping/features/staff/screen/staff-members.dart';

import '../features/housekeeping/screen/DashboadrdScreen.dart';

class RoleBasedNavigation extends StatelessWidget {
  const RoleBasedNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthController().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        final role = user?['role'] ?? 'USER';

        // Navigate to different screens based on role
        switch (role) {
          case 'ADMIN':
            return const DashboardScreen(isAdmin: true);
          case 'STAFF':
            return const StaffDashboard();
          case 'USER':
            return const UserDashboard();
          default:
            return const DashboardScreen(isAdmin: false);
        }
      },
    );
  }
}

// Staff Dashboard - Limited access
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StaffHomeScreen(),
    const RoomsScreen(),
  ];

  final List<String> _titles = [
    'Staff Dashboard',
    'Rooms',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Rooms',
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await AuthController().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}

// User Dashboard - Very limited access
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const UserHomeScreen(),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await AuthController().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}

// Staff Home Screen
class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthController().getCurrentUser(),
      builder: (context, snapshot) {
        final username = snapshot.data?['username'] ?? 'Staff';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome back, $username!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have limited access. Please contact admin for more features.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildMenuCard(
                    context,
                    'View Rooms',
                    Icons.meeting_room,
                    Colors.blue,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RoomsScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'My Tasks',
                    Icons.assignment,
                    Colors.green,
                        () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// User Home Screen - Very limited
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthController().getCurrentUser(),
      builder: (context, snapshot) {
        final username = snapshot.data?['username'] ?? 'User';

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  'Welcome, $username!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You do not have permission to access the system.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await AuthController().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}