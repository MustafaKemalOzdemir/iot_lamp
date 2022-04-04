/*
 ** Created by Mustafa Kemal ÖZDEMİR on 3.04.2022 **
*/
import 'package:iot_playground/core/service/call_builder/call_builder.dart';
import 'package:iot_playground/core/service/connection_manager/connection_manager.dart';
import 'package:iot_playground/core/service/device_manager/device_manager.dart';
import 'package:iot_playground/core/service/operation_manager/operation_manager.dart';
import 'package:iot_playground/core/service/queue_manager/queue_manager.dart';

abstract class DeviceManagerFactory {
  DeviceManager constructDeviceManager();
  DeviceManager constructManagerWithIp(String ip);
  DeviceManager? getManagerWithIp(String ip);
}
class DeviceManagerFactoryImpl implements DeviceManagerFactory {

  final _managers = <String, DeviceManager>{};

  @override
  DeviceManager constructDeviceManager() {
    final CallBuilder callBuilder = CallBuilderImpl();
    final ConnectionManager connectionManager = ConnectionManagerImpl(callBuilder);
    final OperationManager operationManager = OperationManagerImpl(callBuilder: callBuilder, connectionManager: connectionManager);
    final QueueManager queueManager = QueueManagerImpl(operationManager: operationManager);
    final DeviceManager deviceManager = DeviceManagerImpl(queueManager: queueManager, connectionManager: connectionManager);
    return deviceManager;
  }

  @override
  DeviceManager constructManagerWithIp(String ip) {
    final manager = _managers[ip];
    if(manager == null) {
      final generated = constructDeviceManager();
      _managers[ip] = generated;
      return generated;
    }else {
      return manager;
    }
  }

  @override
  DeviceManager? getManagerWithIp(String ip) {
    return _managers[ip];
  }

}