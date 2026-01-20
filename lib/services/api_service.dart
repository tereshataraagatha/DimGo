import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for Windows/Web
  String get baseUrl {
    if (kIsWeb) return 'http://localhost/dimgo_backend';
    if (Platform.isAndroid) return 'http://10.0.2.2/dimgo_backend';
    return 'http://localhost/dimgo_backend';
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_products.php'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard.php'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_product.php'),
        body: jsonEncode(productData),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> processTransaction(double total, List<Map<String, dynamic>> items) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaction.php'),
        body: jsonEncode({
          "total_amount": total,
          "items": items
        }),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
         var res = jsonDecode(response.body);
         return res['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_product.php'),
        body: jsonEncode(productData),
        headers: {"Content-Type": "application/json"},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_product.php'),
        body: jsonEncode({"id": id}),
        headers: {"Content-Type": "application/json"},
      );
      var body = jsonDecode(response.body);
      return response.statusCode == 200 && body['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_transactions.php'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
