/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_playground/core/service/station/station.dart';
import 'package:iot_playground/screen/station/bloc/station_cubit.dart';

import '../../core/di/injection_container.dart';

class StationPage extends StatefulWidget {
  const StationPage({Key? key}) : super(key: key);

  @override
  _StationPageState createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  final _station = sl.get<Station>();

  @override
  void initState() {
    _station.start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.get<StationCubit>()..initialize(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Device Interface', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: Center(
                  child: BlocBuilder<StationCubit, StationState>(
                    buildWhen: (p, n) => n is StationDisplayColor,
                    builder: (context, state) {
                      late Color color;
                      if(state is StationDisplayColor) {
                        color = state.color;
                      }else {
                        color = BlocProvider.of<StationCubit>(context).currentColor;
                      }
                      return Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),

                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _station.stop();
    super.dispose();
  }

}
