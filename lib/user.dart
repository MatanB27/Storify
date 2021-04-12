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
      id: doc.data()['id'],
      email: doc.data()['email'],
      displayName: doc.data()['displayName'],
      photoUrl: doc.data()['photoUrl'],
      bio: doc.data()['bio'],
    );
  }
}
