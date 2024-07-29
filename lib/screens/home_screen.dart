import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myfoodwise_app/screens/add_product_screen.dart';
import 'package:myfoodwise_app/screens/inventory_screen.dart';
import 'package:myfoodwise_app/screens/product_list_screen.dart';
import 'package:myfoodwise_app/screens/scan_product.dart';
import 'package:myfoodwise_app/screens/settings_screen.dart';
import 'package:myfoodwise_app/services/storage_service.dart';
import 'package:myfoodwise_app/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final NotificationService notificationService;

  // Constructor to initialize the HomeScreen with a notification service
  HomeScreen({required this.notificationService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService(); // Storage service instance
  int _totalItems = 0; // Total items count
  int _expiredItems = 0; // Expired items count
  int _expiringSoonItems = 0; // Expiring soon items count

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when the screen is initialized
  }

  // Load data from storage service
  void _loadData() async {
    _totalItems = await _storageService.getTotalItems();
    _expiredItems = await _storageService.getExpiredItems();
    _expiringSoonItems = await _storageService.getExpiringSoonItems();
    setState(() {}); // Update the state with new data
  }

  // Navigate to the product list screen with the given title and fetch function
  void _navigateToProductList(String title, Future<List<Map<String, dynamic>>> Function() fetchProducts) async {
    final products = await fetchProducts();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(title: title, products: products),
      ),
    );
  }

  // Navigate to the add product screen with the given category
  void _navigateToAddProduct(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(category: category),
      ),
    );
    _loadData(); // Refresh data after adding a new product
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and settings button
      appBar: AppBar(
        title: const Text('Fresh Flux'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // Main body with a scroll view and padding to avoid FAB overlap
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row of summary cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToProductList('All Items', _storageService.getProducts),
                    child: _buildSummaryCard('Items added', '$_totalItems', Colors.blue),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToProductList('Expired Items', _storageService.getExpiredProducts),
                    child: _buildSummaryCard('Expired', '$_expiredItems', Colors.red),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToProductList('Expiring Soon', _storageService.getExpiringSoonProducts),
                    child: _buildSummaryCard('Expiring soon', '$_expiringSoonItems', Colors.orange),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Section title for adding items
              Text('Add items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              // Horizontal list of category cards
              Container(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryCard('Canned', 'Beans, Tuna, etc', 'assets/img.png', Colors.teal, 'Canned Product'),
                    _buildCategoryCard('Medicine', 'Pills, vitamins etc', 'assets/medicine.png', Colors.green, 'Medicine'),
                    _buildCategoryCard('Dairy', 'Eggs, milk etc', 'assets/dd.png', Colors.blue, 'Dairy Product'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Section title for shortcuts
              Text('Shortcuts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              // List of shortcut cards
              _buildShortcutCard('Scan a product', Icons.qr_code, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BarcodeScannerScreen()),
                );
              }, Colors.purple),
              _buildShortcutCard('View inventory', Icons.inventory, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryScreen(refreshHomeScreen: _loadData),
                  ),
                );
              }, Colors.blue),
              _buildShortcutCard('Settings', Icons.settings, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              }, Colors.green),
            ],
          ),
        ),
      ),
      // Floating action button to add a new product
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen()));
          _loadData(); // Refresh data after adding a new product
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Build a summary card with the given title, count, and color
  Widget _buildSummaryCard(String title, String count, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 5),
            Text(title, style: TextStyle(color: color, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Build a category card with the given title, subtitle, image path, color, and category
  Widget _buildCategoryCard(String title, String subtitle, String imagePath, Color color, String category) {
    return GestureDetector(
      onTap: () => _navigateToAddProduct(category),
      child: Container(
        width: 160,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(imagePath, height: 100, fit: BoxFit.cover),
              ),
              SizedBox(height: 5),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(subtitle, style: TextStyle(color: color, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // Build a shortcut card with the given title, icon, onTap function, and color
  Widget _buildShortcutCard(String title, IconData icon, VoidCallback onTap, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward, color: color),
        onTap: onTap,
      ),
    );
  }
}
