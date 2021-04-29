import 'package:cloud_firestore/cloud_firestore.dart';

class ChatClass {
  final String id; // User id
  final String rid; // Room id
  final String sender; // DisplayName
  final String message;
  final String photoUrl;
  final DateTime timestamp;

  ChatClass({
    this.id,
    this.rid,
    this.sender,
    this.message,
    this.photoUrl,
    this.timestamp,
  });

  factory ChatClass.fromDocuments(DocumentSnapshot doc) {
    return ChatClass(
      id: doc.data()['id'],
      rid: doc.data()['rid'],
      sender: doc.data()['sender'],
      message: doc.data()['message'],
      photoUrl: doc.data()['photoUrl'],
      timestamp: doc.data()['timestamp'],
    );
  }
}
