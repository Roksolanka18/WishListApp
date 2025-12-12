import 'package:cloud_firestore/cloud_firestore.dart'; 

enum WishStatus { Wanted, Purchased }

extension WishStatusExtension on WishStatus {
  String toFirestoreString() {
    return toString().split('.').last;
  }
}

class WishItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final double cost;
  final DateTime dateAdded;
  final WishStatus status;

  WishItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cost,
    required this.dateAdded,
    this.status = WishStatus.Wanted,
  });

  // читання даних з Firestore
  factory WishItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return WishItem(
      id: snapshot.id,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      cost: (data['cost'] as num).toDouble(),
      dateAdded: (data['date_added'] as Timestamp).toDate(),
      status: data['status'] == WishStatus.Purchased.toFirestoreString() 
          ? WishStatus.Purchased 
          : WishStatus.Wanted,
    );
  }

  // запис даних у Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'cost': cost,
      'date_added': Timestamp.fromDate(dateAdded),
      'status': status.toFirestoreString(),
    };
  }

  // оновлення полів
  WishItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? cost,
    DateTime? dateAdded,
    WishStatus? status,
  }) {
    return WishItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      dateAdded: dateAdded ?? this.dateAdded,
      status: status ?? this.status,
    );
  }
}