import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'core/theme/app_theme.dart';
import 'presentation/routes.dart';
import 'injection.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies(); // registers services, repositories, etc.
  runApp(const CIROApp());
}

class CIROApp extends StatelessWidget {
  const CIROApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = createRouter();
    return MaterialApp.router(
      title: 'CIRO',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
