import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';
import '../auth_service.dart';
import 'home.dart';

//TODO: let the use change his profile picture
class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading;
  //scaffold key
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  //log out method that will send us back go the signin screen
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
    Navigator.popUntil(context, ModalRoute.withName("/"));
  }

  //alert dialog that will ask us if we want to log out
  Future<void> _confirmSignOut(BuildContext context) async {
    try {
      final didRequestSignOut = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Accept'),
            ),
          ],
        ),
      );
      if (didRequestSignOut == true) {
        _signOut(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  updateProfileData() {
    bool displayNameValid;
    userRef.doc(auth.currentUser.uid).update({
      "displayName": displayNameController.text,
      "bio": bioController.text,
    });
    // SnackBar snackBar = SnackBar(content: Text("Profile Updated!"));
    // _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  //TODO: change the hint text
  profileEditPage() {
    return FutureBuilder(
        future: userRef
            .doc(auth.currentUser.uid)
            .get(), //we are taking the profile id that we passed
        builder: (context, snapshot) {
          //reload untill all the data will gather up
          if (!snapshot.hasData) {
            return loading();
          }
          UserClass user = UserClass.fromDocuments(snapshot.data);
          return Container(
            padding: EdgeInsets.only(left: 16, top: 25, right: 16),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10),
                              ),
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(user.photoUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Center(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 35,
                    ),
                    child: TextField(
                      controller: displayNameController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: "Your name:",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: user.displayName,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 35,
                    ),
                    child: TextField(
                      controller: bioController,
                      maxLength: 150,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: "Tell us about yourself:",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: user.bio,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlineButton(
                        color: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onPressed: () {},
                        child: Text(
                          'cancel',
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      OutlineButton(
                        onPressed: updateProfileData,
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'save',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit profile',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey,
          elevation: 1,
          actions: [
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onPressed: () => _confirmSignOut(context),
            ),
          ],
        ),
        body: Container(
          child: profileEditPage(),
        ),
      ),
    );
  }
}
