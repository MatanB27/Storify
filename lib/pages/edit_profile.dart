import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/keywords.dart';
import 'package:storify/user.dart';
import 'package:storify/services/loading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../services/auth_service.dart';
import 'home.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Values for editing display name & bio
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Values for uploading the image
  File file;
  String _uploadedFileURL;
  bool isUploading = false;

  // Logout method that will send us back go the signin screen
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  //TODO: edit in story && comment name or bio!!!!!
  // Alert dialog that will ask us if we want to log out
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

  // This function will help us update the data inside the chat Ref
  updateNameInChatRef() async {
    // x will get all the data from the currentUser id
    DocumentSnapshot x = await userRef.doc(auth.currentUser.uid).get();

    // Here we are inserting all of the user rooms id in userRef.
    Map<dynamic, dynamic> map = x.get('messages');
    List<dynamic> userRooms = [];
    map.forEach((key, value) {
      userRooms.add(value);
    });
    print(userRooms);

    // We are filtering the chatRef with the user ids that we got
    var y = chatRef.where('rid', whereIn: userRooms).get();

    // The new name
    String newName = displayNameController.text.toString();

    // The update itself, we are checking who is the user and according to
    // The result we decide in which index we are changing the name
    y.then((value) => {
          value.docs.forEach((element) {
            //We are only doing it if the element exist.
            if (element.exists) {
              print('element ' + element.id);
              String currentName = element.data()['names'][0];
              String otherName = element.data()['names'][1];
              chatRef.doc(element.id).update({
                'names': auth.currentUser.uid == element.data()['ids'][0]
                    ? [newName, otherName]
                    : [currentName, newName],
              });
            }
          }),
        });
  }

  // Will update the profile photo in the user database and in chat database
  updateProfileData() async {
    await updateNameInChatRef();
    userRef.doc(auth.currentUser.uid).update({
      "displayName": displayNameController.text,
      "displayNameSearch": displayNameController.text.toLowerCase(),
      "bio": bioController.text,
      "keywords": setSearchParam(displayNameController.text.toString()),
    });
    final snackBar = SnackBar(
      content: Text('Profile has been update successfully!'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {}, // No need to put anything, just click "Undo"
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Menu for changing photo from camera or gallery
  selectImage() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          Text(
            'Choose Profile Photo',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () => takePhoto(false),
                label: Text('Camera'),
              ),
              FlatButton.icon(
                onPressed: () => takePhoto(true),
                icon: Icon(Icons.image),
                label: Text("Gallery"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Taking a photo with the camera or choose from the gallery
  // Depends on the argument value.
  // Pick image is still ok, its just from older version
  // If we cancel our choice, try catch will catch the error and isUploading
  // Will become false
  void takePhoto(bool isGallery) async {
    try {
      Navigator.pop(context);
      if (isGallery) {
        File file = await ImagePicker.pickImage(source: ImageSource.gallery);
        setState(
          () => this.file = file,
        );
      } else {
        File file = await ImagePicker.pickImage(
          source: ImageSource.camera,
          maxHeight: 675,
          maxWidth: 960,
        );
        setState(() => this.file = file);
      }
      setState(() {
        isUploading = true;
      });
      await uploadImage(this.file);
      setState(() {
        isUploading = false;
      });
    } catch (e) {
      setState(() {
        isUploading = false;
      });
    }
  }

  // Upload the photo
  Future<String> uploadImage(imageFile) async {
    firebase_storage.UploadTask uploadTask =
        storageRef.child("user_${auth.currentUser.uid}.jpg").putFile(imageFile);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    _uploadedFileURL = imageUrl.toString();
    userRef.doc(auth.currentUser.uid).update({
      "photoUrl": _uploadedFileURL,
    });
    await updatePhotoInChatRef();
    return _uploadedFileURL;
  }

  // This function will help us update the data inside the chat Ref
  updatePhotoInChatRef() async {
    // x will get all the data from the currentUser id
    DocumentSnapshot x = await userRef.doc(auth.currentUser.uid).get();

    // Here we are inserting all of the user rooms id in userRef.
    Map<dynamic, dynamic> map = x.get('messages');
    List<dynamic> userRooms = [];
    map.forEach((key, value) {
      userRooms.add(value);
    });
    print(userRooms);

    // We are filtering the chatRef with the user ids that we got
    var y = chatRef.where('rid', whereIn: userRooms).get();

    // The new name
    String newPhoto = _uploadedFileURL;

    // The update itself, we are checking who is the user and according to
    // The result we decide in which index we are changing the photo

    y.then((value) => {
          value.docs.forEach((element) {
            //We are only doing it if the element exist.
            if (element.exists) {
              print('element ' + element.id);
              String currentPhoto = element.data()['photos'][0];
              String otherPhoto = element.data()['photos'][1];
              chatRef.doc(element.id).update({
                'photos': auth.currentUser.uid == element.data()['ids'][0]
                    ? [newPhoto, otherPhoto]
                    : [currentPhoto, newPhoto],
              });
            }
          }),
        });
  }

  // All of the header of the app (Everything expect story tickets).
  profileEditPage() {
    return FutureBuilder(
        future: userRef
            .doc(auth.currentUser.uid)
            .get(), // We are taking the profile id that we passed
        builder: (context, snapshot) {
          // Reload until all the data will gather up
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
                        child: isUploading
                            ? loading()
                            : Container(
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
                                    image: CachedNetworkImageProvider(
                                        user.photoUrl),
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
                  SizedBox(
                    height: 18,
                  ),
                  GestureDetector(
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                              context: context,
                              builder: ((builder) => selectImage()));
                        },
                        child: Text(
                          'Change Profile Photo',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
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
                      maxLines: 4,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: "Tell us about yourself:",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () => Navigator.pop(context),
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

  // The state of the app when we are in its init state
  @override
  void initState() {
    super.initState();
    getUserInfo();
    //updateNameInChatRef();
  }

  // Getting the user info from the database
  getUserInfo() async {
    DocumentSnapshot documentSnapshot =
        await userRef.doc(auth.currentUser.uid).get();
    UserClass user = UserClass.fromDocuments(documentSnapshot);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    displayNameController.dispose();
    bioController.dispose();
    super.dispose();
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
