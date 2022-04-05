/*
 ** Created by Mustafa Kemal ÖZDEMİR on 4.04.2022 **
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iot_playground/core/router/app_routes.dart';
import 'package:iot_playground/screen/discover_device/discover_device_screen.dart';
import 'package:iot_playground/screen/home/home_screen.dart';
import 'package:iot_playground/screen/light_settings/light_settings.dart';
import 'package:iot_playground/screen/station/station_page.dart';

abstract class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch(settings.name) {
      case AppRoutes.home: {
        return _generateCupertinoRoute(const HomeScreen(), settings);
      }
      case AppRoutes.discoverDevices: {
        return _generateCupertinoRoute(const DiscoverDeviceScreen(), settings);
      }
      case AppRoutes.station: {
        return _generateCupertinoRoute(const StationPage(), settings);
      }
      case AppRoutes.lightSettings: {
        return _generateCupertinoRoute(const LightSettings(), settings);
      }
      default: {
        return _generateCupertinoRoute(const HomeScreen(), settings);
      }
    }
  }

  static Route _generateMaterialRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => widget, settings: settings);
  }

  static Route _generateCupertinoRoute(Widget widget, RouteSettings settings) {
    return CupertinoPageRoute(builder: (context) => widget, settings: settings);
  }
}