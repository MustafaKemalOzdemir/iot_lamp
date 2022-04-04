/*
 ** Created by Mustafa Kemal ÖZDEMİR on 3.04.2022 **
*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_playground/core/model/discovered_device.dart';
import 'package:iot_playground/screen/discover_device/bloc/discover_device_cubit.dart';

import '../../core/di/injection_container.dart';

class DiscoverDeviceScreen extends StatefulWidget {
  const DiscoverDeviceScreen({Key? key}) : super(key: key);

  @override
  _DiscoverDeviceScreenState createState() => _DiscoverDeviceScreenState();
}

class _DiscoverDeviceScreenState extends State<DiscoverDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.get<DiscoverDeviceCubit>()..discoverDevices(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover devices'),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.youtube_searched_for_rounded),
                  onPressed: () {
                    BlocProvider.of<DiscoverDeviceCubit>(context).discoverDevices();
                  },
                );
              }
            ),
          ],
        ),
        body: BlocBuilder<DiscoverDeviceCubit, DiscoverDeviceState>(
          buildWhen: (p, n) => n is DiscoverDeviceDisplayDevices,
          builder: (context, state) {
            final dataList = <DiscoveredDevice>[];
            if (state is DiscoverDeviceDisplayDevices) {
              dataList.addAll(state.devices);
            }
            if (dataList.isEmpty) {
              return const Center(
                child: Text('No device has been found'),
              );
            }
            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(dataList[index].ip), trailing: Text(dataList[index].name),);
              },
            );
          },
        ),
      ),
    );
  }
}
