import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

/*
   Here we are building all of the chat history tickets
  According to the attributes
 */
class ChatHistory extends StatelessWidget {
  final String rid; // Room ID
  final String id; // User ID
  final String otherUserId; // Other user ID
  final String displayName;
  final String photoUrl;
  final String message;
  final Timestamp timeStamp;

  ChatHistory({
    this.rid,
    this.id,
    this.otherUserId,
    this.displayName,
    this.photoUrl,
    this.message,
    this.timeStamp,
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
        subtitle: Text(
          this.message,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          timeago.format(this.timeStamp.toDate()),
        ),
        dense: true,
        onTap: () {
          showPrivateMessage(context,
              privateId: this.otherUserId, roomId: this.rid);
        },
      ),
    );
  }
}
