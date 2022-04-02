/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'dart:async';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';

abstract class Station {
  void start();
  void stop();
  void registerListener(String tag, Function(List<int> data) listener);
}

class StationImpl implements Station {

  var isActive = false;
  StreamSubscription? _streamSubscription;
  final _listeners = Map<String, Function(List<int>)>();

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
            Fluttertoast.showToast(msg: 'Packet received length: ${data.data.length}');
            print('Packet received length: ${data.data.length} data: ${data.data}');
            _notifyListeners(data.data);
            final sentDataLength = socket.send(data.data.sublist(0,2), data.address, data.port);
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



}