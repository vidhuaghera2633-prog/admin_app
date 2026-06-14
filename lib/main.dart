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
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stackTrace) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint(stackTrace.toString());
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize Firebase',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

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