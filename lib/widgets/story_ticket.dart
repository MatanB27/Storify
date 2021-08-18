import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/widgets/rating.dart';
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
    return Padding(
      padding: const EdgeInsets.only(top: 35.0),
      child: FlatButton(
        onPressed: () async {
          await getAverageRatingFromStoriesRef(storyId);
          showReadStory(context,
              storyId: this.storyId,
              commentId: this.commentId,
              ownerId: ownerId);
        },
        child: Container(
          width: double.infinity,
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // decoration: BoxDecoration(borderRadius: BorderRadius()),
                margin: EdgeInsets.only(top: 8.0, right: 8.0),
                padding: EdgeInsets.only(right: 2.0),
                height: 128,
                width: 100,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(50),
                // ),
                child: Image(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    this.storyPhoto,
                  ),
                ),
              ),
              SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          this.title,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // GestureDetector( TODO: delete
                        //   onTap: () {},
                        //   child: Icon(
                        //     Icons.bookmark_border,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      this.displayName,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ratingStars(rating, 15, false),
                            this.countRating > 0
                                ? Text(
                                    ' (' + this.countRating.toString() + ')',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic),
                                  )
                                : Text(''),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Row(
                        children: [
                          // This code is fine, its not a bug!
                          for (var category in categories)
                            Text(
                              category + '  ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          color: Colors.grey,
                          size: 22.0,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          this.timestamp.toDate().day.toString() +
                              '.' +
                              this.timestamp.toDate().month.toString() +
                              '.' +
                              this.timestamp.toDate().year.toString(),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
