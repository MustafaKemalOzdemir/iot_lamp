/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'package:flutter/material.dart';
import 'package:iot_playground/core/di/injection_container.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iot_playground/screen/light_settings/bloc/light_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LightSettings extends StatefulWidget {
  const LightSettings({Key? key}) : super(key: key);

  @override
  _LightSettingsState createState() => _LightSettingsState();
}

class _LightSettingsState extends State<LightSettings> {
  final ipFieldController = TextEditingController();

  @override
  void initState() {
    Future.microtask(() {
      ipFieldController.text = "192.168.1.151";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.get<LightSettingsCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Light settings')),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<LightSettingsCubit, LightSettingsState>(
                    buildWhen: (p,n) => n is LightSettingsDisplayColor,
                    builder: (context, state) {
                      late Color currentColor;
                      if(state is LightSettingsDisplayColor) {
                        currentColor = state.color;
                      }else {
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
                      controller: ipFieldController,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        child: const Text('connect'),
                        onPressed: () {
                          BlocProvider.of<LightSettingsCubit>(context).init(ipFieldController.text);
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        child: const Text('send'),
                        onPressed: () {
                          BlocProvider.of<LightSettingsCubit>(context).send();
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      ElevatedButton(
                        child: const Text('manual init'),
                        onPressed: () {
                          BlocProvider.of<LightSettingsCubit>(context).manualInit(ipFieldController.text);
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        child: const Text('manual send'),
                        onPressed: () {
                          BlocProvider.of<LightSettingsCubit>(context).manualSend();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
