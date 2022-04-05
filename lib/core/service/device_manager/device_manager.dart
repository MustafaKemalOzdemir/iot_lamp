/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
import 'dart:async';

import 'package:iot_playground/core/enum/call_type.dart';
import 'package:iot_playground/core/enum/connection_manager_state.dart';
import 'package:iot_playground/core/enum/device_manager_message.dart';
import 'package:iot_playground/core/enum/device_manager_state.dart';
import 'package:iot_playground/core/enum/queue_manager_state.dart';
import 'package:iot_playground/core/model/call_raw_response.dart';
import 'package:iot_playground/core/model/call_request.dart';
import 'package:iot_playground/core/model/machine_message.dart';
import 'package:iot_playground/core/model/preview_data.dart';
import 'package:iot_playground/core/model/void_callback.dart';
import 'package:iot_playground/core/service/connection_manager/connection_manager.dart';
import 'package:iot_playground/core/service/device_manager/device_manager_base.dart';
import 'package:iot_playground/core/service/queue_manager/queue_manager.dart';
import 'package:statemachine/statemachine.dart';

abstract class DeviceManager {
  void startMachine();
  void connect(String ip);
  void stop();
  void resume();
  Future<VoidCallback> addConnectionCheckCall();
  Future<VoidCallback> addPreviewCall(PreviewData data);
  Future<VoidCallback> addWriteDeviceNameCall(String deviceName);
  void registerStateChangeListener(String tag, Function(DeviceManagerState state) listener);
  void unregisterStateChangeListener(String tag);
}

class DeviceManagerImpl extends DeviceManagerBase implements DeviceManager {
  final machine = Machine<DeviceManagerState>();
  late State<DeviceManagerState> idle;
  late State<DeviceManagerState> connecting;
  late State<DeviceManagerState> connected;
  late State<DeviceManagerState> disconnected;
  final QueueManager queueManager;
  final ConnectionManager connectionManager;
  bool _isConnectionCheckerAlive = false;

  late final StreamController<MachineMessage<DeviceManagerMessage>> _machineMessengerSC;
  late final Stream<MachineMessage<DeviceManagerMessage>> _messengerStream;
  late final Sink<MachineMessage<DeviceManagerMessage>> _messengerSink;


  DeviceManagerImpl({required this.queueManager, required this.connectionManager}) {
    _machineMessengerSC = StreamController();
    _messengerStream = _machineMessengerSC.stream.asBroadcastStream();
    _messengerSink = _machineMessengerSC.sink;

    idle = machine.newStartState(DeviceManagerState.idle);
    connecting = machine.newState(DeviceManagerState.connecting);
    connected = machine.newState(DeviceManagerState.connected);
    disconnected = machine.newState(DeviceManagerState.disconnected);

    setupIdle();
    setupConnecting();
    setupConnected();
    setupDisconnected();

    connectionManager.registerStateChangeListener('connection_manager', (state) {
      _connectionManagerStateChange(state);
    });

  }

  @override
  void startMachine() {
    if(machine.current == null) {
      machine.start();
    }
  }

  void _startConnectionChecker() {
    _isConnectionCheckerAlive = true;
    _connectionCheck();
  }

  void _connectionCheck() async {
    Future.delayed(const Duration(seconds: 5), () {
      if(_isConnectionCheckerAlive) {
        if(queueManager.currentState == QueueManagerState.idle) {
          addConnectionCheckCall();
        }
        _connectionCheck();
      }
    });
  }

  void _stopConnectionChecker() {
    _isConnectionCheckerAlive = false;
  }

  void setupIdle() {
    idle.onEntry(() {
      print("DM IDLE ON ENTER");
      notifyStateChangeListeners(DeviceManagerState.idle);
    });
    idle.onStream(_messengerStream, (MachineMessage<DeviceManagerMessage> message) {
      switch(message.flag) {
        case DeviceManagerMessage.connect:
          connectionManager.connect(message.obj as String);
          break;
        case DeviceManagerMessage.addCall:
          _rejectRequest(message.obj as CallRequest);
          break;
        case DeviceManagerMessage.connectionManagerStateChange:
          switch(message.obj as ConnectionManagerState) {
            case ConnectionManagerState.idle:
              break;
            case ConnectionManagerState.connecting:
              connecting.enter();
              break;
            case ConnectionManagerState.connected:
              break;
            case ConnectionManagerState.disconnected:
              break;
            case ConnectionManagerState.stop:
              break;
          }
          break;
      }
    });
    idle.onExit(() {
      print("DM IDLE ON EXIT");
    });
  }

