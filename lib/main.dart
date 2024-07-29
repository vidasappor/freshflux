import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:myfoodwise_app/provider/theme_provider.dart';
import 'package:myfoodwise_app/screens/barcode_result.dart';
import 'package:provider/provider.dart';
import 'package:myfoodwise_app/services/notification_service.dart';
import 'package:myfoodwise_app/screens/home_screen.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  final NotificationService notificationService = NotificationService();
  await notificationService.initNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(notificationService: notificationService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  MyApp({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyFoodWise',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Nunito',
            // textTheme: TextTheme(
            //   headline1: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
            //   headline2: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
            //   headline3: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
            //   headline4: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
            //   headline5: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500),
            //   headline6: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w400),
            //   bodyText1: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w300),
            //   bodyText2: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w200),
            //   subtitle1: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w100),
            //   subtitle2: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w100),
            // ),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
        //home: BarcodeResultScreen(barcode: '43242342342', productName: 'Product Name Not Included', expiryDate: 'Expiry Date Not Included',),
          home: HomeScreen(notificationService: notificationService),
        );
      },
    );
  }
}
