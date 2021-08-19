import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:storify/services/database.dart';
import 'package:storify/widgets/loading.dart';
import 'package:storify/widgets/story_ticket.dart';

class Favorites extends StatefulWidget {
  final String currentUserId;
  Favorites({this.currentUserId});
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  void initState() {
    super.initState();
    print(widget.currentUserId);
  }

  buildFavorites() {
    return FutureBuilder(
      future: storiesRef
          .where('favorites', arrayContains: widget.currentUserId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingCircular();
        }
        final stories = snapshot.data.docs;
        List<StoryTickets> tickets = [];
        for (var story in stories) {
          List<String> categories = List.from(story.data()['categories']);
          StoryTickets ticket = StoryTickets(
            displayName: story.data()['displayName'],
            categories: categories,
            storyId: story.data()['sid'],
            commentId: story.data()['cid'],
            ownerId: story.data()['uid'],
            rating: story.data()['average'],
            storyPhoto: story.data()['storyPhoto'],
            timestamp: story.data()['timeStamp'],
            title: story.data()['title'],
            countRating: story.data()['countRating'],
          );
          tickets.add(ticket);
        }
        return ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: tickets,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff09031D),
        appBar: AppBar(
          toolbarHeight: 120.0,
          flexibleSpace: SafeArea(
            child: Container(
              height: 120,
              color: Color(0xff09031D),
              child: Column(
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    'Favorites',
                    style: TextStyle(color: Colors.white, fontSize: 30.0),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'All of your favorites stories in one place.',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
        body: buildFavorites());
  }
}
