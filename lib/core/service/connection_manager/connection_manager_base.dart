/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'dart:async';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:iot_playground/core/enum/connection_manager_state.dart';
import 'package:iot_playground/core/model/call_raw_response.dart';

class NoDatagramAvailableException implements Exception {}
class DatagramResponseLengthException implements Exception {}
class DatagramResponseCharacterMismatchException implements Exception {}

abstract class ConnectionManagerBase {
  RawDatagramSocket? _socket;
  StreamSubscription? _streamSubscription;
  List<int>? _currentData;
  String? _targetAddress;
  final _targetPort = 6666;
  String get targetAddress => _targetAddress!;

  Completer<CallRawResponse>? _callResponseCompleter;
  final _stateChangeListeners = <String, Function(ConnectionManagerState state)>{};

  initializeSocket(String ip) async{
    _targetAddress = ip;
    close();
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _targetPort);
    _socket?.timeout(const Duration(seconds: 1));
    _streamSubscription = _socket?.listen((event) {
      print('SUBSCRIPTION EVENT $event');
      if(event == RawSocketEvent.read) {
        final datagram = _socket?.receive();
        print('DATAGRAM RECEIVED');
        if(datagram != null) {
          _onStreamReceive(datagram);
        }else {
          print('SUBSCRIPTION READ DATAGRAM NULL');
        }
      }
    });
    Fluttertoast.showToast(msg: 'Socked init $ip');
  }

  void onDataSent(bool isSuccessful);

  void _onStreamReceive(Datagram datagram) {
    if(_targetAddress != null && _targetAddress == datagram.address.address && _currentData != null) {
      final response = datagram.data;
      if(response.length < 2) {
        print('Response length exception');
        _callResponseCompleter?.complete(CallRawResponse.failed());
        onDataSent(false);
      }else if(response[0] != _currentData![0] || response[1] != _currentData![1]) {
        print('Response character mismatch');
        _callResponseCompleter?.complete(CallRawResponse.failed());
        onDataSent(false);
      }else {
        _callResponseCompleter?.complete(CallRawResponse.success(response));
        print('All good data sent');
        onDataSent(true);
      }
    }else {
      print("RECEIVED DATAGRAM DISCARTED TA:$_targetAddress DA:${datagram.address.address} CD: $_currentData");
    }
  }

  void send(List<int> data, Completer<CallRawResponse> callback) {
    _callResponseCompleter = callback;
    _currentData = data;
    print("SEND DATA $data S:$_socket");
    _socket?.send(data, InternetAddress(_targetAddress!), _targetPort);
  }

  void close() {
    _socket = null;
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void resetData() {
    _currentData = null;
    _callResponseCompleter = null;
  }

  void registerStateListenerBase(String tag, Function(ConnectionManagerState state) listener) {
    _stateChangeListeners[tag] = listener;
  }

  void notifyStateChange(ConnectionManagerState current) {
    _stateChangeListeners.forEach((key, value) {
      value.call(current);
    });
  }

}