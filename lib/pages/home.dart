import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/chat.dart';
import 'package:storify/pages/feed.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/pages/search.dart';
import 'package:storify/pages/upload_story.dart';
import '../user.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

//global variables:
//variable for signing in

UserClass currentUserHome; //current user
final DateTime timestampNow = DateTime.now(); //the time the user was created
final userRef = FirebaseFirestore.instance.collection('users'); //Users ref
final storageRef = FirebaseStorage.instance.ref(); //storage ref
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
    return Scaffold(
      body: PageView(
        children: [
          Feed(),
          Search(),
          UploadStory(), //TODO: use - currentUser
          Chat(chatId: auth.currentUser?.uid), // ? ignores nullu
          Profile(
            profileId: auth.currentUser?.uid, // ? ignores null
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChange,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: pageIndex,
        onTap: onClick,
        //when we press on icon, we will move to it page and the icon will
        //change his color
        backgroundColor: Colors.blueAccent,
        //navigator color
        items: [
          Icon(Icons.home, size: 30),
          Icon(Icons.search_rounded, size: 30),
          Icon(Icons.add_circle, size: 30),
          Icon(Icons.chat, size: 30),
          Icon(Icons.person_rounded, size: 30),
        ],
      ),
    );
  }
}
