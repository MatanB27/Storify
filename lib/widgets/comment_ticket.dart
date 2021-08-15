import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/widgets/rating.dart';
import 'package:timeago/timeago.dart' as timeago;

/*
  This page is the comment tickets in the comment's page
  It will show the UI with the current data from firebaes
 */
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
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                elevation: 5,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Color(0xff6F61E8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        this.comment,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ratingStars(rating, 25.0, true),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(this.photoUrl),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                this.displayName,
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                timeago.format(this.timeStamp.toDate()),
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ],
          ),
        ));
  }
}
