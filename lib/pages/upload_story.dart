import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/pages/read_story.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/loading.dart';
import 'package:uuid/uuid.dart';

// The page where we uploading the story to the data base.
class UploadStory extends StatefulWidget {
  final String userId;

  UploadStory({this.userId});
  @override
  _UploadStoryState createState() => _UploadStoryState();
}

class _UploadStoryState extends State<UploadStory> {
  // Text fields variables
  TextEditingController titleStoryController = TextEditingController();
  TextEditingController storyController = TextEditingController();

  // All the categories in Storify app.
  List<String> allCategories = [
    'Drama',
    'Poetry',
    'Fantasy',
    'Horror',
    'Humor',
    'Mystery',
    'Reality',
    'Parody',
    'Romantic',
    'Novel',
    'Science',
    'Action',
  ];

  // Chosen categories -> up to 3 categories
  // User will have to pick at least 1 category
  List<String> chosenCategories = [];

  // Variable for uploading an image
  File file;
  String _uploadedFileURL;
  bool isUploading = false;

  // Getting doc id for the storyID
  String storyId = Uuid().v4();

  // Variables to fetch the name and photo from the user ref
  String name;
  String photo;
  // We are picking a category, removing it from the AllCategories
  // And adding it to chosenCategories, if chosenCategories length is 3,
  // We will get an error message that we cant take more categories
  pickACategory(int index) {
    if (chosenCategories.length < 3) {
      String category = allCategories.removeAt(index);
      chosenCategories.add(category);
    } else {
      message('You already have 3 genres');
    }
  }

  // Will remove the category from the chosenCategories list and add it
  // Into AllCategories
  removeACategory(int index) {
    String category = chosenCategories.removeAt(index);
    allCategories.add(category);
  }

  // When we quit the app
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleStoryController.dispose();
    storyController.dispose();
    super.dispose();
  }

  // Will give some kind of a message at the bottom of the screen
  message(String text) {
    final snackBar = SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {}, // No need to put anything, just click "Undo"
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  // Publish story method, it will only work if the user have story title,
  // Categories or the story itself
  // It will all add to the firebase.
  publishStory() async {
    if (storyController.text.toString().trim().length < 20 ||
        titleStoryController.text.toString().trim().length < 3 ||
        chosenCategories.length == 0 ||
        _uploadedFileURL == null) {
      message('Make sure you fill everything correctly.');
    } else {
      // Generating random id from firebase
      //storyId = storiesRef.doc(widget.userId).collection('storyId').doc().id;
      // First we are creating the doc story
      await storiesRef.doc(widget.userId).set({});
      await storiesRef
          .doc(widget.userId)
          .collection('storyId')
          .doc(storyId)
          .set({
        'uid': widget.userId,
        'sid': storyId,
        'displayName': name,
        'photoUrl': photo,
        'categories': chosenCategories,
        'storyPhoto': _uploadedFileURL,
        'title': titleStoryController.text.toString(),
        'timeStamp': DateTime.now(),
        'story': storyController.text.toString(),
        'rating': 0 // Every rating will start with 0 - it will be change
        // According to the users rating
      });
      message('Congratulations, You posted a new story!');
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadStory(
            storyId: storyId,
            ownerId: widget.userId,
          ),
        ),
      );

      // We are resetting everything after we finish to upload the story.
      setState(() {
        storyId = Uuid().v4();
        _uploadedFileURL = null;
        isUploading = false;
        file = null;
        storyController.clear();
        titleStoryController.clear();
      });
    }
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
        storageRef.child("story_${storyId}.jpg").putFile(imageFile);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    _uploadedFileURL = imageUrl.toString();

    return _uploadedFileURL;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Upload Story',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: titleStoryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  icon: Icon(
                    Icons.title,
                    color: Colors.black,
                  ),
                  hintText: 'Write your title...',
                  helperText: 'at least 3 characters',
                ),
                maxLength: 30,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Pick the story genres - up to 3 genres:',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              GridView.builder(
                  // All categories
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120,
                      childAspectRatio: 8 / 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 10),
                  itemCount: allCategories.length,
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
                          color: Colors.red[300],
                        ),
                        child: Center(child: Text(allCategories[index])),
                        height: 25,
                      ),
                    );
                  }),
              SizedBox(
                height: 12,
              ),
              Text(
                'Your genres:',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              GridView.builder(
                  // All categories
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
                          color: Colors.lightBlueAccent,
                        ),
                        child: Center(child: Text(chosenCategories[index])),
                        height: 25,
                      ),
                    );
                  }),
              Divider(
                color: Colors.black,
                thickness: 2.0,
              ),
              FlatButton.icon(
                onPressed: () async {
                  showModalBottomSheet(
                      context: context, builder: ((builder) => selectImage()));
                },
                color: Colors.indigo,
                label: Text(
                  'Upload image',
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  Icons.upload_rounded,
                  color: Colors.white,
                ),
              ),
              isUploading
                  ? loading()
                  : _uploadedFileURL != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.grey[600],
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              'Image uploaded successfully!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          ],
                        )
                      : Text(
                          'Please upload your story image',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: storyController,
                maxLength: 7500,
                maxLines: 30,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  hintText: 'Tell us your story here...',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              FloatingActionButton(
                  child: Icon(
                    Icons.menu_book,
                    size: 25,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.lightBlueAccent,
                  onPressed: () {
                    publishStory();
                  }),
              SizedBox(
                height: 10,
              ),
              Text(
                'By clicking the publish button - you are agreeing '
                'that you are the owner of the story and you didnt stole it from other places.'
                ' Breaking those rules will result in deleting your story or deleting your account',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
