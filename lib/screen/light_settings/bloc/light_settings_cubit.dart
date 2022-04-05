import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iot_playground/core/di/injection_container.dart';
import 'package:iot_playground/core/enum/device_manager_state.dart';
import 'package:iot_playground/core/model/discovered_device.dart';
import 'package:iot_playground/core/model/preview_data.dart';
import 'package:iot_playground/core/service/device_manager/device_manager.dart';
import 'package:iot_playground/core/service/device_manager_factory/device_manager_factory.dart';

part 'light_settings_state.dart';

class LightSettingsCubit extends Cubit<LightSettingsState> {
  LightSettingsCubit(): super(LightSettingsInitial());

  final tag = 'light_settings_cubit';
  final factory = sl.get<DeviceManagerFactory>();
  late final DeviceManager deviceManager;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void initializeCubit(DiscoveredDevice device) {
    if(_isInitialized) {
      return;
    }
    _isInitialized = true;
    deviceManager = factory.constructManagerWithIp(device.ip);
    deviceManager.registerStateChangeListener(tag, (state) {
      emit(LightSettingsDeviceManagerStateChange(state));
    });
  }

  Color _currentColor = const Color(0xFFFFFFFF);
  Color get currentColor => _currentColor;

  void init(String ip) {
    deviceManager.connect(ip);
  }

 void updateDeviceName(String name) {
    if(name.isNotEmpty) {
      deviceManager.addWriteDeviceNameCall(name).then((value) {
        if(value.isSuccessful) {
          emit(LightSettingsDisplayDeviceName(name));
        }else {
          Fluttertoast.showToast(msg: 'Couldn\'t update device name');
        }
      });
    }
 }

  void onColorSelected(Color color) {
    _currentColor = color;
    final data = PreviewData(color);
    deviceManager.addPreviewCall(data);
  }

  @override
  Future<void> close() {
    deviceManager.unregisterStateChangeListener(tag);
    return super.close();
  }

}
