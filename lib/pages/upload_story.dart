import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/services/scaffold_message.dart';
import 'package:uuid/uuid.dart';
import 'package:storify/services/categories.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:edge_alert/edge_alert.dart';

// The page where we uploading the story to the data base.
class UploadStory extends StatefulWidget {
  final String userId;

  UploadStory({this.userId});
  @override
  _UploadStoryState createState() => _UploadStoryState();
}

// The implement it too keep the state of the app when we are moving to another page
class _UploadStoryState extends State<UploadStory>
    with AutomaticKeepAliveClientMixin<UploadStory> {
  // Text fields variables
  TextEditingController titleStoryController = TextEditingController();
  TextEditingController storyController = TextEditingController();

  // Chosen categories -> up to 3 categories
  // User will have to pick at least 1 category
  List<String> chosenCategories = [];
  /*
    We are copying all of the allCategories list value to a copy list
    Because we don't want to touch the original.
  */
  List<String> copyCategories = List.from(allCategories);
  // Variable for uploading an image
  File file;
  String _uploadedFileURL = 'assets/images/upload_photo.png';
  bool isUploading = false;

  // Getting doc id for the storyID
  String storyId = Uuid().v4();

  // The current user who is logged in
  final String currentUserId = auth.currentUser?.uid;

  // Variables to fetch the name and photo from the user ref
  String name;
  String photo;

  /*
     We are picking a category, removing it from the copyCategories
    And adding it to chosenCategories, if chosenCategories length is 3,
     We will get an error message that we cant take more categories
   */
  pickACategory(int index) {
    if (chosenCategories.length < 3) {
      String category = copyCategories.removeAt(index);
      chosenCategories.add(category);
    } else {
      showMessage(context, 'You already have 3 genres');
    }
  }

  /*
    Will remove the category from the chosenCategories list and add it
    Into copyCategories
   */
  removeACategory(int index) {
    String category = chosenCategories.removeAt(index);
    copyCategories.add(category);
  }

  // When we quit the app
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleStoryController.dispose();
    storyController.dispose();
    super.dispose();
  }

  getDisplayNameAndPhoto() async {
    DocumentSnapshot docName = await userRef.doc(widget.userId).get();
    DocumentSnapshot docPhoto = await userRef.doc(widget.userId).get();
    name = docName.get('displayName');
    photo = docPhoto.get('photoUrl');
  }

  // Init state of the app
  @override
  void initState() {
    super.initState();
    getDisplayNameAndPhoto();
  }

  /*
     Publish story method, it will only work if the user have story title,
     Categories or the story itself
     It will all add to the firebase.
  */
  publishStory() async {
    if (storyController.text.toString().trim().length < 20 ||
        titleStoryController.text.toString().trim().length < 3 ||
        chosenCategories.length == 0 ||
        _uploadedFileURL == 'assets/images/upload_photo.png') {
      SweetAlert.show(context,
          title: "Oops",
          subtitle:
              "Please make sure you pick a photo\n or all the fields are full",
          style: SweetAlertStyle.error);
    } else {
      /*
         Generating random id from firebase
         storyId = storiesRef.doc(widget.userId).collection('storyId').doc().id;
         First we are creating the doc story
      */
      await userRef.doc(currentUserId).update({
        'stories': FieldValue.arrayUnion([storyId]),
      });

      print(getFollowers(currentUserId));
      await storiesRef.doc(storyId).set({
        'uid': widget.userId,
        'sid': storyId,
        'displayName': name,
        'photoUrl': photo,
        'followers': FieldValue.arrayUnion(await getFollowers(currentUserId)),
        'categories': chosenCategories,
        'average': 0, // Average score - start with 0
        'countRating': 0, // How many ratings the story got
        'total': 0, // Total score (to calculate average)
        'storyPhoto': _uploadedFileURL,
        'title': titleStoryController.text.toString(),
        'timeStamp': DateTime.now(),
        'story': storyController.text.toString(),
        // According to the users rating
      });
      SweetAlert.show(context,
          title: "Succeed",
          subtitle: "Your story has been successfully published",
          style: SweetAlertStyle.success);

      await showReadStory(context, storyId: storyId, ownerId: widget.userId);

      // We are resetting everything after we finish to upload the story.
      setState(() {
        storyId = Uuid().v4();
        _uploadedFileURL = 'assets/images/upload_photo.png';
        isUploading = false;
        file = null;
        storyController.clear();
        titleStoryController.clear();
      });
    }
  }

  // Menu for changing photo from camera or gallery
  selectImage() {
    return SingleChildScrollView(
      child: Container(
        height: 100.0,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            Text(
              'Upload your own photo',
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
    firebase_storage.UploadTask uploadTask = storageRef
        .child("story_ " + storyId + "_" + currentUserId + ".jpg")
        .putFile(imageFile);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    _uploadedFileURL = imageUrl.toString();

    return _uploadedFileURL;
  }

  // Help us save he state of this page when we move to another page
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Color(0xff09031D),
        body: Container(
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
                          ? loadingCircular()
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
                                  image: _uploadedFileURL ==
                                          'assets/images/upload_photo.png'
                                      ? AssetImage(_uploadedFileURL)
                                      : CachedNetworkImageProvider(
                                          _uploadedFileURL),
                                  fit: BoxFit.fill,
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
                        'Choose your own story photo',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                          //fontFamily: 'Pacifico',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 35,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          FlatButton(
                            child: Text(
                              "Your title",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              EdgeAlert.show(
                                context,
                                title: 'Your story title',
                                // description: 'Description',
                                gravity: EdgeAlert.TOP,
                                icon: Icons.info,
                                backgroundColor: Colors.grey,
                              );
                            },
                          ),
                        ],
                      ),
                      FlatButton(
                        child: TextField(
                          controller: titleStoryController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 25,
                          decoration: InputDecoration(
                            // hintText: "title here",
                            fillColor: Colors.white,
                            filled: true,
                            helperText: 'at least 3 characters',
                            helperStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FlatButton(
                        child: Text(
                          'Pick the story genres - up to 3 genres:',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          EdgeAlert.show(
                            context,
                            title: 'Genres',
                            description: 'Please choose three',
                            gravity: EdgeAlert.TOP,
                            icon: Icons.info,
                            backgroundColor: Colors.grey,
                          );
                        },
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      GridView.builder(
                          // All categories
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 120,
                                  childAspectRatio: 8 / 2,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 10),
                          itemCount: copyCategories.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  pickACategory(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    color: Colors.white24),
                                child:
                                    Center(child: Text(copyCategories[index])),
                                height: 25,
                              ),
                            );
                          }),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        'Your genres:',
                        style:
                            TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      GridView.builder(
                          // All categories
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 120,
                                  childAspectRatio: 8 / 2,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 10),
                          itemCount: chosenCategories.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  removeACategory(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  color: Colors.blueAccent,
                                ),
                                child: Center(
                                    child: Text(
                                  chosenCategories[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                                height: 25,
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 35,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Your story",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        controller: storyController,
                        maxLength: 7500,
                        maxLines: 15,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Tell us your story here...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      AnimatedButton(
                        height: 40,
                        width: 200,
                        text: 'Publish story',
                        isReverse: true,
                        selectedTextColor: Colors.black,
                        transitionType: TransitionType.LEFT_TO_RIGHT,
                        //textStyle: submitTextStyle,
                        backgroundColor: Colors.black,
                        borderColor: Colors.white,
                        borderRadius: 50,
                        borderWidth: 2,
                        onPress: publishStory,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
