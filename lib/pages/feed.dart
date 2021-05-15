import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart'; //the font package
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'read_story.dart';
import 'package:storify/widgets/story_ticket.dart';

//todo: read here
//==============================the main feed code================//
//pleas follow my comments

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with SingleTickerProviderStateMixin {
  // We work with the class list_item
  // And her constructor
  // To create a story ticket

  //TODO: use for each from firebase
  List<StoryTickets> tickets = [
    StoryTickets(
      title: 'wow1232132123231232131',
      displayName: '123',
      timestamp: Timestamp.now(),
      categories: ['123', '234'],
      rating: '123',
      storyPhoto:
          "https://m.media-amazon.com/images/M/MV5BNWRiZGRjOGQtZjIzYy00MDc0LWIwYzktYTJlMTJlMWVkZjk5XkEyXkFqcGdeQXVyMjc4NzY1MTM@._V1_.jpg",
    ),
    StoryTickets(
      title: 'wow',
      displayName: '123',
      timestamp: Timestamp.now(),
      categories: ['123', '432', '421'],
      rating: '123',
      storyPhoto:
          "https://m.media-amazon.com/images/M/MV5BNWRiZGRjOGQtZjIzYy00MDc0LWIwYzktYTJlMTJlMWVkZjk5XkEyXkFqcGdeQXVyMjc4NzY1MTM@._V1_.jpg",
    ),
    StoryTickets(
      title: 'wow',
      displayName: '123',
      timestamp: Timestamp.now(),
      categories: ['123'],
      rating: '123',
      storyPhoto:
          "https://m.media-amazon.com/images/M/MV5BNWRiZGRjOGQtZjIzYy00MDc0LWIwYzktYTJlMTJlMWVkZjk5XkEyXkFqcGdeQXVyMjc4NzY1MTM@._V1_.jpg",
    ),
    StoryTickets(
      title: 'wow',
      displayName: '123',
      timestamp: Timestamp.now(),
      categories: ['123'],
      rating: '123',
      storyPhoto:
          "https://m.media-amazon.com/images/M/MV5BNWRiZGRjOGQtZjIzYy00MDc0LWIwYzktYTJlMTJlMWVkZjk5XkEyXkFqcGdeQXVyMjc4NzY1MTM@._V1_.jpg",
    ),
    StoryTickets(
      title: 'wow',
      displayName: '123',
      timestamp: Timestamp.now(),
      categories: ['123', '567', '321'],
      rating: '123',
      storyPhoto:
          "https://m.media-amazon.com/images/M/MV5BNWRiZGRjOGQtZjIzYy00MDc0LWIwYzktYTJlMTJlMWVkZjk5XkEyXkFqcGdeQXVyMjc4NzY1MTM@._V1_.jpg",
    ),
  ];
  // This is a part of the top menu
  // With all the tabs : all,top,popular...... 5 tabs
  List<Tab> tabList = [
    Tab(
      child: Text('all'),
    ),
    Tab(
      child: Text('popular'),
    ),
    Tab(
      child: Text('top'),
    ),
    Tab(
      child: Text('editor choice'),
    ),
    Tab(
      child: Text('category'),
    ),
  ];

  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabList.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // When we pull the page, it will refresh it and fetch the new data.
  Future<Null> pullToRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      //TODO: Updating the stories on refresh.
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        //the app bar code with the title, the tab menu and the chat button
        appBar: AppBar(
          toolbarHeight: 110.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'storify',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: TabBar(
              indicatorColor: Colors.black,
              isScrollable: true,
              controller: tabController,
              tabs: tabList,
              labelColor: Colors.black,
            ),
          ),
        ),
        //-------------------the end of the app bar----------//
        //now we use the lists to show them
        body: TabBarView(
          controller: tabController,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                child: RefreshIndicator(
                  onRefresh: pullToRefresh,
                  child: ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadStory(),
                              ));
                        },
                        child: tickets[index],
                      );
                    },
                  ),
                ),
              ),
            ),

            // If you want to put list in other category put it inside the containers
            // Each container include other category - those are the tabs
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
