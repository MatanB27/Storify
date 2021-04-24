import 'package:cloud_firestore/cloud_firestore.dart';

class ChatClass {
  final String id; //user id
  final String sender; //displayName
  final String message;
  final DateTime timestamp;

  ChatClass({
    this.id,
    this.sender,
    this.message,
    this.timestamp,
  });

  factory ChatClass.fromDocuments(DocumentSnapshot doc) {
    return ChatClass(
      id: doc.data()['id'],
      sender: doc.data()['sender'],
      message: doc.data()['message'],
      timestamp: doc.data()['timestamp'],
    );
  }
}
