import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/features/rooms/model/room-model.dart';

class RoomDetailScreen extends StatelessWidget {
  final DummyRooms room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room ${room.roomNumber} Details"),
        backgroundColor: _getRoomColor(room.roomStatus),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildInfoSection(context),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
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
        color: _getRoomColor(room.roomStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRoomColor(room.roomStatus), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(room.roomStatus),
            size: 64,
            color: _getRoomColor(room.roomStatus),
          ),
          const SizedBox(height: 12),
          Text(
            room.roomStatus.toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getRoomColor(room.roomStatus),
            ),
          ),
          const Text(
            "Current Status",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
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
            _buildInfoRow(Icons.king_bed, "Room Type", "Deluxe Suite"),
            _buildInfoRow(Icons.people, "Capacity", "2 Adults, 1 Child"),
            _buildInfoRow(Icons.room, "Floor", "1st Floor"),
            _buildInfoRow(Icons.attach_money, "Rate", "\$120 / night"),
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
        _buildActivityItem("Cleaning Completed", "Today, 10:30 AM", "by Sarah J."),
        _buildActivityItem("Maintenance Check", "Yesterday, 04:15 PM", "by Mike R."),
        _buildActivityItem("Linens Changed", "2 days ago", "by Sarah J."),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("$time • $user", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.cleaning_services),
            label: const Text("Clean"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.build),
            label: const Text("Repair"),
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
    switch (status) {
      case 'Available': return Colors.green;
      case 'NotReady': return Colors.orange;
      case 'Occupied': return Colors.red;
      case 'Maintenance': return Colors.purple;
      case 'Cleaning': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Available': return Icons.check_circle;
      case 'NotReady': return Icons.warning;
      case 'Occupied': return Icons.person;
      case 'Maintenance': return Icons.build;
      case 'Cleaning': return Icons.cleaning_services;
      default: return Icons.help;
    }
  }
}
