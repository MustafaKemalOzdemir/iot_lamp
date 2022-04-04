/*
 ** Created by Mustafa Kemal ÖZDEMİR on 4.04.2022 **
*/
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferenceManager {
  Future<void> writeStationName(String name);
  Future<String> readStationName();
}

class PreferenceManagerImpl implements PreferenceManager {
  final String deviceNameKey = 'device_name';

  @override
  Future<void> writeStationName(String name) async {
    final instance = await SharedPreferences.getInstance();
    await instance.setString(deviceNameKey, name);
  }

  @override
  Future<String> readStationName() async{
    final instance = await SharedPreferences.getInstance();
    return instance.getString(deviceNameKey) ?? 'Unknown';
  }

}