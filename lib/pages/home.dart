import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/pages/chat.dart';
import 'package:storify/pages/feed.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/pages/search.dart';
import 'package:storify/pages/upload_story.dart';
import 'package:storify/user.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

// Global variables:

UserClass currentUserHome; //current user
DateTime timestampNow = DateTime.now(); // The time the user was created
final userRef = FirebaseFirestore.instance.collection('users'); // Users ref
final storageRef = FirebaseStorage.instance.ref(); // Storage ref
final chatRef = FirebaseFirestore.instance.collection('chatrooms'); // Chat ref
final messageRef =
    FirebaseFirestore.instance.collection('messages'); // MessageRef
final followingRef =
    FirebaseFirestore.instance.collection('following'); // Following ref
final followersRef =
    FirebaseFirestore.instance.collection('followers'); // Followers ref
final storiesRef =
    FirebaseFirestore.instance.collection('stories'); // Stories ref
final commentsRef =
    FirebaseFirestore.instance.collection('comments'); // Comments ref

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
          UploadStory(userId: auth.currentUser?.uid),
          Chat(chatId: auth.currentUser?.uid), // ? ignores null
          Profile(
            profileId: auth.currentUser?.uid, // ? ignores null
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChange,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: pageIndex,
        onTap: onClick,
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
            selectedColor: Colors.pink,
          ),

          /// Add
          SalomonBottomBarItem(
            icon: Icon(Icons.add),
            title: Text("Add"),
            selectedColor: Colors.orange,
          ),

          /// Chat
          SalomonBottomBarItem(
            icon: Icon(Icons.chat),
            title: Text("Chat"),
            selectedColor: Colors.teal,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Color(0xff09031D),
          ),
        ],
      ),
    );
  }
}
