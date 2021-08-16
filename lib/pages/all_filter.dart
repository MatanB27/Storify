import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/widgets/story_ticket.dart';

/*
  The page where the user can see ALL of the stories in Storify

*/
class AllFilter extends StatefulWidget {
  // Our own userId
  final String userId;
  final List<String> categoriesFilter;

  AllFilter({this.userId, this.categoriesFilter});
  @override
  _AllFilterState createState() => _AllFilterState();
}

class _AllFilterState extends State<AllFilter> {
  /*
    The method that will give us all the stories from firebase
  */
  allFilter() {
    return FutureBuilder(
      future: storiesRef
          .where('categories', arrayContainsAny: widget.categoriesFilter)
          .orderBy('timeStamp', descending: true)
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
            rating: story.data()['average'], //TODO: maybe delete
            storyPhoto: story.data()['storyPhoto'],
            timestamp: story.data()['timeStamp'],
            title: story.data()['title'],
            countRating: story.data()['countRating'],
          );
          tickets.add(ticket);
        }
        return ListView(
          physics: BouncingScrollPhysics(),
          children: tickets,
        );
      },
    );
  }

  // When we pull the page, it will refresh it and fetch the new data.
  Future<Null> pullToRefresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      allFilter();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Color(0xff09031D),
        body: RefreshIndicator(
          onRefresh: pullToRefresh,
          child: allFilter(),
        ),
      ),
    );
  }
}
