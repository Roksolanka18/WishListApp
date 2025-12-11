// lib/storage_repository.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User is not authenticated. Cannot upload files.");
    }
    return uid;
  }

  // 1. Завантаження файлу та повернення його URL
  Future<String> uploadProfilePicture(File imageFile) async {
    final uid = _currentUserId;
    
    // Шлях: users/{uid}/profile_picture.jpg
    final storageRef = _storage
        .ref()
        .child('users')
        .child(uid)
        .child('profile_picture.jpg'); 

    // Завдання на завантаження
    final uploadTask = storageRef.putFile(imageFile);

    // Очікування завершення завантаження
    final snapshot = await uploadTask.whenComplete(() {});

    // Отримання URL для доступу до файлу
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // 2. Видалення файлу
  Future<void> deleteFileByUrl(String imageUrl) async {
    try {
      final storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      // Ігноруємо помилки, якщо файл вже не існує
      print("Error deleting image: $e");
    }
  }
}