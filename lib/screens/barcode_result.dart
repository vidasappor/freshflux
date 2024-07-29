import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'add_product_screen.dart'; // Import the AddProductScreen for navigation
import 'package:myfoodwise_app/services/storage_service.dart';
import 'home_screen.dart'; // Import the HomeScreen for navigation

class BarcodeResultScreen extends StatelessWidget {
  // Define final variables to hold the barcode, product name, and expiry date
  final String barcode;
  final String productName;
  final String expiryDate;

  // Constructor to initialize the barcode, product name, and expiry date
  BarcodeResultScreen({required this.barcode, required this.productName, required this.expiryDate});

  @override
  Widget build(BuildContext context) {
    // Determine if the product name and expiry date are valid
    bool hasProductName = productName.isNotEmpty && productName != 'Product Name Not Included';
    bool hasExpiryDate = expiryDate.isNotEmpty && expiryDate != 'Expiry Date Not Included';

    return Scaffold(
      // Define the AppBar with a title and background color
      appBar: AppBar(
        title: Text('Barcode Result'),
        backgroundColor: Colors.teal,
      ),
      // Define the body with a container having gradient background and padding
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
        child: Center(
          // Center the card in the container
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Display the title of the card
                  Text(
                    'Barcode Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                      fontFamily: 'Nunito',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Display the barcode details
                  _buildDetailRow('Barcode:', barcode),
                  SizedBox(height: 10),
                  // Display the product name details
                  _buildDetailRow('Product Name:', productName),
                  SizedBox(height: 10),
                  // Display the expiry date details
                  _buildDetailRow('Expiry Date:', expiryDate),
                  SizedBox(height: 20),
                  // Define the OK button to close the screen
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      elevation: 5,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Define the button to proceed to Add Product Screen
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductScreen(
                            product: {
                              if (hasProductName) 'name': productName,
                              if (hasExpiryDate) 'expiryDate': expiryDate,
                            },
                            onSave: (product) async {
                              // Save the product and navigate to HomeScreen
                              await StorageService().saveProduct(product);
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(notificationService: NotificationService()),
                                ),
                                    (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      elevation: 5,
                    ),
                    child: Text(
                      hasProductName && hasExpiryDate
                          ? 'Proceed to Add Product'
                          : 'Proceed to Add Product Manually',
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
      ),
    );
  }

  // Helper method to build detail rows for the barcode, product name, and expiry date
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
            fontFamily: 'Nunito',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.teal.shade800,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}
