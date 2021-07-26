import 'package:get/get.dart';

import '../../providers/providers.dart';
import './locator.dart';

void initProviders() {
  //auth Provider
  final AuthProvider authProvider = Get.put(AuthProvider());
  locator.registerLazySingleton(() => authProvider);

  //notes Provider
  final NotesProvider notesProvider = Get.put(NotesProvider());
  locator.registerLazySingleton(() => notesProvider);
}
