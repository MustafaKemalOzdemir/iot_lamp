/*
 ** Created by Mustafa Kemal ÖZDEMİR on 1.04.2022 **
*/
import 'package:iot_playground/core/model/preview_data.dart';
import 'package:iot_playground/core/protocol/station_command.dart';

abstract class CallBuilder {
  List<int> buildPreview(PreviewData previewData);
  List<int> buildConnectionCheck();
  List<int> buildDiscoverDevices();
  List<int> buildDiscoverResponse(String stationName);
  List<int> buildWriteDeviceName(String deviceName);

}

class CallBuilderImpl implements CallBuilder {
  @override
  List<int> buildPreview(PreviewData previewData) {
    final color = previewData.color;
    return [StationCommand.writeColor, color.alpha, color.red, color.green, color.blue];
  }

  @override
  List<int> buildConnectionCheck() {
    return [StationCommand.connectionCheck, 0];
  }

  @override
  List<int> buildDiscoverDevices() {
    return[StationCommand.discoverDevice, 0];
  }

  @override
  List<int> buildDiscoverResponse(String stationName) {
    final bytes = <int>[StationCommand.discoverResponse];
    bytes.addAll(stationName.codeUnits);
    return bytes;
  }

  @override
  List<int> buildWriteDeviceName(String deviceName) {
    final bytes = <int>[StationCommand.writeName];
    bytes.addAll(deviceName.codeUnits);
    return bytes;
  }

}