/*
 ** Created by Mustafa Kemal ÖZDEMİR on 1.04.2022 **
*/
import 'package:iot_playground/core/enum/call_type.dart';

class DecodedCall {
  final CallType flag;
  final dynamic obj;
  const DecodedCall(this.flag, this.obj);
}