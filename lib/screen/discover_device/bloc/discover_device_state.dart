part of 'discover_device_cubit.dart';

abstract class DiscoverDeviceState {
  const DiscoverDeviceState();
}

class DiscoverDeviceInitial extends DiscoverDeviceState {

}

class DiscoverDeviceDisplayDevices extends DiscoverDeviceState {
  final List<DiscoveredDevice> devices;
  const DiscoverDeviceDisplayDevices(this.devices);
}

class DiscoverDeviceDeviceSelected extends DiscoverDeviceState {
  final DiscoveredDevice device;
  const DiscoverDeviceDeviceSelected(this.device);
}
