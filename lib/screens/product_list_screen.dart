import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:myfoodwise_app/services/storage_service.dart';
import 'package:myfoodwise_app/screens/product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> products;

  // Constructor to initialize ProductListScreen with a title and list of products
  ProductListScreen({super.key, required this.title, required this.products});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy'); // Date format for parsing and formatting dates
  final StorageService _storageService = StorageService(); // Storage service instance
  late TextEditingController _searchController; // Controller for the search input
  List<Map<String, dynamic>> _filteredProducts = []; // List to hold filtered products

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(); // Initialize search controller
    _filteredProducts = widget.products; // Initialize filtered products with the provided list
    _searchController.addListener(_filterProducts); // Add listener to filter products based on search input
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts); // Remove listener when disposing
    _searchController.dispose(); // Dispose of the search controller
    super.dispose();
  }

  // Filter products based on the search query
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.products.where((product) {
        final productName = product['name'].toLowerCase();
        final expiryDate = product['expiryDate'].toLowerCase();
        return productName.contains(query) || expiryDate.contains(query);
      }).toList();
    });
  }

  // Navigate to the product details screen
  void _navigateToProductDetails(int index, Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
          index: index,
          onSave: (updatedProduct) async {
            await _storageService.updateProduct(index, updatedProduct);
            setState(() {
              widget.products[index] = updatedProduct;
              _filterProducts(); // Refresh the filtered list
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with a search field
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Nunito'),
        ),
        backgroundColor: Colors.teal,
      ),
      // Body with a list view of products
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: product['imagePath'] != null && File(product['imagePath']).existsSync()
                    ? CircleAvatar(
                  backgroundImage: FileImage(File(product['imagePath'])),
                  radius: 30,
                )
                    : CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.food_bank, color: Colors.teal.shade700),
                ),
                title: Text(
                  product['name'],
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal.shade900,
                  ),
                ),
                subtitle: Text(
                  'Exp: ${product['expiryDate']}',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.teal.shade600,
                  ),
                ),
                trailing: Text(
                  'Qty: ${product['quantity']}',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.teal.shade800,
                  ),
                ),
                onTap: () => _navigateToProductDetails(index, product),
              ),
            );
          },
        ),
      ),
    );
  }
}
