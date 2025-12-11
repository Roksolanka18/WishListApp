// lib/wish_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/wish_item.dart';

abstract class BaseWishRepository {
  // Завдання 4: Отримання списку бажань (використовуємо Future)
  Future<List<WishItem>> getWishes(); 
  
  // Методи CRUD (Завдання 3)
  Future<void> addWish(WishItem wish); // FR3
  Future<void> updateWish(WishItem wish); // FR4
  Future<void> deleteWish(String id); // FR5
  Future<void> toggleWishStatus(String id, WishStatus newStatus); // FR7
}

class WishRepository implements BaseWishRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User is not authenticated. Cannot access wish list.");
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _wishesCollection {
    final uid = _currentUserId;
    return _firestore.collection('users').doc(uid).collection('wishes');
  }

  // 4. Реалізація getWishes() з поверненням Future
  @override
  Future<List<WishItem>> getWishes() async {
    final snapshot = await _wishesCollection
        .orderBy('date_added', descending: true) // FR9: Сортування
        .get(); 
        
    return snapshot.docs.map((doc) => WishItem.fromFirestore(doc)).toList();
  }

  // 3. Реалізація addWish() (FR3)
  @override
  Future<void> addWish(WishItem wish) async {
    await _wishesCollection.add(wish.toFirestore());
  }

  // 3. Реалізація updateWish() (FR4)
  @override
  Future<void> updateWish(WishItem wish) async {
    await _wishesCollection.doc(wish.id).set(wish.toFirestore(), SetOptions(merge: true));
  }

  // 3. Реалізація deleteWish() (FR5)
  @override
  Future<void> deleteWish(String id) async {
    await _wishesCollection.doc(id).delete();
  }

  // 3. Реалізація toggleWishStatus() (FR7)
  @override
  Future<void> toggleWishStatus(String id, WishStatus newStatus) async {
    await _wishesCollection.doc(id).update({
      'status': newStatus.toFirestoreString(),
    });
  }
}