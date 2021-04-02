import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/pages/search.dart';
import 'package:storify/pages/uploadStory.dart';
import '../user.dart';
import 'chat.dart';

//user collection database
final userRef = FirebaseFirestore.instance.collection('users');
final DateTime timestampNow = DateTime.now(); //the time the user was created
UserClass currentUserClass;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController; //we use it to control our page selection
  int pageIndex = 0; // current page index we are in

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
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

  Future<void> signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          RaisedButton(
            //raisebutton but from different version
            onPressed: () => signOut(context),
            child: Text('Logout'),
          ),

          //Feed(), //TODO: is closed temporary so we can use the log out func
          Search(),
          UploadStory(), //TODO: use - currentUser
          Chat(),
          Profile(), //TODO: use profileId - currentUser?.id
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
            icon: Icon(Icons.search_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              size: 42.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }
}
