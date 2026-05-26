import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/complaints_provider.dart';
import 'providers/technicians_provider.dart';
import 'providers/users_provider.dart';
import 'providers/map_provider.dart';
import 'providers/scheduled_jobs_provider.dart';
import 'theme/app_theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => TechniciansProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => ScheduledJobsProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const TechServeApp(),
    ),
  );
}

class TechServeApp extends StatelessWidget {
  const TechServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final router = createRouter(auth);
    return MaterialApp.router(
      title: 'TechServe Admin',
      theme: AppTheme.theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}