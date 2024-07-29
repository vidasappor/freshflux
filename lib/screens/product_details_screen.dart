import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfoodwise_app/services/ai_service.dart';
import 'package:myfoodwise_app/services/notification_service.dart';
import 'package:myfoodwise_app/services/storage_service.dart';
import 'dart:io';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final int index;
  final Function(Map<String, dynamic>)? onSave;

  // Constructor to initialize the product details screen with product data, index, and optional onSave callback
  ProductDetailsScreen({super.key, required this.product, required this.index, this.onSave});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _nameController = TextEditingController(); // Controller for the product name input
  final _expiryDateController = TextEditingController(); // Controller for the expiry date input
  final _quantityController = TextEditingController(); // Controller for the quantity input
  final StorageService _storageService = StorageService(); // Storage service instance
  final NotificationService _notificationService = NotificationService(); // Notification service instance
  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy'); // Date format for parsing and formatting dates

  String _selectedReminder = ''; // Selected reminder time
  String _selectedCategory = ''; // Selected product category
  bool _isLoading = false; // Loading state for async operations
  String _aiInfo = ''; // AI-generated information about the product

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with product data
    _nameController.text = widget.product['name'];
    _expiryDateController.text = widget.product['expiryDate'];
    _quantityController.text = widget.product['quantity'];
    _selectedReminder = widget.product['reminder'] ?? '';
    _selectedCategory = widget.product['category'] ?? 'Canned Product';
  }

  // Save the product details
  void _saveProduct() async {
    String name = _nameController.text;
    String expiryDate = _expiryDateController.text;
    String quantity = _quantityController.text;

    // Validate the date format
    try {
      _dateFormat.parseStrict(expiryDate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date format. Use MM/dd/yyyy.')),
      );
      return;
    }

    // Ensure all fields are filled
    if (name.isNotEmpty && expiryDate.isNotEmpty && quantity.isNotEmpty && _selectedCategory.isNotEmpty) {
      Map<String, dynamic> product = {
        'name': name,
        'expiryDate': expiryDate,
        'quantity': quantity,
        'category': _selectedCategory,
        'reminder': _selectedReminder,
        'imagePath': widget.product['imagePath'], // Ensure the imagePath is saved
      };

      // Save the product using the onSave callback or the storage service
      if (widget.onSave != null) {
        widget.onSave!(product);
      } else {
        await _storageService.updateProduct(widget.index, product);
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
    }
  }

  // Set a reminder for the product
  void _setReminder() async {
    if (_selectedReminder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a reminder time.')),
      );
      return;
    }

    final expiryDate = _dateFormat.parse(widget.product['expiryDate']);
    DateTime reminderDate;

    // Calculate the reminder date based on the selected reminder time
    switch (_selectedReminder) {
      case '1 day':
        reminderDate = expiryDate.subtract(Duration(days: 1));
        break;
      case '3 days':
        reminderDate = expiryDate.subtract(Duration(days: 3));
        break;
      case '1 week':
        reminderDate = expiryDate.subtract(Duration(days: 7));
        break;
      case '2 weeks':
        reminderDate = expiryDate.subtract(Duration(days: 14));
        break;
      case '3 weeks':
        reminderDate = expiryDate.subtract(Duration(days: 21));
        break;
      default:
        reminderDate = expiryDate;
    }

    // Schedule a notification
    await _notificationService.scheduleNotification(
      'Product Expiry Reminder',
      '${widget.product['name']} is expiring soon!',
      reminderDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for $_selectedReminder before expiry.')),
    );
  }

  // Show AI-generated information about the product
  Future<void> _showAIInfo() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    String prompt;
    if (widget.product['category'] == 'Medicine') {
      prompt = 'What diseases can ${widget.product['name']} treat?';
    } else {
      prompt = 'Give me some recipes using ${widget.product['name']}';
    }

    try {
      String aiInfo = await fetchAIInfo(prompt, widget.product['category']);
      setState(() {
        _aiInfo = aiInfo;
      });
      // Show AI information in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Product Information'),
            content: Text(aiInfo),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch product information')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Show a larger version of the product image
  void _showLargeImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.file(File(imagePath)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and gradient background
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // Main body with gradient background and product details form
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildImage(widget.product['imagePath']), // Display the product image
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Product Name',
                            icon: Icons.fastfood,
                          ), // Text field for product name
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _expiryDateController,
                            label: 'Expiry Date (MM/dd/yyyy)',
                            icon: Icons.calendar_today,
                          ), // Text field for expiry date
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _quantityController,
                            label: 'Quantity',
                            icon: Icons.format_list_numbered,
                            keyboardType: TextInputType.number,
                          ), // Text field for quantity
                          SizedBox(height: 20),
                          // Dropdown for selecting product category
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            items: ['Canned Product', 'Dairy Product', 'Medicine']
                                .map((category) => DropdownMenuItem(
                              child: Text(category),
                              value: category,
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value ?? 'Canned Product';
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                            ),
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Section for adding reminders
                  Text(
                    'Add a reminder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                      fontFamily: 'Nexa',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  // Reminder chips for selecting reminder times
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildReminderChip('1 day'),
                      _buildReminderChip('3 days'),
                      _buildReminderChip('1 week'),
                      _buildReminderChip('2 weeks'),
                      _buildReminderChip('3 weeks'),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Save button
                  ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Set reminder button
                  ElevatedButton(
                    onPressed: _setReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Set Reminder',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Show AI info button
                  ElevatedButton(
                    onPressed: _showAIInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      widget.product['category'] == 'Medicine' ? 'Show Disease Information' : 'Show Recipes',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Display AI info if available
                  if (_aiInfo.isNotEmpty)
                    Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _aiInfo,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Loading indicator while fetching AI info
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fetching information...',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Nunito',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build a text field with the given controller, label, icon, and keyboard type
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Nunito',
        ),
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.teal.shade50,
      ),
      style: TextStyle(
        fontFamily: 'Nexa',
      ),
    );
  }

  // Build a reminder chip with the given label
  Widget _buildReminderChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedReminder == label,
      onSelected: (selected) {
        setState(() {
          _selectedReminder = selected ? label : '';
        });
      },
      backgroundColor: Colors.teal.shade100,
      selectedColor: Colors.teal.shade400,
      labelStyle: TextStyle(
        fontFamily: 'Nunito',
        color: _selectedReminder == label ? Colors.white : Colors.teal.shade900,
      ),
    );
  }

  // Build the image widget for the product
  Widget _buildImage(String? imagePath) {
    if (imagePath != null && File(imagePath).existsSync()) {
      return GestureDetector(
        onTap: () => _showLargeImage(imagePath), // Show a larger version of the image on tap
        child: CircleAvatar(
          backgroundImage: FileImage(File(imagePath)),
          radius: 60,
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.teal.shade100,
        child: Icon(Icons.food_bank, color: Colors.teal.shade700, size: 60),
        radius: 60,
      );
    }
  }
}
