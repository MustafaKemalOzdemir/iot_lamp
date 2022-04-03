/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
import 'dart:async';

import 'package:iot_playground/core/model/call_raw_response.dart';
import 'package:iot_playground/core/model/call_request.dart';
import 'package:iot_playground/core/model/machine_message.dart';
import 'package:iot_playground/core/model/queue_element.dart';
import 'package:iot_playground/core/service/operation_manager/operation_manager.dart';
import 'package:iot_playground/core/service/queue_manager/queue_manager_base.dart';
import 'package:statemachine/statemachine.dart';

abstract class QueueManager {
  void consume();
  void enqueueCall(CallRequest request);
}

class QueueManagerImpl extends QueueManagerBase implements QueueManager {
  final OperationManager operationManager;

  final machine = Machine<QueueManagerState>();
  late final State<QueueManagerState> idle;
  late final State<QueueManagerState> processing;
  late final State<QueueManagerState> dispose;

  late final StreamController<MachineMessage<QueueManagerMessage>> _machineMessengerSC;
  late final Stream<MachineMessage<QueueManagerMessage>> _messengerStream;
  late final Sink<MachineMessage<QueueManagerMessage>> _messengerSink;

  late MachineMessage<QueueManagerMessage> _currentMessage;

  QueueManagerImpl({required this.operationManager}) {
    _machineMessengerSC = StreamController();
    _messengerStream = _machineMessengerSC.stream.asBroadcastStream();
    _messengerSink = _machineMessengerSC.sink;


    idle = machine.newStartState(QueueManagerState.idle);
    processing = machine.newState(QueueManagerState.processing);
    dispose = machine.newState(QueueManagerState.dispose);

    setupIdle();
    setupProcessing();
    setupDispose();

    machine.start();
  }

  void setupIdle() {
    idle.onEntry(() {
      print('QM IDLE STATE ON ENTER');
      Future.microtask(() async {
        if(await queueSize() > 0) {
          processing.enter();
        }
      });
    });
    idle.onStream(_messengerStream, (MachineMessage<QueueManagerMessage> message) {
      switch(message.flag) {
        case QueueManagerMessage.enqueue:
          _enqueueInternal(message.obj as CallRequest);
          processing.enter();
          break;
        case QueueManagerMessage.consume:
          Future.microtask(() async{
            final size = await queueSize();
            if(size >= 0) {
              processing.enter();
            }
          });
          break;
      }
    });
    idle.onExit(() {
      print('QM IDLE STATE ON EXIT');
    });
  }

  void setupProcessing() {
    processing.onEntry(() {
      Future.delayed(const Duration(milliseconds: 5), () async{
        final element = await peek();
        final response = await element.call.call();
        if(response.isSuccessful) {
          await dequeue();
          element.callback.complete(response);
          idle.enter();
        }else {
          element.callback.complete(response);
          dispose.enter();
        }
      });
      print('QM  PROCESSING STATE ON ENTER');
    });
    processing.onStream(_messengerStream, (MachineMessage<QueueManagerMessage> message) {
      switch(message.flag) {
        case QueueManagerMessage.enqueue:
          _enqueueInternal(message.obj as CallRequest);
          break;
        case QueueManagerMessage.consume:
          break;
      }
    });
    processing.onExit(() {
      print('QM PROCESSING STATE ON EXIT');
    });
  }

  void setupDispose() {
    dispose.onEntry(() {
      print('QM DISPOSE STATE ON ENTER');
      Future.microtask(() async{
        while(await queueSize() > 0) {
          (await dequeue()).callback.complete(CallRawResponse.failed());
        }
        idle.enter();
      });
    });
    dispose.onStream(_messengerStream, (MachineMessage<QueueManagerMessage> message) {
      switch(message.flag) {
        case QueueManagerMessage.enqueue:
          final request = message.obj as CallRequest;
          request.callback.complete(CallRawResponse.failed());
          break;
        case QueueManagerMessage.consume:
          idle.enter();
          break;
      }
    });
    dispose.onExit(() {
      print('QM DISPOSE STATE ON EXIT');
    });
  }



  void _dispatchMessage(QueueManagerMessage flag, dynamic obj) {
    final message = MachineMessage(flag, obj);
    _currentMessage = message;
    _messengerSink.add(message);
  }

  @override
  void consume() {
    _dispatchMessage(QueueManagerMessage.consume, null);
  }

  @override
  void enqueueCall(CallRequest request) {
    _dispatchMessage(QueueManagerMessage.enqueue, request);
  }

  void _enqueueInternal(CallRequest request) {
    final element = QueueElement(() => operationManager.getCall(request.flag, request.param), request.callback);
    enqueue(element);
  }

}

enum QueueManagerMessage {
  consume,
  enqueue
}

enum QueueManagerState {
  idle,
  processing,
  dispose
}