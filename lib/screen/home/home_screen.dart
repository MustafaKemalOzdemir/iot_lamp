/*
 ** Created by Mustafa Kemal ÖZDEMİR on 4.04.2022 **
*/
import 'package:flutter/material.dart';
import 'package:iot_playground/core/router/app_routes.dart';
import 'package:iot_playground/widget/device_mode_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Select Device Mode', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: DeviceModeButton(
                title: 'Configure as RGB Controller',
                res: 'assets/rgb-controller.png',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.discoverDevices);
                },
              ),
            ),
            Expanded(
              child: DeviceModeButton(
                title: 'Configure as RGB Device',
                res: 'assets/rgb-bulb.png',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.station);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
