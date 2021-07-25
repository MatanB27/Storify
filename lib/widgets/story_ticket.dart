import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/services/rating.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:storify/services/database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  StoryTickets(
      {this.storyPhoto,
      this.title,
      this.storyId,
      this.commentId,
      this.ownerId,
      this.categories,
      this.rating,
      this.timestamp,
      this.displayName});

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
        height: 500,
        margin: EdgeInsets.all(12.0),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.loose,
          children: [
            Container(
              height: 400,
              width: 500,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(this.storyPhoto),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            Positioned(
              bottom: 200,
              child: buildContainer(
                Text(
                  ' ' + this.title + ' ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              child: buildContainer(
                ratingStars(rating, 42.0, false),
              ),
            ),
            Positioned(
              bottom: 55,
              left: 10,
              child: buildContainer(
                Row(
                  children: [
                    Icon(
                      Icons.person,
                    ),
                    Text(
                      ' ' + this.displayName + ' ',
                      style: TextStyle(fontSize: 21.0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 85,
              child: buildContainer(
                Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      timeago.format(this.timestamp.toDate()),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 172,
              child: buildContainer(
                Container(
                  child: Row(children: <Widget>[
                    // This code is fine, its not a bug!
                    for (var category in categories)
                      Text(
                        ' ' + category + '  ',
                        style: TextStyle(fontSize: 18.0),
                      )
                  ]),
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
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: widget);
  }
}
