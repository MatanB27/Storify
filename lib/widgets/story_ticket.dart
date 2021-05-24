import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:storify/services/database.dart';

//TODO: improve UI
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
  final String rating; //TODO: might delete
  final Timestamp timestamp;

  StoryTickets(
      {this.storyPhoto,
      this.title,
      this.storyId,
      this.commentId,
      this.ownerId,
      this.categories,
      this.rating, //TODO: might delete
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
      child: Card(
        elevation: 2.0,
        margin: EdgeInsets.only(bottom: 20.0),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 65.0,
                    width: 65.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(this.storyPhoto),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 20.0,
                      ),
                      Text(
                        this.displayName,
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      this.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      child: Row(children: <Widget>[
                        // This code is fine, its not a bug!
                        for (var category in categories)
                          Text(
                            category + '  ',
                            style: TextStyle(color: Colors.grey[700]),
                          )
                      ]),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 5.0,
                        ),
                        // Icon(Icons.star), //TODO - rating - might delete
                        // Text(
                        //   this.rating,
                        //   style: TextStyle(
                        //     fontSize: 15,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(Icons.date_range),
                        Text(
                          timeago.format(this.timestamp.toDate()),
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
