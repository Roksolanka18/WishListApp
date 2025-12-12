import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? name; 
  final String? profilePictureUrl; 

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.profilePictureUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return AppUser(
      uid: snapshot.id,
      email: data['email'] as String,
      name: data['name'] as String?,
      profilePictureUrl: data['profile_picture_url'] as String?, 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      if (name != null) 'name': name,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl, 
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? profilePictureUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}