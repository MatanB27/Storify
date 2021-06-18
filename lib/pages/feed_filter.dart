import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/widgets/story_ticket.dart';

/*
  The main page, the user can read the stories of the users he follow

*/
class FeedFilter extends StatefulWidget {
  final String userId;
  final List<String> categoriesFilter;
  FeedFilter({this.userId, this.categoriesFilter});

  @override
  _FeedFilterState createState() => _FeedFilterState();
}

class _FeedFilterState extends State<FeedFilter> {
  // When we pull the page, it will refresh it and fetch the new data.
  Future<Null> pullToRefresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      buildFeed();
    });
    return null;
  }

  /*
    The body of the Feed tab - will show us only the stories of the users
    we are following
  */
  buildFeed() {
    return FutureBuilder(
      future: storiesRef
          .where('followers', arrayContains: widget.userId)
          .orderBy('timeStamp', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
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
            rating: story.data()['rating'].toString(), //TODO: maybe delete
            storyPhoto: story.data()['storyPhoto'],
            timestamp: story.data()['timeStamp'],
            title: story.data()['title'],
          );
          tickets.add(ticket);
        }
        return ListView(
          children: tickets,
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: delete
    super.initState();
    print(widget.categoriesFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: pullToRefresh,
          child: // Will show it loading if the list is empty
              buildFeed(),
        ),
      ),
    );
  }
}
