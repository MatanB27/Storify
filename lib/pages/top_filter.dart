import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/widgets/story_ticket.dart';

/*
  The page where the user can see the highest stories rating in Storify
*/
class TopFilter extends StatefulWidget {
  final String userId;
  final List<String> categoriesFilter;
  TopFilter({this.userId, this.categoriesFilter});
  @override
  _TopFilterState createState() => _TopFilterState();
}

class _TopFilterState extends State<TopFilter> {
  // When we pull the page, it will refresh it and fetch the new data.
  Future<Null> pullToRefresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      TopFilter();
    });
    return null;
  }

  /*
    The method that will give us all the stories from firebase
    From the highest rating to the lowest.
  */

  topFilter() {
    return FutureBuilder(
      future: storiesRef
          .where('categories', arrayContainsAny: widget.categoriesFilter)
          .orderBy('average', descending: true)
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
            rating: story.data()['average'],
            storyPhoto: story.data()['storyPhoto'],
            timestamp: story.data()['timeStamp'],
            title: story.data()['title'],
          );
          tickets.add(ticket);
        }
        return ListView(
          scrollDirection: Axis.horizontal,
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
        backgroundColor: Color(0xff09031D),
        body: RefreshIndicator(
          onRefresh: pullToRefresh,
          child: topFilter(),
        ),
      ),
    );
  }
}
