import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/feed.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/pages/search.dart';
import 'package:storify/pages/uploadStory.dart';
import '../user.dart';
import 'chat.dart';

//global variables:
//variable for signing in

UserClass currentUserHome; //current user
final DateTime timestampNow = DateTime.now(); //the time the user was created
final userRef = FirebaseFirestore.instance.collection('users'); //Users ref
AuthService auth = new AuthService();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController; //we use it to control our page selection
  int pageIndex = 0; // current page index we are in

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChange(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onClick(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.elasticOut);
  }

  @override
  Widget build(BuildContext context) {
    //if the user is logged in he will see this page
    //in homePage the user is navigating through all the main pages of the app:
    //feed - where the user can see all the stories
    //search - where the user can search for other users profile
    //upload Story - where the user can upload it own story
    //chat - the user can chat with other people in the app
    //profile - the user profile page
    //TODO: use APPBar
    return Scaffold(
      body: PageView(
        children: [
          Feed(), //TODO: is closed temporary so we can use the log out func
          UploadStory(), //TODO: use - currentUser
          Profile(
            profileId: auth.currentUser.uid,
          ), //TODO: use profileId - currentUser?.id
        ],
        controller: pageController,
        onPageChanged: onPageChange,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onClick,
        //when we press on icon, we will move to it page and the icon will
        //change his color
        activeColor: Theme.of(context).accentColor,
        backgroundColor: Colors.grey[200],
        //navigator color
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              size: 42.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),

    );
  }
}

