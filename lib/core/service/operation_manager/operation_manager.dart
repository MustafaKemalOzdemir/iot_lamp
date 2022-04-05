/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
import 'dart:async';

import 'package:iot_playground/core/enum/call_type.dart';
import 'package:iot_playground/core/model/call_raw_response.dart';
import 'package:iot_playground/core/model/call_request_raw.dart';
import 'package:iot_playground/core/model/preview_data.dart';
import 'package:iot_playground/core/service/call_builder/call_builder.dart';
import 'package:iot_playground/core/service/connection_manager/connection_manager.dart';

abstract class OperationManager {
  Future<CallRawResponse> getCall(CallType flag, dynamic param);
}

class OperationManagerImpl implements OperationManager {
  final CallBuilder callBuilder;
  final ConnectionManager connectionManager;
  const OperationManagerImpl({required this.callBuilder, required this.connectionManager});

  @override
  Future<CallRawResponse> getCall(CallType flag, param) async {
    switch(flag)  {
      case CallType.preview:
        return _handlePreview(param as PreviewData);
      case CallType.unknown:
        return CallRawResponse.failed();
      case CallType.connectionCheck:
        return _handleConnectionCheck();
      case CallType.discoverDevice:
        return CallRawResponse.failed();
      case CallType.discoverDeviceResponse:
        return CallRawResponse.failed();
      case CallType.writeDeviceName:
        return _handleWriteDeviceName(param as String);
    }
  }

  Future<CallRawResponse> _handlePreview(PreviewData previewData) async{
    Completer<CallRawResponse> response = Completer();
    final bytes = callBuilder.buildPreview(previewData);
    final request = CallRequestRaw(bytes, response);
    connectionManager.requestCall(request);
    return response.future;
  }

  Future<CallRawResponse> _handleConnectionCheck() async{
    Completer<CallRawResponse> response = Completer();
    final bytes = callBuilder.buildConnectionCheck();
    final request = CallRequestRaw(bytes, response);
    connectionManager.requestCall(request);
    return response.future;
  }

  Future<CallRawResponse> _handleWriteDeviceName(String deviceName) async{
    Completer<CallRawResponse> response = Completer();
    final bytes = callBuilder.buildWriteDeviceName(deviceName);
    final request = CallRequestRaw(bytes, response);
    connectionManager.requestCall(request);
    return response.future;
  }

}

