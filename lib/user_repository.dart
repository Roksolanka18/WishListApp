import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user.dart'; 

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

  Future<void> updateUserNameAndPictureUrl({
    required String name,
    required String? profilePictureUrl, 
  }) async {
    Map<String, dynamic> updateData = {
      'name': name,
    };
    if (profilePictureUrl != null) {
      updateData['profile_picture_url'] = profilePictureUrl;
    } else {
      updateData['profile_picture_url'] = null;
    }

    await _userDocument.update(updateData);
  }
}