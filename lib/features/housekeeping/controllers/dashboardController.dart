import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:tambarara_house_keeping/features/housekeeping/model/inventorymodel.dart';

import '../../../utils/contants.dart';
import 'package:http/http.dart'as http;

final baseUrl = Constants.baseUrl;

class DashboardController {
 
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