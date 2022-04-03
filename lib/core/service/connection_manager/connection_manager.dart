/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/

import 'dart:async';

import 'package:iot_playground/core/enum/connection_manager_message.dart';
import 'package:iot_playground/core/enum/connection_manager_state.dart';
import 'package:iot_playground/core/model/call_raw_response.dart';
import 'package:iot_playground/core/model/call_request_raw.dart';
import 'package:iot_playground/core/model/machine_message.dart';
import 'package:iot_playground/core/service/call_builder/call_builder.dart';
import 'package:statemachine/statemachine.dart';

import 'connection_manager_base.dart';

abstract class ConnectionManager {
  void connect(String ip);
  void requestCall(CallRequestRaw request);
  void registerStateChangeListener(String tag, Function(ConnectionManagerState state) listener);

}

class ConnectionManagerImpl extends ConnectionManagerBase implements ConnectionManager {
  final machine = Machine<ConnectionManagerState>();
  late final State<ConnectionManagerState> idle;
  late final State<ConnectionManagerState> connecting;
  late final State<ConnectionManagerState> connected;
  late final State<ConnectionManagerState> disconnected;
  late final State<ConnectionManagerState> processing;
  late final StreamController<MachineMessage<ConnectionManagerMessage>> _machineMessengerSC;
  late final Stream<MachineMessage<ConnectionManagerMessage>> _messengerStream;
  late final Sink<MachineMessage<ConnectionManagerMessage>> _messengerSink;

  late MachineMessage<ConnectionManagerMessage> _currentMessage;

  final CallBuilder _callBuilder;
  final callTimeout = const Duration(seconds: 1);

  ConnectionManagerImpl(this._callBuilder) {
    _machineMessengerSC = StreamController();
    _messengerStream = _machineMessengerSC.stream.asBroadcastStream();
    _messengerSink = _machineMessengerSC.sink;

    idle = machine.newStartState(ConnectionManagerState.idle);
    connecting = machine.newState(ConnectionManagerState.connecting);
    connected = machine.newState(ConnectionManagerState.connected);
    disconnected = machine.newState(ConnectionManagerState.disconnected);
   // processing = machine.newState(ConnectionManagerState.processing);

    setupIdle();
    setupConnecting();
    setupConnected();
    setupDisconnected();
    //setupProcessing();

    machine.start();
  }

  Future<CallRawResponse> onTimeout() async {
    resetData();
    return Future.value(CallRawResponse.failed());
  }

  void setupIdle() {
    idle.onEntry(() {
      print('CM IDLE STATE ON ENTER');
      notifyStateChange(ConnectionManagerState.idle);
    });
    idle.onStream(_messengerStream, (MachineMessage<ConnectionManagerMessage> message) {
      switch (message.flag) {
        case ConnectionManagerMessage.connect:
          connecting.enter();
          break;
        case ConnectionManagerMessage.disconnect:
          break;
        case ConnectionManagerMessage.send:
          denyCallRequest(message as CallRequestRaw);
          break;
      }
    });
    idle.onExit(() {
      print('CM IDLE STATE ON EXIT');
    });
  }

  void setupConnecting() {
    connecting.onEntry(() {
      print('CM CONNECTING STATE ON ENTER');
      notifyStateChange(ConnectionManagerState.connecting);
      Future.microtask(() async {
        late String ipAddress;
        if(_currentMessage.flag == ConnectionManagerMessage.connect) {
          ipAddress = _currentMessage.obj as String;
        }else {
          ipAddress = targetAddress;
        }

        await initializeSocket(ipAddress);
        var currentTry = 3;
        while(currentTry > 0) {
          final completer = Completer<CallRawResponse>();
          send(_callBuilder.buildConnectionCheck(), completer);
          final response = await completer.future.timeout(callTimeout, onTimeout: onTimeout);
          if(response.isSuccessful) {
            connected.enter();
            break;
          } else {
            currentTry--;
            if(currentTry <= 0) {
              disconnected.enter();
            }
          }
        }
      });
    });
    connecting.onStream(_messengerStream, (MachineMessage<ConnectionManagerMessage> message) {
      switch (message.flag) {
        case ConnectionManagerMessage.connect:
          break;
        case ConnectionManagerMessage.disconnect:
          break;
        case ConnectionManagerMessage.send:
          denyCallRequest(message as CallRequestRaw);
          break;
      }
    });
    connecting.onExit(() {
      print('CM CONNECTING STATE ON EXIT');
    });
  }

