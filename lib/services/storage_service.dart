import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class StorageService {
  static const String _productsKey = 'products';
  final DateFormat dateFormat = DateFormat('MM/dd/yyyy');

  Future<void> saveProduct(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList(_productsKey) ?? [];
    products.add(json.encode(product));
    await prefs.setStringList(_productsKey, products);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList(_productsKey) ?? [];
    return products.map((product) {
      final Map<String, dynamic> productMap = json.decode(product) as Map<String, dynamic>;
      // Ensure the category field is present
      if (!productMap.containsKey('category')) {
        productMap['category'] = 'Unknown'; // Default value for older entries without category
      }
      return productMap;
    }).toList();
  }

  Future<void> updateProduct(int index, Map<String, dynamic> updatedProduct) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList(_productsKey) ?? [];
    products[index] = json.encode(updatedProduct);
    await prefs.setStringList(_productsKey, products);
  }

  Future<void> deleteProduct(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList(_productsKey) ?? [];
    products.removeAt(index);
    await prefs.setStringList(_productsKey, products);
  }

  Future<int> getTotalItems() async {
    final products = await getProducts();
    return products.length;
  }

  Future<int> getExpiredItems() async {
    final products = await getProducts();
    final today = DateTime.now();
    return products.where((product) {
      final expiryDate = dateFormat.parse(product['expiryDate']);
      return expiryDate.isBefore(today);
    }).length;
  }

  Future<int> getExpiringSoonItems() async {
    final products = await getProducts();
    final today = DateTime.now();
    final soon = today.add(Duration(days: 7));
    return products.where((product) {
      final expiryDate = dateFormat.parse(product['expiryDate']);
      return expiryDate.isAfter(today) && expiryDate.isBefore(soon);
    }).length;
  }

  Future<List<Map<String, dynamic>>> getExpiredProducts() async {
    final products = await getProducts();
    final today = DateTime.now();
    return products.where((product) {
      final expiryDate = dateFormat.parse(product['expiryDate']);
      return expiryDate.isBefore(today);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getExpiringSoonProducts() async {
    final products = await getProducts();
    final today = DateTime.now();
    final soon = today.add(Duration(days: 7));
    return products.where((product) {
      final expiryDate = dateFormat.parse(product['expiryDate']);
      return expiryDate.isAfter(today) && expiryDate.isBefore(soon);
    }).toList();
  }
}
