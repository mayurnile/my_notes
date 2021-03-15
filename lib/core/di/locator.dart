import 'package:get_it/get_it.dart';

import '../core.dart';
import './provider_injection.dart';

final locator = GetIt.instance;

void init() {
  //navigation service
  locator.registerLazySingleton(() => NavigationService());

  //providers
  initProviders();
}
