/*
 ** Created by Mustafa Kemal ÖZDEMİR on 3.04.2022 **
*/
import 'package:iot_playground/core/enum/device_manager_state.dart';

abstract class DeviceManagerBase {
  final _stateChangeListeners = <String, Function(DeviceManagerState state)>{};
  DeviceManagerState? _currentState;

  void registerStateChangeListenerBase(String tag, Function(DeviceManagerState state) listener) {
    _stateChangeListeners[tag] = listener;
    if(_currentState != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        listener.call(_currentState!);
      });
    }
  }

  void unregisterListener(String tag) {
    _stateChangeListeners.remove(tag);
  }

  void notifyStateChangeListeners(DeviceManagerState state) {
    _currentState = state;
    _stateChangeListeners.forEach((key, value) {
      value.call(state);
    });
  }

}