import 'package:flutter/cupertino.dart'; //the font package
import 'package:flutter/material.dart';
import 'read_story.dart';
import 'package:storify/pages/chat.dart';
import 'package:storify/widgets/story_ticket.dart'; //todo: pleas follow this  class
import 'package:lipsum/lipsum.dart' as lipsuam; //to show stam texts for example
import 'package:storify/widgets/header.dart';

//todo: read here
//==============================the main feed code================//
//pleas follow my comments

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with SingleTickerProviderStateMixin {
  //we work with the class list_item
  //and her constractor
  //to create a story ticket

  //TODO: use for each from firebase
  List<StoryTickets> tickets = [
    StoryTickets(
        "https://m.media-amazon.com/images/M/MV5BNWRiZGRjOGQtZjIzYy00MDc0LWIwYzktYTJlMTJlMWVkZjk5XkEyXkFqcGdeQXVyMjc4NzY1MTM@._V1_.jpg",
        "Escape from Alcatraz",
        "Action",
        "Raiting : 100",
        "13.04.2021",
        "nelson mandela"),
    StoryTickets(
        "https://picsum.photos/250?image=9",
        "Biggest story ever",
        "Adventure, Drama, Sci-fi",
        "Raiting : 100",
        "14.04.2021",
        "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Coolest story ever",
        "Action", "Raiting : 100", "14.04.2021", "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "14.04.2021", "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "14.04.2021", "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "13.04.2021", "Matan Baruch"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "13.04.2021", "Matan Baruch"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "13.04.2021", "Matan Baruch"),
  ];
//this is a part of the up menu
  //with all the tabs : all,top,popular...... 5 tabs
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Chat()));
            },
            color: Colors.black,
          ),
        ],
      ),
      //-------------------the end of the app bar----------//
      //now we use the lists to show them
      body: TabBarView(
        controller: tabController,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    //this method will show the story tickets
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

          //if you want to put list in other category put it inside the containers
          //each container include other category - those are the tabs
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
    );
  }
}
