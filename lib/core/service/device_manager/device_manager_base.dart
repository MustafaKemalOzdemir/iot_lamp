/*
 ** Created by Mustafa Kemal ÖZDEMİR on 3.04.2022 **
*/
import 'package:iot_playground/core/enum/device_manager_state.dart';

abstract class DeviceManagerBase {
  final _stateChangeListeners = <String, Function(DeviceManagerState state)>{};

  void registerStateChangeListenerBase(String tag, Function(DeviceManagerState state) listener) {
    _stateChangeListeners[tag] = listener;
  }

  void notifyStateChangeListeners(DeviceManagerState state) {
    _stateChangeListeners.forEach((key, value) {
      value.call(state);
    });
  }

}