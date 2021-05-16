import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lipsum/lipsum.dart' as lipsuam;
import 'package:animated_button/animated_button.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/auth_service.dart';
import 'package:readmore/readmore.dart';
import 'package:storify/services/loading.dart';

class ReadStory extends StatefulWidget {
  final String storyId;
  final String ownerId;
  final String commentsId;

  ReadStory({this.storyId, this.ownerId, this.commentsId});
  @override
  _ReadStoryState createState() => _ReadStoryState();
}

//TODO: add report button, listen to story button and share button
class _ReadStoryState extends State<ReadStory> {
  // Story variables that we will take from the firebase:
  String photoUrl = '';
  String displayName = '';
  String title = '';
  List<String> categories = [];
  String storyPhoto = '';
  String story = '';

  // The init state of the app, we are getting the info
  // of the story from here
  @override
  void initState() {
    super.initState();
    // print(widget.storyId);
    // print(widget.commentsId);
    // print(widget.ownerId);
    //getInfo();
  }

  getInfo() async {
    DocumentSnapshot doc = await storiesRef
        .doc(widget.ownerId)
        .collection('storyId')
        .doc(widget.storyId)
        .get();
    if (!doc.exists) {
      return loading();
    }
    photoUrl = doc.get('photoUrl');
    displayName = doc.get('displayName');
    title = doc.get('title');
    categories = doc.get('categories');
    storyPhoto = doc.get('storyPhoto');
    story = doc.get('story');
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: FutureBuilder(
        future: storiesRef
            .doc(widget.ownerId)
            .collection('storyId')
            .where('sid', isEqualTo: widget.storyId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          // Taking the data in inserting them in the page
          snapshot.data.docs.forEach((doc) {
            displayName = doc.data()['displayName'];
            photoUrl = doc.data()['photoUrl'];
            title = doc.data()['title'];
            categories = List.from(doc.data()['categories']);
            storyPhoto = doc.data()['storyPhoto'];
            story = doc.data()['story'];
          });
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              actions: <Widget>[
                Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 27,
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                  ),
                ),
              ],
              toolbarHeight: 60,
              elevation: 0,
            ),
            body: ListView(
              children: [
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          for (var category in categories)
                            Text(
                              category + '  ',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 20),
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(storyPhoto),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Written by ' + displayName,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xffC3C3E0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ReadMoreText(
                        story,
                        trimLines: 2,
                        colorClickableText: Colors.grey,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    AnimatedButton(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Icon(
                              Icons.chat_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        getInfo();
                      },
                      height: 40,
                      shadowDegree: ShadowDegree.dark,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Method that help us go inside the read story.
readStory(BuildContext context,
    {String storyId, String commentId, String ownerId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReadStory(
        storyId: storyId,
        commentsId: commentId,
        ownerId: ownerId,
      ),
    ),
  );
}
