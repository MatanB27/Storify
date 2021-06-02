import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart'; //the font package
import 'package:storify/pages/feed_filter.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/pages/top_filter.dart';
import 'package:storify/pages/categories_filter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/pages/all_filter.dart';
import 'package:storify/services/database.dart';
import 'read_story.dart';
import 'package:storify/widgets/story_ticket.dart';

//==============================the main feed code================//
//pleas follow my comments

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with SingleTickerProviderStateMixin {
  /*
     This is a part of the top menu
    With all the tabs : all,top,popular...... 5 tabs

  */
  List<Tab> tabList = [
    Tab(
      child: Text('Feed'),
    ),
    Tab(
      child: Text('All'),
    ),
    Tab(
      child: Text('Top'),
    ),
    Tab(
      child: Text('Categories'),
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
          /*
            The tabs - we can switch between those pages in the "Home" page.
           */
          children: [
            FeedFilter(
              userId: auth.currentUser?.uid,
            ),
            AllFilter(
              userId: auth.currentUser?.uid,
            ),
            TopFilter(userId: auth.currentUser?.uid),
            CategoriesFilter(userId: auth.currentUser?.uid),
          ],
        ),
      ),
    );
  }
}
