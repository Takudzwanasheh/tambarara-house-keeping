import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/features/housekeeping/controllers/dashboardController.dart';
import 'package:tambarara_house_keeping/features/housekeeping/model/inventorymodel.dart';

class AdminTable extends StatefulWidget {
  const AdminTable({super.key});

  @override
  State<AdminTable> createState() => _AdminTableState();
}

class _AdminTableState extends State<AdminTable> {
  List<Inventorymodel> _inventoryItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getInventoryData();
  }

  Future<void> _getInventoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final items = await DashboardController().fetchInventoryData();
      print("INVENTORY ITEMS FETCHED: ${items.length} items");
      setState(() {
        _inventoryItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching inventory: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
            Text('Current Stock: ${item.currentStock?.toString() ?? '0'} ${item.unit ?? ''}'),
            Text('Reorder Level: ${item.reorderLevel?.toString() ?? '5'} ${item.unit ?? ''}'),
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

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Adding ${quantity.toStringAsFixed(0)} ${item.unit} to ${item.productName}...'),
                  ),
                );

                try {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully added ${quantity.toStringAsFixed(0)} ${item.unit} to ${item.productName}'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh inventory data
                  await _getInventoryData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add stock: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Inventorymodel item) {
    String stockStatus = _getStockStatus(item.currentStock, item.reorderLevel);

    return DataRow(
      cells: [
        DataCell(Text(item.productName)),
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
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
            onPressed: () => _showRestockDialog(item),
            tooltip: 'Restock',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading inventory...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getInventoryData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _inventoryItems.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.inventory, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No inventory items found'),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                    columns: const [
                      DataColumn(
                        label: Text('Item Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),

                      DataColumn(
                        label: Text('Stock',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: _inventoryItems.map((item) => _buildDataRow(item)).toList(),
                  ),
                ),
        ),
      ),
    );
  }
}