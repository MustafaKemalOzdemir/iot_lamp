part of 'station_cubit.dart';

abstract class StationState {
  const StationState();
}

class StationInitial extends StationState {
}

class StationDisplayColor extends StationState {
  final Color color;
  const StationDisplayColor(this.color);
}
