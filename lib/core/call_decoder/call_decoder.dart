/*
 ** Created by Mustafa Kemal ÖZDEMİR on 1.04.2022 **
*/
import 'package:flutter/material.dart';
import 'package:iot_playground/core/enum/call_type.dart';
import 'package:iot_playground/core/model/decoded_call.dart';
import 'package:iot_playground/core/protocol/station_command.dart';
import 'dart:convert';

abstract class CallDecoder {
  DecodedCall decodeCall(List<int> data);
}

class CallDecoderImpl extends CallDecoder {
  @override
  DecodedCall decodeCall(List<int> data) {
    final controlByte = data.first;
    switch(controlByte) {
      case StationCommand.writeColor: {
        final alpha = data[1];
        final red = data[2];
        final green = data[3];
        final blue = data[4];
        return DecodedCall(CallType.preview, Color.fromARGB(alpha, red, green, blue));
      }
      case StationCommand.connectionCheck: {
        return const DecodedCall(CallType.connectionCheck, null);
      }
      case StationCommand.discoverDevice: {
        return const DecodedCall(CallType.discoverDevice, null);
      }
      case StationCommand.discoverResponse: {
        return DecodedCall(CallType.discoverDeviceResponse, utf8.decode(data.sublist(1)));
      }
      case StationCommand.writeName: {
        return DecodedCall(CallType.writeDeviceName, utf8.decode(data.sublist(1)));
      }
      default: {
        return const DecodedCall(CallType.unknown, null);
      }
    }
  }

}