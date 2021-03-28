import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/pages/search.dart';
import 'package:storify/pages/uploadStory.dart';
import 'package:flutter/cupertino.dart';
import 'package:storify/pages/chat.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:storify/pages/feed.dart';
import 'package:storify/widgets/loading.dart';
import '../user.dart';

//global variables:
//variable for signing in
final GoogleSignIn googleSignIn = GoogleSignIn(); //google variable
final FacebookLogin facebookLogin = new FacebookLogin();
User currentUser; //current user
final DateTime timestampNow = DateTime.now(); //the time the user was created
final userRef = Firestore.instance.collection('users'); //Users ref

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

//TODO: add facebook sign in functions
class _HomeState extends State<Home> {
  bool isAuth = false; //if the user is in log in state - show us the homePage
  //else - show us the log in page
  PageController pageController; //we use it to control our page selection
  int pageIndex = 0; // current page index we are in

  //the state of the app when we are entering it
  @override
  void initState() {
    super.initState();
    pageController = PageController();

    //listen to the change of the signing in with error handeling
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignInGoogle(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    //Reauthenticate users when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignInGoogle(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  //When we leave this page, it will remove the pageController
  @override
  dispose() {
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

  //we are building the user in the cloud
  createUserInFirestore() async {
    //we are checking if the user exist in the collection according to the id
    final GoogleSignInAccount user = googleSignIn.currentUser;
    //variable that store userid document, we check if it exist or not
    DocumentSnapshot doc = await userRef.document(user.id).get();

    //if dosent exist - we create it
    if (!doc.exists) {
      userRef.document(user.id).setData({
        "id": user.id,
        "displayName": user.displayName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "bio": "",
        "timestamp": timestampNow,
      });
      //now all the set data we are storing in doc
      doc = await userRef.document(user.id).get();
    }
    //current user is now this data
    currentUser = User.fromDocuments(doc);
  }

  //the way we are handling if the user is sign in or not
  handleSignInGoogle(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      print(account);
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  //TODO: not working!!
  handleSignInFacebook(FacebookLogin account) {
    if (account != null) {
      print(account);
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  //log in the user
  loginGoogle() async {
    await googleSignIn.signIn();
  }

  logout() async {
    await googleSignIn.signOut();
    await facebookLogin.logOut();
  }

  void loginFacebook() async {
    final FacebookLoginResult facebookLoginResult =
        await facebookLogin.logIn(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.loggedIn:
        // TODO: Handle this case.
        FirebaseAuth.instance.signInWithCredential(
          FacebookAuthProvider.getCredential(
              accessToken: facebookLoginResult.accessToken.token),
        );
        FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
        if (currentUser != null) {
          print('user is logged in');

          DocumentSnapshot doc = await userRef.document(currentUser.uid).get();
          //Storing the user data in the firestore database

          //if dosent exist - we create it
          if (!doc.exists) {
            userRef.document(currentUser.uid).setData({
              "id": currentUser.uid,
              "displayName": currentUser.displayName,
              "photoUrl": currentUser.photoUrl,
              "email": currentUser.email,
              "bio": "",
              "timestamp": timestampNow,
            });
            //now all the set data we are storing in doc
            doc = await userRef.document(currentUser.uid).get();
          }
          //current user is now this data
          //currentUser = User.fromDocuments();
        }

        break;
      case FacebookLoginStatus.cancelledByUser:
        print('cancelled by user');
        break;
      case FacebookLoginStatus.error:
        print('login error');
        break;
    }
  }

  //if the user is logged in he will see this page
  //in homePage the user is navigating through all the main pages of the app:
  //feed - where the user can see all the stories
  //search - where the user can search for other users profile
  //upload Story - where the user can upload it own story
  //chat - the user can chat with other people in the app
  //profile - the user profile page
  Scaffold homePage() {
    //TODO: use APPBar
    return Scaffold(
      body: PageView(
        children: [
          RaisedButton(
            onPressed: logout,
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

  Scaffold loginPage() {
    //if the user is not logged in he will see this page
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'STORIFY',
              style: TextStyle(
                  fontSize: 60.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40.0,
            ),
            GestureDetector(
              onTap: loginGoogle,
              child: Container(
                width: 260.0,
                height: 50.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            GestureDetector(
              onTap: loginFacebook,
              child: Container(
                width: 340.0,
                height: 50.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/continue_with_facebook.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //check what page the user need to see

    return isAuth ? homePage() : loginPage();
  }
}
