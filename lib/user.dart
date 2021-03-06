import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;
  final String bio;

  User({
    this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.bio,
  });

  factory User.fromDocuments(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
    );
  }
}
