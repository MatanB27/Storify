import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

//we are seeing the chat history tickets.
class ChatHistory extends StatelessWidget {
  final String id;
  final String displayName;
  final String photoUrl;
  final String lastMessage;
  final DateTime timestamp;

  ChatHistory({
    this.id,
    this.displayName,
    this.photoUrl,
    this.lastMessage,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(this.photoUrl),
        ),
        title: Text(
          this.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Expanded(
          child: Text(this.lastMessage),
        ),
        trailing: Text(
          timeago.format(timestamp),
        ), //TODO: check if its true
        dense: true,
      ),
      onPressed: () {
        //TODO: go to private convo
      },
    );
  }
}
