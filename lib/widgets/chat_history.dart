import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storify/pages/home.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

//we are seeing the chat history tickets.
class ChatHistory extends StatelessWidget {
  final String id;
  final String displayName;
  final String photoUrl;
  final String message;
  final DateTime timestamp;

  ChatHistory({
    this.id,
    this.displayName,
    this.photoUrl,
    this.message,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.0,
          backgroundImage: CachedNetworkImageProvider(this.photoUrl),
        ),
        title: Text(
          this.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Expanded(
          child: Text(this.message),
        ),
        trailing: Text(
          timeago.format(timestamp),
        ), //TODO: check if its true
        dense: true,
        onTap: () {
          print('hello');
        },
      ),
    );
  }
}
