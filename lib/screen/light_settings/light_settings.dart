/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'package:flutter/material.dart';
import 'package:iot_playground/core/di/injection_container.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iot_playground/core/model/light_settings_argument.dart';
import 'package:iot_playground/screen/light_settings/bloc/light_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LightSettings extends StatefulWidget {
  const LightSettings({Key? key}) : super(key: key);

  @override
  _LightSettingsState createState() => _LightSettingsState();
}

class _LightSettingsState extends State<LightSettings> {
  final nameFieldController = TextEditingController();
  final bloc = sl.get<LightSettingsCubit>();
  final nameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments as LightSettingsArguments;
    if (!bloc.isInitialized) {
      bloc.initializeCubit(argument.device);
      nameFieldController.text = argument.device.name;
    }
    return BlocProvider(
      create: (context) => bloc,
      child: Builder(builder: (context) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  nameFocus.unfocus();
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          BlocBuilder<LightSettingsCubit, LightSettingsState>(
                            buildWhen: (p, n) => n is LightSettingsDisplayDeviceName,
                            builder: (context, state) {
                              String name = argument.device.name;
                              if(state is LightSettingsDisplayDeviceName) {
                                name = state.deviceName;
                              }
                              return Text(
                                name,
                                style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: BlocBuilder<LightSettingsCubit, LightSettingsState>(
                                buildWhen: (p, n) => n is LightSettingsDeviceManagerStateChange,
                                builder: (context, state) {
                                  String currentState = "Unknown";
                                  if (state is LightSettingsDeviceManagerStateChange) {
                                    currentState = state.currentState.name;
                                  }
                                  return Text(
                                    currentState,
                                    style: const TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w500),
                                  );
                                },
                              ),
                            ),
                          ),
                          BlocBuilder<LightSettingsCubit, LightSettingsState>(
                            buildWhen: (p, n) => n is LightSettingsDisplayColor,
                            builder: (context, state) {
                              late Color currentColor;
                              if (state is LightSettingsDisplayColor) {
                                currentColor = state.color;
                              } else {
                                currentColor = context.read<LightSettingsCubit>().currentColor;
                              }
                              return ColorPicker(
                                pickerColor: currentColor,
                                onColorChanged: (Color color) {
                                  BlocProvider.of<LightSettingsCubit>(context).onColorSelected(color);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: TextField(
                              controller: nameFieldController,
                              focusNode: nameFocus,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                child: const Text('Update'),
                                onPressed: () {
                                  BlocProvider.of<LightSettingsCubit>(context).updateDeviceName(nameFieldController.text.trim());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
