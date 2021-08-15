import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'database.dart';
import 'navigator_to_pages.dart';

//TODO: FINISH!!!

class UploadImage {
  File currentFile;
  String uploadedFileURL = 'assets/images/upload_photo.png';
  bool isUploading = false;

  // Menu for changing photo from camera or gallery
  selectImage(BuildContext context, String storyId, String currentUserId) {
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
                  onPressed: () =>
                      takePhoto(context, false, storyId, currentUserId),
                  label: Text('Camera'),
                ),
                FlatButton.icon(
                  onPressed: () =>
                      takePhoto(context, true, storyId, currentUserId),
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
  void takePhoto(BuildContext context, bool isGallery, String storyId,
      String currentUserId) async {
    try {
      goBack(context);
      if (isGallery) {
        File file = await ImagePicker.pickImage(source: ImageSource.gallery);
        this.currentFile = file;
      } else {
        File file = await ImagePicker.pickImage(
          source: ImageSource.camera,
          maxHeight: 675,
          maxWidth: 960,
        );
        this.currentFile = file;
      }
      isUploading = true;

      await uploadImage(this.currentFile, storyId, currentUserId);

      isUploading = false;
    } catch (e) {
      isUploading = false;
    }
  }

  // Upload the photo
  Future<String> uploadImage(
      imageFile, String storyId, String currentUserId) async {
    firebase_storage.UploadTask uploadTask = storageRef
        .child("story_ " + storyId + "_" + currentUserId + ".jpg")
        .putFile(imageFile);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    uploadedFileURL = imageUrl.toString();

    return uploadedFileURL;
  }
}
