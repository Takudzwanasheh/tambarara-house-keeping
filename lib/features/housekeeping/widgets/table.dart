import 'package:flutter/material.dart';

class SupplyItem {
  final String itemName;
  final String category;
  final int stockLevel;
  final String unit;
  final String status;

  SupplyItem({
    required this.itemName,
    required this.category,
    required this.stockLevel,
    required this.unit,
    required this.status,
  });
}

class AdminTable extends StatefulWidget {
  const AdminTable({super.key});

  @override
  State<AdminTable> createState() => _AdminTableState();
}

class _AdminTableState extends State<AdminTable> {
  final List<SupplyItem> _allSupplies = [
    SupplyItem(itemName: 'Toilet Paper', category: 'Toiletries', stockLevel: 450, unit: 'Rolls', status: 'In Stock'),
    SupplyItem(itemName: 'Shampoo (30ml)', category: 'Toiletries', stockLevel: 120, unit: 'Bottles', status: 'Low Stock'),
    SupplyItem(itemName: 'Bed Sheets (King)', category: 'Linens', stockLevel: 85, unit: 'Pairs', status: 'In Stock'),
    SupplyItem(itemName: 'Floor Cleaner', category: 'Cleaning', stockLevel: 15, unit: 'Liters', status: 'In Stock'),
    SupplyItem(itemName: 'Bath Towels', category: 'Linens', stockLevel: 8, unit: 'Units', status: 'Out of Stock'),
    SupplyItem(itemName: 'Hand Soap', category: 'Toiletries', stockLevel: 200, unit: 'Refills', status: 'In Stock'),
    SupplyItem(itemName: 'Pillow Cases', category: 'Linens', stockLevel: 150, unit: 'Pairs', status: 'In Stock'),
    SupplyItem(itemName: 'Glass Cleaner', category: 'Cleaning', stockLevel: 5, unit: 'Liters', status: 'Low Stock'),
    SupplyItem(itemName: 'Toothbrush Kits', category: 'Toiletries', stockLevel: 60, unit: 'Kits', status: 'In Stock'),
    SupplyItem(itemName: 'Laundry Detergent', category: 'Cleaning', stockLevel: 40, unit: 'Kg', status: 'In Stock'),
    SupplyItem(itemName: 'Face Towels', category: 'Linens', stockLevel: 25, unit: 'Units', status: 'Low Stock'),
    SupplyItem(itemName: 'Trash Bags (Large)', category: 'Cleaning', stockLevel: 500, unit: 'Units', status: 'In Stock'),
    SupplyItem(itemName: 'Trash Bags (Small)', category: 'Cleaning', stockLevel: 0, unit: 'Units', status: 'Out of Stock'),
    SupplyItem(itemName: 'Conditioner (30ml)', category: 'Toiletries', stockLevel: 110, unit: 'Bottles', status: 'In Stock'),
    SupplyItem(itemName: 'Body Lotion', category: 'Toiletries', stockLevel: 95, unit: 'Bottles', status: 'In Stock'),
    SupplyItem(itemName: 'Slippers', category: 'Essentials', stockLevel: 40, unit: 'Pairs', status: 'Low Stock'),
    SupplyItem(itemName: 'Bath Mats', category: 'Linens', stockLevel: 30, unit: 'Units', status: 'In Stock'),
    SupplyItem(itemName: 'Bleach', category: 'Cleaning', stockLevel: 20, unit: 'Liters', status: 'In Stock'),
    SupplyItem(itemName: 'Room Freshener', category: 'Cleaning', stockLevel: 12, unit: 'Cans', status: 'Low Stock'),
    SupplyItem(itemName: 'Tea Bags (Mix)', category: 'F&B', stockLevel: 1000, unit: 'Units', status: 'In Stock'),
    SupplyItem(itemName: 'Coffee Sachets', category: 'F&B', stockLevel: 800, unit: 'Units', status: 'In Stock'),
    SupplyItem(itemName: 'Sugar Packets', category: 'F&B', stockLevel: 1200, unit: 'Units', status: 'In Stock'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Stock Level', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _allSupplies.map((item) => _buildDataRow(item)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(SupplyItem item) {
    return DataRow(
      cells: [
        DataCell(Text(item.itemName)),
        DataCell(Text(item.category)),
        DataCell(Text('${item.stockLevel} ${item.unit}')),
        DataCell(
          Text(
            item.status,
            style: TextStyle(
              color: _getStatusColor(item.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                onPressed: () => _showRestockDialog(item),
                tooltip: 'Restock',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
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

  void _showRestockDialog(SupplyItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${item.itemName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Level: ${item.stockLevel} ${item.unit}'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.itemName} restock request submitted')),
              );
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }
}
