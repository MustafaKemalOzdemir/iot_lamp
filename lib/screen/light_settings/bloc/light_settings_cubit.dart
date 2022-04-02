import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:iot_playground/core/di/injection_container.dart';
import 'package:iot_playground/core/model/call_raw_response.dart';
import 'package:iot_playground/core/model/call_request.dart';
import 'package:iot_playground/core/model/preview_data.dart';
import 'package:iot_playground/core/service/call_builder/call_builder.dart';
import 'package:iot_playground/core/service/connection_manager/connection_manager.dart';

part 'light_settings_state.dart';

class LightSettingsCubit extends Cubit<LightSettingsState> {
  final CallBuilder _callBuilder;
  final ConnectionManager _connectionManager;
  LightSettingsCubit(this._callBuilder, this._connectionManager): super(LightSettingsInitial());


  Color _currentColor = const Color(0xFFFFFFFF);
  Color get currentColor => _currentColor;

  void manualInit(String ip) {
    _connectionManager.manualInit(ip);
  }

  void init(String ip) {
    _connectionManager.connect(ip);
  }

  void manualSend() {
    final data = PreviewData(_currentColor);
    final bytes = _callBuilder.buildPreview(data);
    _connectionManager.manualSend(bytes);
  }

  void send(){
    final data = PreviewData(_currentColor);
    final bytes = _callBuilder.buildPreview(data);
    final completer = Completer<CallRawResponse>();
    _connectionManager.requestCall(CallRequest(bytes, completer));
    completer.future.then((result) {
      print("call result ${result.isSuccessful}");
    });
  }

  void onColorSelected(Color color) {
    _currentColor = color;
  }

}
