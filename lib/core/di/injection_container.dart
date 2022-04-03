/*
 ** Created by Mustafa Kemal ÖZDEMİR on 31.03.2022 **
*/
import 'package:get_it/get_it.dart';
import 'package:iot_playground/core/call_decoder/call_decoder.dart';
import 'package:iot_playground/core/service/device_manager_factory/device_manager_factory.dart';
import 'package:iot_playground/core/service/station/station.dart';
import 'package:iot_playground/screen/light_settings/bloc/light_settings_cubit.dart';
import 'package:iot_playground/screen/station/bloc/station_cubit.dart';

final sl = GetIt.instance;

void initializeDi() {
  sl.registerLazySingleton<Station>(() => StationImpl());
  sl.registerLazySingleton<CallDecoder>(() => CallDecoderImpl());
  sl.registerLazySingleton<DeviceManagerFactory>(() => DeviceManagerFactoryImpl());

  //bloc
  sl.registerFactory(() => LightSettingsCubit());
  sl.registerFactory(() => StationCubit(sl.get(), sl.get()));

}