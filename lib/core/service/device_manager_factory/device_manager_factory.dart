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
}
class DeviceManagerFactoryImpl implements DeviceManagerFactory {

  @override
  DeviceManager constructDeviceManager() {
    final CallBuilder callBuilder = CallBuilderImpl();
    final ConnectionManager connectionManager = ConnectionManagerImpl(callBuilder);
    final OperationManager operationManager = OperationManagerImpl(callBuilder: callBuilder, connectionManager: connectionManager);
    final QueueManager queueManager = QueueManagerImpl(operationManager: operationManager);
    final DeviceManager deviceManager = DeviceManagerImpl(queueManager: queueManager, connectionManager: connectionManager);
    return deviceManager;
  }

}