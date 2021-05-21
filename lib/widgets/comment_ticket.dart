import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/services/rating.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentTicket extends StatelessWidget {
  final String uid; // user ID
  final String displayName;
  final String photoUrl;
  final Timestamp timeStamp;
  final String comment;
  final int rating;

  CommentTicket({
    this.displayName,
    this.photoUrl,
    this.uid,
    this.timeStamp,
    this.comment,
    this.rating,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showProfile(context, profileId: uid);
      },
      child: Card(
        color: Colors.blueGrey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(this.photoUrl),
              ),
              title: Text(
                this.displayName,
                style: TextStyle(fontSize: 18.0),
              ),
              subtitle: ratingStars(rating),
              isThreeLine: true,
            ),
            Text(
              this.comment,
              style: TextStyle(color: Colors.black, fontSize: 16.0),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              timeago.format(this.timeStamp.toDate()),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
