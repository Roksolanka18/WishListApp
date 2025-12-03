import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (erroDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(erroDetails);
  };

  PlatformDispatcher.instance.onError = (err, stack) {
    FirebaseCrashlytics.instance.recordError(err, stack);
    return true;};
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Wishlist',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDF6F9),
        useMaterial3: true,
      ),
      
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
