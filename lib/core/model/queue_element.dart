/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
import 'dart:async';

import 'package:iot_playground/core/model/call_raw_response.dart';

class QueueElement {
  final Future<CallRawResponse> Function() call;
  final Completer<CallRawResponse> callback;
  const QueueElement(this.call, this.callback);
}