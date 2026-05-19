class ProductUsage {
  final int? id;
  final String productName;
  final double quantityUsed;
  final String unit;
  final DateTime usedAt;
  final double totalCost;
  final String? cleanedBy;
  final int? roomId;
  final int? productId;

  ProductUsage({
    this.id,
    required this.productName,
    required this.quantityUsed,
    required this.unit,
    required this.usedAt,
    required this.totalCost,
    this.cleanedBy,
    this.roomId,
    this.productId,
  });

  factory ProductUsage.fromJson(Map<String, dynamic> json) {
    // Handle nested product object if present
    String productName = '';
    String unit = '';

    if (json['product'] != null) {
      productName = json['product']['productName'] ?? json['product']['product_name'] ?? '';
      unit = json['product']['unit'] ?? '';
    } else {
      productName = json['productName'] ?? json['product_name'] ?? '';
      unit = json['unit'] ?? '';
    }

    // Handle cleaned_by or cleanedBy
    String? cleanedBy = json['cleanedBy'] ?? json['cleaned_by'];
    if (cleanedBy == null && json['requestedBy'] != null) {
      cleanedBy = json['requestedBy'];
    }

    return ProductUsage(
      id: json['id'],
      productName: productName,
      quantityUsed: (json['quantityUsed'] ?? json['quantity_used'] ?? 0).toDouble(),
      unit: unit,
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'])
          : (json['usageDate'] != null
          ? DateTime.parse(json['usageDate'])
          : (json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now())),
      totalCost: (json['totalCost'] ?? json['total_cost'] ?? 0).toDouble(),
      cleanedBy: cleanedBy,
      roomId: json['roomId'] ?? json['room_id'],
      productId: json['productId'] ?? json['product_id'],
    );
  }
}