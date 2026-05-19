import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../utils/contants.dart';
import "package:http/http.dart" as http;
import '../../rooms/model/MaintenanceRequest Model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<MaintenanceRequest> _maintenanceRequests = [];
  List<MaintenanceRequest> _filteredRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Sorting and filtering
  String _selectedSortBy = 'Newest First';
  String _selectedStatusFilter = 'All';

  final List<String> _sortOptions = [
    'Newest First',
    'Oldest First',
    'Priority: High to Low',
    'Priority: Low to High',
    'Room Number',
  ];

  final List<String> _statusOptions = [
    'All',
    'PENDING',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceRequests();
  }

  Future<void> _fetchMaintenanceRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/maintenance/all'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _maintenanceRequests = data.map((json) => MaintenanceRequest.fromJson(json)).toList();
          _applyFiltersAndSort();
          _isLoading = false;
          print("MAINTENANCE BODY ${response.body}");
        });
      } else {
        throw Exception('Failed to load maintenance requests');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    List<MaintenanceRequest> filtered = List.from(_maintenanceRequests);

    // Apply status filter
    if (_selectedStatusFilter != 'All') {
      filtered = filtered.where((r) => r.status == _selectedStatusFilter).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_selectedSortBy) {
        case 'Newest First':
          return b.requestedAt.compareTo(a.requestedAt);
        case 'Oldest First':
          return a.requestedAt.compareTo(b.requestedAt);
        case 'Priority: High to Low':
          return _getPriorityValue(b.priority).compareTo(_getPriorityValue(a.priority));
        case 'Priority: Low to High':
          return _getPriorityValue(a.priority).compareTo(_getPriorityValue(b.priority));
        case 'Room Number':
          return a.roomNumber.compareTo(b.roomNumber);
        default:
          return b.requestedAt.compareTo(a.requestedAt);
      }
    });

    setState(() {
      _filteredRequests = filtered;
    });
  }

  int _getPriorityValue(String priority) {
    switch (priority.toUpperCase()) {
      case 'EMERGENCY':
        return 5;
      case 'HIGH':
        return 4;
      case 'MEDIUM':
        return 3;
      case 'LOW':
        return 2;
      default:
        return 1;
    }
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'EMERGENCY':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.blue;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toUpperCase()) {
      case 'EMERGENCY':
        return Icons.warning_rounded;
      case 'HIGH':
        return Icons.trending_up_rounded;
      case 'MEDIUM':
        return Icons.trending_flat_rounded;
      case 'LOW':
        return Icons.trending_down_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  void _showFilterSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: SizedBox(
                      width: 40,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort By',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _sortOptions.map((option) {
                      return FilterChip(
                        label: Text(option),
                        selected: _selectedSortBy == option,
                        onSelected: (selected) {
                          setSheetState(() {
                            _selectedSortBy = option;
                          });
                          _applyFiltersAndSort();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter by Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _statusOptions.map((status) {
                      return FilterChip(
                        label: Text(status),
                        selected: _selectedStatusFilter == status,
                        onSelected: (selected) {
                          setSheetState(() {
                            _selectedStatusFilter = selected ? status : 'All';
                          });
                          _applyFiltersAndSort();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredRequests.isEmpty && !_isLoading
        ? _maintenanceRequests
        : _filteredRequests;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Maintenance Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortDialog,
            tooltip: 'Filter & Sort',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMaintenanceRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading maintenance requests...'),
          ],
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMaintenanceRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : displayList.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_circle_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No maintenance requests found'),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchMaintenanceRequests,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: displayList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = displayList[index];
            return _buildRequestCard(request);
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(MaintenanceRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showRequestDetails(request);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with room number and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Room ${request.roomNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.status,
                        style: TextStyle(
                          color: _getStatusColor(request.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Room type badge
                Row(
                  children: [
                    const Icon(Icons.bed, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.roomType,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Issue description
                Text(
                  request.issueDescription,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Priority badge and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(request.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPriorityIcon(request.priority),
                            size: 14,
                            color: _getPriorityColor(request.priority),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.priority,
                            style: TextStyle(
                              color: _getPriorityColor(request.priority),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(request.requestedAt),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(MaintenanceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Request for Room ${request.roomNumber}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.meeting_room, 'Room Number', request.roomNumber.toString()),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.bed, 'Room Type', request.roomType),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.priority_high, 'Priority', request.priority),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.person_outline, 'Requested By', request.requestedBy),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.calendar_today, 'Requested At', _formatDate(request.requestedAt)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Issue Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (request.notes != null && request.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Additional Notes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(request.notes!),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ],
    );
  }
}