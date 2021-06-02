import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/keywords.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/services/scaffold_message.dart';
import 'package:storify/user.dart';
import 'package:storify/services/loading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../services/auth_service.dart';
import 'home.dart';
import 'package:storify/services/database.dart';

//TODO: improve UI
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

  // This function will help us update the data inside the stories ref
  updateNameInStoriesRef() async {
    // The new name
    String newName = displayNameController.text.toString();
    QuerySnapshot x = await storiesRef.get();
    x.docs.forEach((element) async {
      await storiesRef.doc(element.id).update({
        'displayName': newName,
      });
    });
  }

  // Updating the photo in the photo ref
  updatePhotoInCommentRef() async {
    String newPhoto = _uploadedFileURL;

    var doc = await commentsRef.get();
    if (doc.docs.length > 0) {
      doc.docs.forEach((element) {
        element.reference
            .collection('userId')
            .where('uid', isEqualTo: widget.currentUserId)
            .get()
            .then((value) => {
                  value.docs.forEach((element) {
                    element.reference.update({'photoUrl': newPhoto});
                  })
                });
      });
    }
  }

  // This function will help us to update the data inside the comment ref
  updateNameInCommentRef() async {
    String newName = displayNameController.text.toString();

    var doc = await commentsRef.get();
    if (doc.docs.length > 0) {
      doc.docs.forEach((element) {
        element.reference
            .collection('userId')
            .where('uid', isEqualTo: widget.currentUserId)
            .get()
            .then((value) => {
                  value.docs.forEach((element) {
                    element.reference.update({'displayName': newName});
                  })
                });
      });
    }
  }

  // Updating the name in following and followers REF!
  updateNameInFollowingAndFollowersRef() async {
    String newName = displayNameController.text.toString();

    // In followingRef
    var followingDoc = await followingRef.get();
    if (followingDoc.docs.length > 0) {
      followingDoc.docs.forEach((element) {
        element.reference
            .collection('userFollowing')
            .where('id', isEqualTo: widget.currentUserId)
            .get()
            .then((value) => {
                  value.docs.forEach((element) {
                    element.reference.update({'displayName': newName});
                  })
                });
      });
    }
    // In followerRef
    var followerDoc = await followersRef.get();
    if (followerDoc.docs.length > 0) {
      followerDoc.docs.forEach((element) {
        element.reference
            .collection('userFollowers')
            .where('id', isEqualTo: widget.currentUserId)
            .get()
            .then((value) => {
                  value.docs.forEach((element) {
                    element.reference.update({'displayName': newName});
                  })
                });
      });
    }
  }

  // Updating the photo in following and followers REF!
  updatePhotoInFollowingAndFollowersRef() async {
    String newPhoto = _uploadedFileURL;

    // In followingRef
    var followingDoc = await followingRef.get();
    if (followingDoc.docs.length > 0) {
      followingDoc.docs.forEach((element) {
        element.reference
            .collection('userFollowing')
            .where('id', isEqualTo: widget.currentUserId)
            .get()
            .then((value) => {
                  value.docs.forEach((element) {
                    element.reference.update({'photoUrl': newPhoto});
                  })
                });
      });
    }
    // In followerRef
    var followerDoc = await followersRef.get();
    if (followerDoc.docs.length > 0) {
      followerDoc.docs.forEach((element) {
        element.reference
            .collection('userFollowers')
            .where('id', isEqualTo: widget.currentUserId)
            .get()
            .then((value) => {
                  value.docs.forEach((element) {
                    element.reference.update({'photoUrl': newPhoto});
                  })
                });
      });
    }
  }

  // This function will help us to update the data inside the chat Ref
  updateNameInChatRef() async {
    // x will get all the data from the currentUser id
    DocumentSnapshot x = await userRef.doc(auth.currentUser.uid).get();

    // Here we are inserting all of the user rooms id in userRef.
    Map<dynamic, dynamic> map = x.get('messages');

    List<dynamic> userRooms = [];
    map.forEach((key, value) {
      userRooms.add(value);
    });
    //print(userRooms);

    // Check if collection exist:
    var snap = await chatRef.get();
    if (snap.docs.length > 0) {
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
  }

  // Will update the profile photo in the user database, chat database,
  // Story database and comment database
  updateProfileData() async {
    await updateNameInCommentRef();
    await updateNameInChatRef();
    await updateNameInStoriesRef();
    await updateNameInFollowingAndFollowersRef();

    userRef.doc(auth.currentUser.uid).update({
      "displayName": displayNameController.text,
      "displayNameSearch": displayNameController.text.toLowerCase(),
      "bio": bioController.text,
      "keywords": setSearchParam(displayNameController.text.toString()),
    });
    showMessage(context, 'Profile has been updated successfully!');
  }

  updatePhotoInStoriesRef() async {
    // The new photo
    String newPhoto = _uploadedFileURL;
    QuerySnapshot x = await storiesRef.get();
    x.docs.forEach((element) async {
      await storiesRef.doc(element.id).update({
        'photoUrl': newPhoto,
      });
    });
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

  /*
     Taking a photo with the camera or choose from the gallery
     Depends on the argument value.
    Pick image is still ok, its just from older version
    If we cancel our choice, try catch will catch the error and isUploading
    Will become false
   */
  void takePhoto(bool isGallery) async {
    try {
      goBack(context);
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
    await updatePhotoInStoriesRef();
    await updatePhotoInChatRef();
    await updatePhotoInCommentRef();
    await updatePhotoInFollowingAndFollowersRef();
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
                        onPressed: () => goBack(context),
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
    //updateNameInStoriesRef();
  }

  // Getting the user info from the database
  getUserInfo() async {
    DocumentSnapshot documentSnapshot =
        await userRef.doc(auth.currentUser.uid).get();
    UserClass user = UserClass.fromDocuments(documentSnapshot);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
  }

  // When we quit the page its disposing it
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    displayNameController.clear();
    bioController.clear();
    displayNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        //backgroundColor: Color(0xff09031D),
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => goBack(context),
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
              onPressed: () => confirmSignOut(context),
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
