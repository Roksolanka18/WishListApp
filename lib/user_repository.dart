// lib/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user.dart'; // Модель AppUser

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> get _userDocument {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in.");
    }
    return _firestore.collection('users').doc(uid);
  }

  // 1. Отримання даних профілю
  Future<AppUser> fetchUserProfile() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception("No user logged in.");
    }

    final docSnapshot = await _userDocument.get();

    if (docSnapshot.exists) {
      return AppUser.fromFirestore(docSnapshot);
    } else {
      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'N/A',
        name: 'User', 
      );
      await _userDocument.set(newUser.toFirestore());
      return newUser;
    }
  }

  // 2. Оновлення даних профілю (ім'я та/або URL фото)
  Future<void> updateUserNameAndPictureUrl({
    required String name,
    required String? profilePictureUrl, // << ДОДАНО
  }) async {
    // Використовуємо Map для оновлення лише потрібних полів
    Map<String, dynamic> updateData = {
      'name': name,
    };
    // Оновлюємо URL, тільки якщо він був наданий
    if (profilePictureUrl != null) {
      updateData['profile_picture_url'] = profilePictureUrl;
    } else {
      // Якщо фото було видалено, явно встановлюємо null (якщо це потрібно)
      // updateData['profile_picture_url'] = null;
    }

    await _userDocument.update(updateData);
  }
}