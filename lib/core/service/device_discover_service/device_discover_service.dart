/*
 ** Created by Mustafa Kemal ÖZDEMİR on 3.04.2022 **
*/
import 'dart:async';
import 'dart:io';

import 'package:iot_playground/core/call_decoder/call_decoder.dart';
import 'package:iot_playground/core/enum/call_type.dart';
import 'package:iot_playground/core/model/discovered_device.dart';
import 'package:iot_playground/core/service/call_builder/call_builder.dart';
import 'package:iot_playground/core/service/device_manager_factory/device_manager_factory.dart';

abstract class DeviceDiscoverService {
  Future<List<DiscoveredDevice>> discoverDevices();
}

class DeviceDiscoverServiceImpl extends DeviceDiscoverService {
  final CallDecoder callDecoder;
  RawDatagramSocket? _socket;
  StreamSubscription? _socketSubscription;
  final CallBuilder _callBuilder;
  final DeviceManagerFactory _factory;
  DeviceDiscoverServiceImpl(this._callBuilder, this.callDecoder, this._factory);
  final _discoveredDevices = <String, DiscoveredDevice>{};

  Future<void> initSocket() async {
    _close();
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 6666);
    _socket?.broadcastEnabled = true;
    _socketSubscription = _socket?.listen((event) {
      if(event == RawSocketEvent.read) {
        final datagram = _socket?.receive();
        print('DATAGRAM RECEIVED');
        if(datagram != null) {
          _evaluateResponse(datagram);
        }else {
          print('SUBSCRIPTION READ DATAGRAM NULL');
        }
      }
    });
  }

  @override
  Future<List<DiscoveredDevice>> discoverDevices() async{
    _factory.stopManagers();
    await initSocket();
    _discoveredDevices.clear();
    final data = _callBuilder.buildDiscoverDevices();
    _socket?.send(data, InternetAddress('255.255.255.255'), 6666);
    await Future.delayed(const Duration(seconds: 2));
    _factory.resumeManagers();
    return _discoveredDevices.values.toList();
  }

  void _close() {
    _socket = null;
    _socketSubscription?.cancel();
    _socketSubscription = null;
  }

  _evaluateResponse(Datagram data) {
    final decodedCall = callDecoder.decodeCall(data.data);
    if(decodedCall.flag == CallType.discoverDeviceResponse) {
      print('DISCOVERED DEVICE IP ${data.address.address}');
      _discoveredDevices[data.address.address] = DiscoveredDevice(data.address.address, decodedCall.obj as String);
    }
  }

}
