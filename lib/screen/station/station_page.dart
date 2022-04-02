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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.get<StationCubit>()..initialize(),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity),
            BlocBuilder<StationCubit, StationState>(
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
                  color: color,
                );
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: const Text('Start'),
                  onPressed: () {
                    _station.start();
                  },
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  child: const Text('Stop'),
                  onPressed: () {
                    _station.stop();
                  },
                ),
              ],
            ),
          ],
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
