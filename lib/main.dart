import 'package:flutter/material.dart';
import 'package:iot_playground/core/di/injection_container.dart';
import 'package:iot_playground/screen/discover_device/discover_device_screen.dart';
import 'package:iot_playground/screen/light_settings/light_settings.dart';
import 'package:iot_playground/screen/station/station_page.dart';

void main() {
  initializeDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Discover'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DiscoverDeviceScreen()));
              },
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              child: const Text('Host'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LightSettings()));
              },
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              child: const Text('Station'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StationPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
