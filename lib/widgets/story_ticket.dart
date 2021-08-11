import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storify/pages/top_filter.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/services/rating.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:storify/services/database.dart';

// Here we are building all of the story tickets.
// Each story will have his own ticket, in the profile page or feed page
class StoryTickets extends StatelessWidget {
  final String storyPhoto;
  final String storyId; // To know where to go
  final String commentId; // To have comment id parameter
  final String ownerId; // To have the id of the owner of the story
  final String displayName;
  final String title;
  final List<String> categories;
  final dynamic rating;
  final Timestamp timestamp;
  final int countRating;

  StoryTickets({
    this.storyPhoto,
    this.title,
    this.storyId,
    this.commentId,
    this.ownerId,
    this.categories,
    this.rating,
    this.timestamp,
    this.displayName,
    this.countRating,
  });

  // Let us see all of the categories in the List
  getCategories() {
    List<Text> list = [];
    for (var category in categories) {
      list.add(
        new Text(category),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () async {
        await getAverageRatingFromStoriesRef(storyId);
        showReadStory(context,
            storyId: this.storyId, commentId: this.commentId, ownerId: ownerId);
      },
      child: Container(
        width: 330,
        height: 450,
        margin: EdgeInsets.all(12.0),
        child: Stack(
          fit: StackFit.loose,
          children: [
            Container(
              height: 300,
              width: 500,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(this.storyPhoto),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            Positioned(
              bottom: 25,
              child: Container(
                //alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Container(
                  height: 170,
                  width: 330,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        this.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: Colors.black),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // This code is fine, its not a bug!
                            for (var category in categories)
                              Text(
                                category + '  ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ratingStars(rating, 38.0, false),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 18.0,
                            color: Colors.black,
                          ),
                          Text(
                            ' ' + this.displayName + ' ',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            timeago.format(this.timestamp.toDate()),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          countRating == 1
                              ? Text(
                                  " " +
                                      countRating.toString() +
                                      " user rated this story",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16.0),
                                )
                              : Text(
                                  " " +
                                      countRating.toString() +
                                      " users rated this story",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16.0),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
    Building containers for all the widgets on the stack
  */
  Container buildContainer(Widget widget) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: widget);
  }
}
