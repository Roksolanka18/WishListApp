import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/wish_item.dart';

abstract class BaseWishRepository {
  Future<List<WishItem>> getWishes(); 
  
  Future<void> addWish(WishItem wish); 
  Future<void> updateWish(WishItem wish);
  Future<void> deleteWish(String id); 
  Future<void> toggleWishStatus(String id, WishStatus newStatus); 
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

  @override
  Future<List<WishItem>> getWishes() async {
    final snapshot = await _wishesCollection
        .orderBy('date_added', descending: true) 
        .get(); 
        
    return snapshot.docs.map((doc) => WishItem.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addWish(WishItem wish) async {
    await _wishesCollection.add(wish.toFirestore());
  }

  @override
  Future<void> updateWish(WishItem wish) async {
    await _wishesCollection.doc(wish.id).set(wish.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteWish(String id) async {
    await _wishesCollection.doc(id).delete();
  }

  @override
  Future<void> toggleWishStatus(String id, WishStatus newStatus) async {
    await _wishesCollection.doc(id).update({
      'status': newStatus.toFirestoreString(),
    });
  }
}