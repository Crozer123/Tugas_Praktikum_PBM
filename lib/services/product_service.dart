import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';

class ProductService {
  final storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://task.itprojects.web.id/api';

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<List<Product>> getProducts() async {
    final token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List list = data['data'] is List
          ? data['data']
          : (data['data']?['products'] ?? data['products'] ?? []);
      return list.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> addProduct(String name, int price, String description) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteProduct(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> submitTugas(Product product, String githubUrl) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/products/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'github_url': githubUrl,
      }),
    );
    return response.statusCode == 200;
  }
}
