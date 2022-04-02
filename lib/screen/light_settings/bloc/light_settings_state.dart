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
