import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iot_playground/core/call_decoder/call_decoder.dart';
import 'package:iot_playground/core/enum/call_type.dart';
import 'package:iot_playground/core/model/decoded_call.dart';
import 'package:iot_playground/core/service/station/station.dart';

part 'station_state.dart';

class StationCubit extends Cubit<StationState> {
  final Station station;
  final CallDecoder callDecoder;
  StationCubit(this.station, this.callDecoder) : super(StationInitial());

  final tag = "station_page";
  Color _currentColor = const Color(0xffff0000);
  Color get currentColor => _currentColor;

  void initialize() {
    station.registerListener(tag, (data) {
      final result = callDecoder.decodeCall(data);
      evaluateCall(result);
    });
  }

  void evaluateCall(DecodedCall call) {
    switch(call.flag) {
      case CallType.preview:
        _currentColor = call.obj as Color;
        emit(StationDisplayColor(_currentColor));
        break;
      case CallType.unknown:
        Fluttertoast.showToast(msg: 'Unknown call');
        break;
      case CallType.connectionCheck:
        break;
    }
  }

}
