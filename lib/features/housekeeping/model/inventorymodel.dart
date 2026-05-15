// lib/data/models/room.dart
import 'package:flutter/material.dart';

class Inventorymodel {
  final int? id;
  final String productName;
  final double reorderLevel;
  final double currentStock;
  final String category;
  final String unit;
  final double? unitPrice;
  final String? createdAt;
  final String? updatedAt;

  Inventorymodel({
    this.id,
    required this.productName,
    required this.reorderLevel,
    required this.currentStock,
    required this.category,
    required this.unit,
    this.unitPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Inventorymodel.fromJson(Map<String, dynamic> json) {
    return Inventorymodel(
      id: json['id'],
      productName: json['productName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      reorderLevel: (json['reorderLevel'] ?? 0).toDouble(),
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      unit: json['unit']?.toString() ?? 'units',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'reorderLevel': reorderLevel,
      'currentStock': currentStock,
      'unit': unit,
      'unitPrice': unitPrice,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to check stock status
  String get stockStatus {
    if (currentStock <= 0) return 'Out of Stock';
    if (currentStock <= reorderLevel) return 'Low Stock';
    return 'In Stock';
  }

  // Helper method to get status color
  Color get statusColor {
    switch (stockStatus) {
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

  // CopyWith method for updating local state
  Inventorymodel copyWith({
    int? id,
    String? productName,
    double? reorderLevel,
    double? currentStock,
    String? category,
    String? unit,
    double? unitPrice,
    String? createdAt,
    String? updatedAt,
  }) {
    return Inventorymodel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      currentStock: currentStock ?? this.currentStock,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Inventorymodel(id: $id, productName: $productName, currentStock: $currentStock, category: $category)';
  }
}