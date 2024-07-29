import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../main.dart';
import 'barcode_result.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late CameraController controller;
  bool isDetecting = false;
  final BarcodeScanner barcodeScanner = BarcodeScanner();
  String barcodeValue = '';
  String productName = '';
  String expiryDate = '';

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  // Initialize the camera
  Future<void> initializeCamera() async {
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
    controller.startImageStream((CameraImage image) {
      if (!isDetecting) {
        isDetecting = true;
        processCameraImage(image).then((_) {
          isDetecting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    barcodeScanner.close();
    super.dispose();
  }

  // Stop the camera and navigate to the barcode result screen
  Future<void> stopCameraAndNavigate() async {
    await controller.stopImageStream();
    await controller.dispose();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeResultScreen(
          barcode: barcodeValue,
          productName: productName,
          expiryDate: expiryDate,
        ),
      ),
    );
  }

  // Convert rotation integer to InputImageRotation enum
  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  // Process the camera image to detect barcodes
  Future<void> processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final InputImage inputImage = InputImage.fromBytes(
      bytes: bytes,
      inputImageData: InputImageData(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        imageRotation: _rotationIntToImageRotation(cameras[0].sensorOrientation),
        inputImageFormat: InputImageFormat.yuv420,
        planeData: image.planes.map(
              (Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          },
        ).toList(),
      ),
    );

    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      print('Barcode found! ${barcode.displayValue}');
      setState(() {
        barcodeValue = barcode.displayValue ?? 'Unknown barcode';
        productName = extractProductName(barcode.displayValue ?? '');
        expiryDate = extractExpiryDate(barcode.displayValue ?? '');
      });

      // Stop the camera and navigate to the result screen if a barcode is found
      if (barcodeValue.isNotEmpty) {
        await stopCameraAndNavigate();
        break;
      }
    }
  }

  // Extract the product name from the barcode data
  String extractProductName(String barcodeData) {
    if (barcodeData.contains('ProductName:')) {
      return barcodeData.split('ProductName:')[1].split(';')[0].trim();
    }
    return 'Product Name Not Included';
  }

  // Extract the expiry date from the barcode data
  String extractExpiryDate(String barcodeData) {
    if (barcodeData.contains('ExpiryDate:')) {
      return barcodeData.split('ExpiryDate:')[1].split(';')[0].trim();
    }
    return 'Expiry Date Not Included';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Stack(
        children: <Widget>[
          if (controller.value.isInitialized)
            CameraPreview(controller),
          if (!controller.value.isInitialized)
            const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                barcodeValue.isNotEmpty
                    ? 'Barcode found: $barcodeValue'
                    : 'Point the camera at a barcode',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Overlay to guide the user
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
