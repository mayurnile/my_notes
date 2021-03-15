import 'package:get/get.dart';

import './locator.dart';
import '../../providers/providers.dart';

void initProviders() {
  //auth Provider
  AuthProvider authProvider = Get.put(AuthProvider());
  locator.registerLazySingleton(() => authProvider);

  //notes Provider
  NotesProvider notesProvider = Get.put(NotesProvider());
  locator.registerLazySingleton(() => notesProvider);
}