  void setupConnecting() {
    connecting.onEntry(() {
      print("DM CONNECTING ON ENTER");
      notifyStateChangeListeners(DeviceManagerState.connecting);
    });
    connecting.onStream(_messengerStream, (MachineMessage<DeviceManagerMessage> message) {
      switch(message.flag) {
        case DeviceManagerMessage.connect:
          break;
        case DeviceManagerMessage.addCall:
          _rejectRequest(message.obj as CallRequest);
          break;
        case DeviceManagerMessage.connectionManagerStateChange:
          switch(message.obj as ConnectionManagerState) {
            case ConnectionManagerState.idle:
              break;
            case ConnectionManagerState.connecting:
              break;
            case ConnectionManagerState.connected:
              connected.enter();
              break;
            case ConnectionManagerState.disconnected:
              disconnected.enter();
              break;
            case ConnectionManagerState.stop:
              break;
          }
          break;
      }
    });
    connecting.onExit(() {
      print("DM CONNECTING ON EXIT");
      _startConnectionChecker();
    });
  }

  void setupConnected() {
    connected.onEntry(() {
      print("DM CONNECTED ON ENTER");
      notifyStateChangeListeners(DeviceManagerState.connected);
    });
    connected.onStream(_messengerStream, (MachineMessage<DeviceManagerMessage> message) {
      switch(message.flag) {
        case DeviceManagerMessage.connect:
          break;
        case DeviceManagerMessage.addCall:
          _enqueueInternal(message.obj as CallRequest);
          break;
        case DeviceManagerMessage.connectionManagerStateChange:
          switch(message.obj as ConnectionManagerState) {
            case ConnectionManagerState.idle:
              break;
            case ConnectionManagerState.connecting:
              break;
            case ConnectionManagerState.connected:
              break;
            case ConnectionManagerState.disconnected:
              disconnected.enter();
              break;
            case ConnectionManagerState.stop:
              break;
          }
          break;
      }
    });
    connected.onExit(() {
      print("DM CONNECTED ON EXIT");
      _stopConnectionChecker();
    });
  }

  void setupDisconnected() {
    disconnected.onEntry(() {
      print("DM DISCONNECTED ON ENTER");
      notifyStateChangeListeners(DeviceManagerState.disconnected);
    });
    disconnected.onStream(_messengerStream, (MachineMessage<DeviceManagerMessage> message) {
      switch(message.flag) {
        case DeviceManagerMessage.connect:
          break;
        case DeviceManagerMessage.addCall:
          _rejectRequest(message.obj as CallRequest);
          break;
        case DeviceManagerMessage.connectionManagerStateChange:
          switch(message.obj as ConnectionManagerState) {
            case ConnectionManagerState.idle:
              break;
            case ConnectionManagerState.connecting:
              connecting.enter();
              break;
            case ConnectionManagerState.connected:
              break;
            case ConnectionManagerState.disconnected:
              break;
            case ConnectionManagerState.stop:
              break;
          }
          break;
      }
    });
    disconnected.onExit(() {
      print("DM DISCONNECTED ON EXIT");
    });
  }


  void _dispatchMessage(DeviceManagerMessage flag, dynamic obj) {
    final message = MachineMessage(flag, obj);
    _messengerSink.add(message);
  }

  void _enqueueInternal(CallRequest request) {
    queueManager.enqueueCall(request);
  }

  void _rejectRequest(CallRequest request) {
    request.callback.complete(CallRawResponse.failed());
  }

  void _connectionManagerStateChange(ConnectionManagerState state) {
    _dispatchMessage(DeviceManagerMessage.connectionManagerStateChange, state);
  }

  @override
  void connect(String ip) {
    _dispatchMessage(DeviceManagerMessage.connect, ip);
  }

  @override
  Future<VoidCallback> addPreviewCall(PreviewData data) async {
    final callback = Completer<CallRawResponse>();
    final request = CallRequest(CallType.preview, callback, data);
    _dispatchMessage(DeviceManagerMessage.addCall, request);
    final callResult = await callback.future;
    return VoidCallback(callResult.isSuccessful);
  }

  @override
  Future<VoidCallback> addConnectionCheckCall() async{
    final callback = Completer<CallRawResponse>();
    final request = CallRequest(CallType.connectionCheck, callback, null);
    _dispatchMessage(DeviceManagerMessage.addCall, request);
    final callResult = await callback.future;
    return VoidCallback(callResult.isSuccessful);
  }

  @override
  Future<VoidCallback> addWriteDeviceNameCall(String deviceName) async{
    final callback = Completer<CallRawResponse>();
    final request = CallRequest(CallType.writeDeviceName, callback, deviceName);
    _dispatchMessage(DeviceManagerMessage.addCall, request);
    final callResult = await callback.future;
    return VoidCallback(callResult.isSuccessful);
  }

  @override
  void registerStateChangeListener(String tag, Function(DeviceManagerState state) listener) {
    registerStateChangeListenerBase(tag, listener);
  }

 @override
  void unregisterStateChangeListener(String tag) {
    unregisterListener(tag);
  }

  @override
  void stop() {
    connectionManager.stopMachine();
  }

  @override
  void resume() {
    connectionManager.resumeMachine();
  }

}

