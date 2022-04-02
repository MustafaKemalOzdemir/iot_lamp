/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
import 'dart:async';

import 'package:iot_playground/core/model/call_raw_response.dart';

class CallRequest {
  final List<int> data;
  final Completer<CallRawResponse> callback;
  const CallRequest(this.data, this.callback);
}