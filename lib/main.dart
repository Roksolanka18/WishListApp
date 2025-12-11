import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; 
import 'firebase_options.dart';
import 'wish_repository.dart';
import 'providers/create_edit_wish_provider.dart'; 
import 'notification_repository.dart'; 
import 'user_repository.dart'; 
import 'auth_repository.dart';// << НОВИЙ ІМПОРТ
import 'storage_repository.dart'; // << ІМПОРТ STORAGE

import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart'; 
import 'screens/notifications_screen.dart'; 
import 'screens/wish_item_details_screen.dart'; 
import 'screens/add_item_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'providers/wishlist_provider.dart'; 
import 'providers/notification_provider.dart'; 
import 'providers/app_user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final wishRepository = WishRepository(); 
  final notificationRepository = NotificationRepository();
  final userRepository = UserRepository(); 
  final authRepository = AuthRepository(); 
  final storageRepository = StorageRepository(); // << ІНІЦІАЛІЗАЦІЯ STORAGE

  runApp(
    MultiProvider(
      providers: [
        // 1. Реєстрація репозиторіїв
        Provider<BaseWishRepository>(create: (_) => wishRepository),
        Provider<BaseNotificationRepository>(create: (_) => notificationRepository), 
        Provider<UserRepository>(create: (_) => userRepository), 
        Provider<AuthRepository>(create: (_) => authRepository),
        Provider<StorageRepository>(create: (_) => storageRepository), // << РЕЄСТРАЦІЯ STORAGE

        // 2. Реєстрація провайдерів
        ChangeNotifierProvider(
          create: (_) => WishListProvider(wishRepository), // Завдання 4, 5 (Список)
        ),
        ChangeNotifierProvider(
          create: (_) => CreateEditWishProvider(wishRepository), // Завдання 5 (Форма)
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationRepository), // Завдання 5 (Сповіщення)
        ),
        ChangeNotifierProvider(
          create: (_) => AppUserProvider(userRepository, storageRepository), // Завдання 6 (Профіль)
        ),
      ],
      child: MyApp(), // Ваш головний віджет
    ),
  );
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
        '/profile': (context) => const ProfileScreen(), 
        '/notifications': (context) => const NotificationsScreen(), 
        '/wish_details': (context) => const WishItemDetailsScreen(), 
        '/add_item': (context) => const AddItemScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
    );
  }
}