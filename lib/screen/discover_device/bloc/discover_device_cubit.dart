import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:iot_playground/core/model/discovered_device.dart';
import 'package:iot_playground/core/service/device_discover_service/device_discover_service.dart';

part 'discover_device_state.dart';

class DiscoverDeviceCubit extends Cubit<DiscoverDeviceState> {
  final DeviceDiscoverService discoverService;
  DiscoverDeviceCubit(this.discoverService) : super(DiscoverDeviceInitial());

  void discoverDevices() async{
    final discoveredDevices = await discoverService.discoverDevices();
    emit(DiscoverDeviceDisplayDevices(discoveredDevices));
  }
}
