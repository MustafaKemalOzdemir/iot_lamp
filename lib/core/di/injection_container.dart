/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'package:get_it/get_it.dart';
import 'package:iot_playground/core/call_decoder/call_decoder.dart';
import 'package:iot_playground/core/preference_manager/preference_manager.dart';
import 'package:iot_playground/core/service/call_builder/call_builder.dart';
import 'package:iot_playground/core/service/device_discover_service/device_discover_service.dart';
import 'package:iot_playground/core/service/device_manager_factory/device_manager_factory.dart';
import 'package:iot_playground/core/service/station/station.dart';
import 'package:iot_playground/screen/discover_device/bloc/discover_device_cubit.dart';
import 'package:iot_playground/screen/light_settings/bloc/light_settings_cubit.dart';
import 'package:iot_playground/screen/station/bloc/station_cubit.dart';

final sl = GetIt.instance;

void initializeDi() {
  sl.registerLazySingleton<Station>(() => StationImpl(sl.get(), sl.get(), sl.get()));
  sl.registerLazySingleton<CallDecoder>(() => CallDecoderImpl());
  sl.registerSingleton<DeviceManagerFactory>(DeviceManagerFactoryImpl());

  sl.registerSingleton<PreferenceManager>(PreferenceManagerImpl());
  sl.registerLazySingleton<CallBuilder>(() => CallBuilderImpl());
  sl.registerLazySingleton<DeviceDiscoverService>(() => DeviceDiscoverServiceImpl(sl.get(), sl.get(), sl.get()));

  //bloc
  sl.registerFactory(() => LightSettingsCubit());
  sl.registerFactory(() => StationCubit(sl.get(), sl.get()));
  sl.registerFactory(() => DiscoverDeviceCubit(sl.get()));

}