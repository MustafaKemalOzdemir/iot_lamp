/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
import 'dart:async';

import 'package:iot_playground/core/enum/call_type.dart';
import 'package:iot_playground/core/model/call_raw_response.dart';

class CallRequest<T> {
  final CallType flag;
  final Completer<CallRawResponse> callback;
  final T param;
  const CallRequest(this.flag, this.callback, this.param);
}