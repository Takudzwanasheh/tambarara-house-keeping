import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:tambarara_house_keeping/features/housekeeping/model/inventorymodel.dart';

import '../../../utils/contants.dart';
import 'package:http/http.dart'as http;

final baseUrl = Constants.baseUrl;

class DashboardController {


Future<Map<String, dynamic>> recordProductUsage({
  required int? roomNumber,  // Changed from roomId to roomNumber for clarity
  required int productId,
  required double quantityUsed,
  required String cleanedBy,
  required String notes,
}) async {
  try {
    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/api/cleaning/use-product').replace(
      queryParameters: {
        'roomNumber': roomNumber?.toString() ?? '',  
        'productId': productId.toString(),
        'quantityUsed': quantityUsed.toString(),
        'cleanedBy': cleanedBy,
        'notes': notes,
      },
    );
    
    print('REQUEST URL: $uri');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Product usage recorded successfully');
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to record product usage: ${response.statusCode}');
    }
  } catch (e) {
    print('Error recording product usage: $e');
    throw Exception('Error recording product usage: $e');
  }
}

//add inventory
  Future<Inventorymodel> createProduct(Inventorymodel product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      ).timeout(const Duration(seconds: 60));

      print("CREATE PRODUCT RESPONSE: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("PRODUCT CREATED SUCCESSFULLY: $responseData");
        return Inventorymodel.fromJson(responseData);
      } else {
        String errorMessage = 'Failed to create product. Status code: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON or message key is missing
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection or server is unreachable.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

Future<List<Inventorymodel>> fetchInventoryData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 60));

       print("FETCH INVENTORY RESPONSE: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> inventoryJsonList = jsonDecode(response.body);
        print(" INVENTORY ITEMS AVAILABLE , $inventoryJsonList");
        return inventoryJsonList.map((json) => Inventorymodel.fromJson(json)).toList();
      } else {
        String errorMessage = 'Failed to load inventory items. Status code: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON or message key is missing
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection or server is unreachable.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

}