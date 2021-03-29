import 'package:cloud_firestore/cloud_firestore.dart';

class UserClass {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;
  final String bio;

  UserClass({
    this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.bio,
  });

  factory UserClass.fromDocuments(DocumentSnapshot doc) {
    return UserClass(
      id: doc['id'],
      email: doc['email'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
    );
  }
}
