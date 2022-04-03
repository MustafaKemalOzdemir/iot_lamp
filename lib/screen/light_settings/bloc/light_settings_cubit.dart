import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:iot_playground/core/di/injection_container.dart';
import 'package:iot_playground/core/enum/device_manager_state.dart';
import 'package:iot_playground/core/model/preview_data.dart';
import 'package:iot_playground/core/service/device_manager/device_manager.dart';
import 'package:iot_playground/core/service/device_manager_factory/device_manager_factory.dart';

part 'light_settings_state.dart';

class LightSettingsCubit extends Cubit<LightSettingsState> {
  LightSettingsCubit(): super(LightSettingsInitial());

  final factory = sl.get<DeviceManagerFactory>();
  late final DeviceManager deviceManager;

  void initializeCubit() {
    deviceManager = factory.constructDeviceManager();
    deviceManager.registerStateChangeListener('light_settings_cubit', (state) {
      emit(LightSettingsDeviceManagerStateChange(state));
    });
    deviceManager.startMachine();
  }

  Color _currentColor = const Color(0xFFFFFFFF);
  Color get currentColor => _currentColor;

  void init(String ip) {
    deviceManager.connect(ip);
  }

  void send() async{
    final data = PreviewData(_currentColor);
    final result = await deviceManager.addPreviewCall(data);
    print('settings cubit call state ${result.isSuccessful}');
  }

  void onColorSelected(Color color) {
    _currentColor = color;
    final data = PreviewData(color);
    deviceManager.addPreviewCall(data);
  }

}
