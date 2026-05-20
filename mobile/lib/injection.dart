import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Firebase initialization
  await Firebase.initializeApp();

  // Register Firebase services
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Example of a repository registration (dummy)
  // getIt.registerLazySingleton<IncidentRepository>(() => IncidentRepositoryImpl());
}
