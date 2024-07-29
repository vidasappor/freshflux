import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:myfoodwise_app/services/storage_service.dart';

// Main screen for adding or editing a product
class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;  // Product data if editing an existing product
  final Function(Map<String, dynamic>)? onSave;  // Callback function for saving the product
  final String? category;  // Pre-selected category

  const AddProductScreen({super.key, this.product, this.onSave, this.category});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();  // Controller for product name input
  final _expiryDateController = TextEditingController();  // Controller for expiry date input
  final _quantityController = TextEditingController();  // Controller for quantity input
  final StorageService _storageService = StorageService();  // Service for saving product data
  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy');  // Date format
  final _formKey = GlobalKey<FormState>();  // Key for form validation
  String _selectedCategory = 'Canned Product';  // Default category
  File? _image;  // Image file for product

  @override
  void initState() {
    super.initState();
    // If editing an existing product, populate the fields with its data
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _expiryDateController.text = widget.product!['expiryDate'] ?? '';
      _quantityController.text = widget.product!['quantity'] ?? '';
      _selectedCategory = widget.product!['category'] ?? 'Canned Product';
      if (widget.product!['imagePath'] != null) {
        _image = File(widget.product!['imagePath']);
      }
    }
    // If a category is pre-selected, set it
    else if (widget.category != null) {
      _selectedCategory = widget.category!;
    }
  }

  // Function to pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to save the product data
  void _saveProduct() async {
    // Validate the form fields
    if (_formKey.currentState?.validate() ?? false) {
      String name = _nameController.text;
      String expiryDate = _expiryDateController.text;
      String quantity = _quantityController.text;

      // Check if the expiry date format is valid
      try {
        _dateFormat.parseStrict(expiryDate);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid date format. Use MM/dd/yyyy.')),
        );
        return;
      }

      // Create a product map with the input data
      Map<String, dynamic> product = {
        'name': name,
        'expiryDate': expiryDate,
        'quantity': quantity,
        'category': _selectedCategory,
        'imagePath': _image?.path,
      };

      // If an onSave callback is provided, use it; otherwise, save the product using the storage service
      if (widget.onSave != null) {
        widget.onSave!(product);
      } else {
        await _storageService.saveProduct(product);
      }

      // Navigate back to the previous screen
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.product == null ? 'Add a New Product' : 'Edit Product',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                    fontFamily: 'Nunito',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  icon: Icons.fastfood,
                  validator: (value) => value!.isEmpty ? 'Please enter product name' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _expiryDateController,
                  label: 'Expiry Date (MM/dd/yyyy)',
                  icon: Icons.calendar_today,
                  validator: (value) => value!.isEmpty ? 'Please enter expiry date' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
                ),
                const SizedBox(height: 20),
                _buildCategoryDropdown(),
                const SizedBox(height: 20),
                _buildImagePicker(),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 5, // Added shadow for better visual appearance
                  ),
                  child: const Text(
                    'Save Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Nunito',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for building text input fields with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Nunito',
          color: Colors.teal.shade800,
        ),
        prefixIcon: Icon(icon, color: Colors.teal, size: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade800),
        ),
        filled: true,
        fillColor: Colors.teal.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Adjusted padding for better spacing
      ),
      style: TextStyle(
        fontFamily: 'Nunito',
        color: Colors.teal.shade800,
      ),
      validator: validator,
    );
  }

  // Widget for building the category dropdown menu
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: const [
        DropdownMenuItem(
          value: 'Canned Product',
          child: Text('Canned Product'),
        ),
        DropdownMenuItem(
          value: 'Dairy Product',
          child: Text('Dairy Product'),
        ),
        DropdownMenuItem(
          value: 'Medicine',
          child: Text('Medicine'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: TextStyle(
          fontFamily: 'Nexa',
          color: Colors.teal.shade800,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade800),
        ),
        filled: true,
        fillColor: Colors.teal.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
      style: TextStyle(
        fontFamily: 'Nexa',
        color: Colors.teal.shade800,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
    );
  }

  // Widget for building the image picker section
  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_image != null)
          Image.file(
            _image!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        else if (widget.product != null && widget.product!['imagePath'] != null)
          Image.file(
            File(widget.product!['imagePath']),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text('Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
