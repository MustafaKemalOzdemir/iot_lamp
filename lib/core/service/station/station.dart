/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'dart:async';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:iot_playground/core/call_decoder/call_decoder.dart';
import 'package:iot_playground/core/enum/call_type.dart';
import 'package:iot_playground/core/preference_manager/preference_manager.dart';
import 'package:iot_playground/core/service/call_builder/call_builder.dart';

abstract class Station {
  void start();
  void stop();
  void registerListener(String tag, Function(List<int> data) listener);
}

class StationImpl implements Station {
  final CallDecoder callDecoder;
  final PreferenceManager preferenceManager;
  final CallBuilder callBuilder;
  StationImpl(this.callDecoder, this.preferenceManager, this.callBuilder);

  var isActive = false;
  StreamSubscription? _streamSubscription;
  final _listeners = <String, Function(List<int>)>{};

  @override
  void start() async {
    isActive = true;
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 6666);
    socket.timeout(const Duration(seconds: 1));
    print('SUBSCRIPTION STARTED');
    _streamSubscription = socket.listen((event) {
      print('SUBSCRIPTION EVENT $event');
      if(event == RawSocketEvent.read) {
        final data = socket.receive();
        if(data != null) {
          print('data received address ${data.address} port ${data.port} data size ${data.data.length}');
          Future.microtask(() {
            print('Packet received length: ${data.data.length} data: ${data.data}');
            _evaluateReceivedDatagram(data).then((responseBytes) {
              socket.send(responseBytes, data.address, data.port);
            });
            _notifyListeners(data.data);
          });
        }else {
          print('data is null');
        }
      }
    });
  }

  @override
  void stop() {
    print('SUBSCRIPTION CANCELLED');
    _streamSubscription?.cancel();
  }

  @override
  void registerListener(String tag, Function(List<int> data) listener) {
    _listeners[tag] = listener;
  }

  void _notifyListeners(List<int> data) {
    print("NOTIFY LISTENER");
    for (var listener in _listeners.values) {
      print("NOTIFYING LISTENER");
      listener.call(data);
    }
  }

  Future<List<int>> _evaluateReceivedDatagram(Datagram datagram) async {
    final decodedCall = callDecoder.decodeCall(datagram.data);
    if(decodedCall.flag == CallType.discoverDevice) {
      final stationName = await preferenceManager.readStationName();
      return callBuilder.buildDiscoverResponse(stationName);
    }else if(decodedCall.flag == CallType.writeDeviceName) {
      await preferenceManager.writeStationName(decodedCall.obj as String);
    }
    return datagram.data;
  }

}