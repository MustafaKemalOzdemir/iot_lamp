part of 'light_settings_cubit.dart';

abstract class LightSettingsState extends Equatable {
  const LightSettingsState();
}

class LightSettingsInitial extends LightSettingsState {
  @override
  List<Object> get props => [];
}

class LightSettingsDisplayColor extends LightSettingsState{
  final Color color;
  const LightSettingsDisplayColor(this.color);

  @override
  List<Object?> get props => [color.value];
}

class LightSettingsDeviceManagerStateChange extends LightSettingsState {
  final DeviceManagerState currentState;
  const LightSettingsDeviceManagerStateChange(this.currentState);

  @override
  List<Object?> get props => [currentState];
}

class LightSettingsDisplayDeviceName extends LightSettingsState {
  final String deviceName;
  const LightSettingsDisplayDeviceName(this.deviceName);

  @override
  List<Object?> get props => [deviceName];
}
