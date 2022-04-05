import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_playground/core/di/injection_container.dart';
import 'package:iot_playground/core/router/app_router.dart';
import 'package:iot_playground/core/router/app_routes.dart';
void main() {
  initializeDi();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: Colors.grey.shade50, // status bar color
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter IoT Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        fontFamily: 'CeraRound',
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.home,
    );
  }
}

