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

  // завантаження файлу та повернення його URL
  Future<String> uploadProfilePicture(File imageFile) async {
    final uid = _currentUserId;
    
    // шлях users/{uid}/profile_picture
    final storageRef = _storage
        .ref()
        .child('users')
        .child(uid)
        .child('profile_picture.jpg'); 

    final uploadTask = storageRef.putFile(imageFile);

    final snapshot = await uploadTask.whenComplete(() {});

    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteFileByUrl(String imageUrl) async {
    try {
      final storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}