/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
import 'dart:async';
import 'dart:collection';

import 'package:iot_playground/core/model/queue_element.dart';
import 'package:synchronized/synchronized.dart';

abstract class QueueManagerBase {
  final _lock = Lock();
  final _safeQueue = Queue<QueueElement>();

  void enqueue(QueueElement element) {
    _lock.synchronized(() {
      _safeQueue.add(element);
    });
  }

  Future<QueueElement> peek() async {
    final completer = Completer<QueueElement>();
    _lock.synchronized(() {
      completer.complete(_safeQueue.first);
    });
    return completer.future;
  }

  Future<QueueElement> dequeue() async {
    final completer = Completer<QueueElement>();
    _lock.synchronized(() {
      completer.complete(_safeQueue.removeFirst());
    });
    return completer.future;
  }

  Future<int> queueSize() async {
    final completer = Completer<int>();
    _lock.synchronized(() {
      completer.complete(_safeQueue.length);
    });
    return completer.future;
  }

}