  void setupConnected() {
    connected.onEntry(() {
      print('CM CONNECTED STATE ON ENTER');
      notifyStateChange(ConnectionManagerState.connected);
    });
    connected.onStream(_messengerStream, (MachineMessage<ConnectionManagerMessage> message) {
      switch (message.flag) {
        case ConnectionManagerMessage.connect:
          break;
        case ConnectionManagerMessage.disconnect:
          break;
        case ConnectionManagerMessage.send:
        //data
        //callback -> CallRawResponse
          final request = message.obj as CallRequestRaw;
          trySend(request);
          break;
      }
    });
    connected.onExit(() {
      resetData();
      print('CM CONNECTED STATE ON EXIT');
    });
  }

  void trySend(CallRequestRaw request) {
    Future.microtask(() async {
      var currentTry = 3;
      while(currentTry > 0) {
        final completer = Completer<CallRawResponse>();
        send(request.data, completer);
        final response = await completer.future.timeout(callTimeout, onTimeout: onTimeout);
        if(response.isSuccessful) {
          request.callback.complete(response);
          break;
        } else {
          currentTry--;
          if(currentTry <= 0) {
            request.callback.complete(CallRawResponse.failed());
            disconnected.enter();
          }
        }
      }
    });
  }

  void denyCallRequest(CallRequestRaw request) {
    request.callback.complete(CallRawResponse.failed());
  }

  void setupDisconnected() {
    disconnected.onEntry(() {
      print('CM DISCONNECTED STATE ON ENTER');
      notifyStateChange(ConnectionManagerState.disconnected);
      Future.delayed(const Duration(seconds: 1), () {
        connecting.enter();
      });
    });
    disconnected.onStream(_messengerStream, (MachineMessage<ConnectionManagerMessage> message) {
      switch (message.flag) {
        case ConnectionManagerMessage.connect:
          break;
        case ConnectionManagerMessage.disconnect:
          break;
        case ConnectionManagerMessage.send:
          denyCallRequest(message as CallRequestRaw);
          break;
      }
    });
    disconnected.onExit(() {
      print('CM DISCONNECTED STATE ON EXIT');
    });
  }

  /*void setupProcessing() {
    processing.onEntry(() {
      print('PROCESSING STATE ON ENTER');
    });
    processing.onStream(_messengerStream, (MachineMessage<ConnectionManagerMessage> message) {
      switch (message.flag) {
        case ConnectionManagerMessage.connect:
          break;
        case ConnectionManagerMessage.disconnect:
          break;
      }
    });
    processing.onExit(() {
      print('PROCESSING STATE ON EXIT');
    });
  }*/

  void _dispatchMessage(ConnectionManagerMessage flag, dynamic obj) {
    final message = MachineMessage(flag, obj);
    _currentMessage = message;
    _messengerSink.add(message);
  }

  //idle
  //connecting
  //connected
  //sending data
  //disconnected

  @override
  void connect(String ip) {
    _dispatchMessage(ConnectionManagerMessage.connect, ip);
  }

  @override
  void onDataSent(bool isSuccessful) {
    print('ON DATA SENT STATE: $isSuccessful');
    //Fluttertoast.showToast(msg: 'on data sent $isSuccessful');
    //_dispatchMessage(ConnectionManagerMessage.dataSent, isSuccessful);
  }

  @override
  void requestCall(CallRequestRaw request) {
    _dispatchMessage(ConnectionManagerMessage.send, request);
  }

  @override
  void registerStateChangeListener(String tag, Function(ConnectionManagerState state) listener) {
    registerStateListenerBase(tag, listener);
  }

}
