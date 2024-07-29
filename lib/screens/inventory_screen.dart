import 'package:flutter/material.dart';
import 'package:myfoodwise_app/services/storage_service.dart';
import 'package:myfoodwise_app/screens/add_product_screen.dart';
import 'package:myfoodwise_app/screens/product_details_screen.dart';
import 'dart:io';

class InventoryScreen extends StatefulWidget {
  final Function refreshHomeScreen;

  // Constructor to initialize InventoryScreen with a function to refresh the home screen
  const InventoryScreen({super.key, required this.refreshHomeScreen});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final StorageService _storageService = StorageService(); // Storage service instance
  List<Map<String, dynamic>> _products = []; // List to hold all products
  List<Map<String, dynamic>> _filteredProducts = []; // List to hold filtered products
  late TextEditingController _searchController; // Controller for the search input

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(); // Initialize search controller
    _loadProducts(); // Load products from storage
    _searchController.addListener(_filterProducts); // Add listener to filter products based on search input
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts); // Remove listener when disposing
    _searchController.dispose(); // Dispose of the search controller
    super.dispose();
  }

  // Load products from storage and update the state
  void _loadProducts() async {
    _products = await _storageService.getProducts();
    _filteredProducts = _products;
    setState(() {}); // Update the state with the loaded products
  }

  // Filter products based on the search query
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final productName = product['name'].toLowerCase();
        final expiryDate = product['expiryDate'].toLowerCase();
        return productName.contains(query) || expiryDate.contains(query);
      }).toList();
    });
  }

  // Show a confirmation dialog before deleting a product
  void _confirmDelete(int index) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _deleteProduct(index);
    }
  }

  // Delete a product from the storage
  Future<void> _deleteProduct(int index) async {
    await _storageService.deleteProduct(index);
    widget.refreshHomeScreen(); // Refresh the home screen
    _loadProducts(); // Reload the products
  }

  // Navigate to the add/edit product screen
  void _editProduct(int index, Map<String, dynamic> product) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          product: product,
          onSave: (updatedProduct) async {
            await _storageService.updateProduct(index, updatedProduct);
            widget.refreshHomeScreen(); // Refresh the home screen
            _loadProducts(); // Reload the products
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
            Map<String, dynamic> product = _filteredProducts[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: _buildLeading(product), // Leading widget for product image or icon
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.teal.shade700),
                      onPressed: () => _editProduct(index, product), // Edit product
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade700),
                      onPressed: () => _confirmDelete(index), // Confirm delete product
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(
                        product: product,
                        index: index,
                        onSave: (updatedProduct) async {
                          await _storageService.updateProduct(index, updatedProduct);
                          widget.refreshHomeScreen(); // Refresh the home screen
                          _loadProducts(); // Reload the products
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      // Floating action button to add a new product
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(onSave: (product) async {
                await _storageService.saveProduct(product);
                widget.refreshHomeScreen(); // Refresh the home screen
                _loadProducts(); // Reload the products
              }),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build the leading widget for the product list tile
  Widget _buildLeading(Map<String, dynamic> product) {
    if (product['imagePath'] != null && File(product['imagePath']).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(product['imagePath'])),
        radius: 30,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.teal.shade100,
        child: Icon(Icons.food_bank, color: Colors.teal.shade700),
      );
    }
  }
}
