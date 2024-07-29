// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:intl/intl.dart';
// import 'package:myfoodwise_app/services/storage_service.dart';
//
// class VoiceCommandScreen extends StatefulWidget {
//   @override
//   _VoiceCommandScreenState createState() => _VoiceCommandScreenState();
// }
//
// class _VoiceCommandScreenState extends State<VoiceCommandScreen> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _text = 'Press the button and start speaking';
//   final FlutterTts _flutterTts = FlutterTts();
//   final StorageService _storageService = StorageService();
//   final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
//   String _name = '';
//   String _expiryDate = '';
//   String _quantity = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }
//
//   Future<void> _listen() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (val) => print('onStatus: $val'),
//         onError: (val) => print('onError: $val'),
//       );
//       if (available) {
//         setState(() => _isListening = true);
//         _speech.listen(
//           onResult: (val) => setState(() {
//             _text = val.recognizedWords;
//           }),
//         );
//       } else {
//         setState(() => _isListening = false);
//         _speak('Speech recognition not available');
//       }
//     } else {
//       setState(() => _isListening = false);
//       _speech.stop();
//       _processCommand(_text);
//     }
//   }
//
//   Future<void> _processCommand(String command) async {
//     List<String> words = command.split(' ');
//
//     if (words.contains('add') && words.contains('product')) {
//       setState(() {
//         _name = _extractProductName(command);
//         _expiryDate = _extractDate(command);
//         _quantity = _extractQuantity(words);
//       });
//
//       if (_name.isNotEmpty && _expiryDate.isNotEmpty && _quantity.isNotEmpty) {
//         try {
//           _dateFormat.parseStrict(_expiryDate);
//           Map<String, dynamic> product = {
//             'name': _name,
//             'expiryDate': _expiryDate,
//             'quantity': _quantity,
//           };
//           await _storageService.saveProduct(product);
//           _speak('Product added successfully');
//         } catch (e) {
//           _speak('Invalid date format. Use dd/MM/yyyy.');
//         }
//       } else {
//         _speak('Please provide complete product details.');
//       }
//     } else {
//       _speak('Command not recognized. Please try again.');
//     }
//   }
//
//   String _extractProductName(String command) {
//     final productRegExp = RegExp(r'add product (.*?) expires');
//     final match = productRegExp.firstMatch(command);
//     return match != null ? match.group(1)! : '';
//   }
//
//   String _extractDate(String command) {
//     final dateRegExp = RegExp(r'expires in (.*?) quantity');
//     final match = dateRegExp.firstMatch(command);
//     if (match != null) {
//       final dateStr = match.group(1)!;
//       try {
//         final parsedDate = DateFormat('d MMMM yyyy').parseStrict(dateStr);
//         return DateFormat('dd/MM/yyyy').format(parsedDate);
//       } catch (e) {
//         return '';
//       }
//     }
//     return '';
//   }
//
//   String _extractQuantity(List<String> words) {
//     int quantityIndex = words.indexWhere((word) => word == 'quantity');
//     return quantityIndex != -1 && quantityIndex + 1 < words.length ? words[quantityIndex + 1] : '';
//   }
//
//   Future<void> _speak(String text) async {
//     await _flutterTts.speak(text);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Voice Commands'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 _text,
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 if (_isListening)
//                   CircularProgressIndicator(), // Show a loading indicator when listening
//                 FloatingActionButton(
//                   onPressed: _listen,
//                   backgroundColor: _isListening ? Colors.red : Colors.blue,
//                   child: Icon(_isListening ? Icons.mic : Icons.mic_none),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
