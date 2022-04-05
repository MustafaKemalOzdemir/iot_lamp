/*
 ** Created by Mustafa Kemal ÖZDEMİR on 3.04.2022 **
*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_playground/core/model/discovered_device.dart';
import 'package:iot_playground/core/model/light_settings_argument.dart';
import 'package:iot_playground/core/router/app_routes.dart';
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
      create: (context) => sl.get<DiscoverDeviceCubit>()..discoverDevices(const Duration(seconds: 3)),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Builder(
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        const Text(
                          'Discover devices',
                          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.youtube_searched_for_rounded),
                          onPressed: () {
                            BlocProvider.of<DiscoverDeviceCubit>(context).discoverDevices();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                }
              ),
              Expanded(
                child: BlocBuilder<DiscoverDeviceCubit, DiscoverDeviceState>(
                  buildWhen: (p, n) => n is DiscoverDeviceDeviceSelected,
                  builder: (context, state) {
                    DiscoveredDevice? selectedDevice;
                    if (state is DiscoverDeviceDeviceSelected) {
                      selectedDevice = state.device;
                    }
                    return BlocBuilder<DiscoverDeviceCubit, DiscoverDeviceState>(
                      buildWhen: (p, n) => n is DiscoverDeviceDisplayDevices,
                      builder: (context, state) {
                        final dataList = <DiscoveredDevice>[];
                        if (state is DiscoverDeviceDisplayDevices) {
                          dataList.addAll(state.devices);
                        }
                        if (dataList.isEmpty) {
                          return const Center(child: Text('No device has been found'));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: dataList.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                BlocProvider.of<DiscoverDeviceCubit>(context).deviceSelected(dataList[index]);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    child: ListTile(
                                      leading: const Icon(Icons.lightbulb_outline_rounded),
                                      style: ListTileStyle.list,
                                      selected: dataList[index] == selectedDevice,
                                      title: Text(dataList[index].ip),
                                      trailing: Text(dataList[index].name),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              BlocBuilder<DiscoverDeviceCubit, DiscoverDeviceState>(
                buildWhen: (p, n) => n is DiscoverDeviceDisplayDevices,
                builder: (context, state) {
                  bool devicesFound = false;
                  if (state is DiscoverDeviceDisplayDevices) {
                    devicesFound = state.devices.isNotEmpty;
                  }
                  return BlocBuilder<DiscoverDeviceCubit, DiscoverDeviceState>(
                    buildWhen: (p, n) => n is DiscoverDeviceDeviceSelected,
                    builder: (context, state) {
                      DiscoveredDevice? selectedDevice;
                      if (state is DiscoverDeviceDeviceSelected) {
                        selectedDevice = state.device;
                      }
                      return Visibility(
                        visible: devicesFound,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  shape: MaterialStateProperty.all(BeveledRectangleBorder(borderRadius: BorderRadius.circular(8)))),
                              child: const Text('Connect Selected Device'),
                              onPressed: selectedDevice != null
                                  ? () {
                                      Navigator.of(context).pushNamed(AppRoutes.lightSettings, arguments: LightSettingsArguments(selectedDevice!)).then((value) {
                                        BlocProvider.of<DiscoverDeviceCubit>(context).discoverDevices();
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
