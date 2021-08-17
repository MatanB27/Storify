import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/auth_service.dart';
import 'package:readmore/readmore.dart';
import 'package:storify/services/build_icon.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/favorite.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/widgets/rating.dart';
import 'package:storify/services/scaffold_message.dart';

class ReadStory extends StatefulWidget {
  final String storyId;
  final String ownerId;

  ReadStory({this.storyId, this.ownerId});
  @override
  _ReadStoryState createState() => _ReadStoryState();
}

class _ReadStoryState extends State<ReadStory> {
  // Story variables that we will take from the firebase:
  String photoUrl = '';
  String displayName = '';
  String title = '';
  List<String> categories = [];
  String storyPhoto = '';
  String story = '';
  Timestamp timeStamp;
  dynamic average;
  String ownerUserId; // The story teller ID
  final String currentUserId = auth.currentUser?.uid; // the current user ID

  // if user made the story his favorite
  Favorite favorite = new Favorite();
  // The init state of the app, we are getting the info
  // of the story from here

  @override
  void initState() {
    super.initState();
    favorite.checkIfFavorite(widget.storyId, currentUserId);
  }

  // When we quit the page its disposing it
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    stop();
    super.dispose();
  }

  /*
    This method will used when we click on the play button.
    as long as it play - the system will read us the story.
    There is a limitation of how many chars we can from a string
    We cut the string to 2 parts: 3000 chars and 3500 chars
           (Each story have maximum of 7500 chars)
  */
  Future speak(String story) async {
    await FlutterTts().setLanguage("en-US");
    if (story.length >= 3000) {
      List<String> temp = [
        story.substring(0, 3000),
        story.substring(3001, story.length - 1)
      ];
      int i = 0;
      FlutterTts flutterTts = FlutterTts();
      await flutterTts.speak(temp[i]);
      flutterTts.setCompletionHandler(() async {
        if (i < temp.length - 1) {
          i++;
          await flutterTts.speak(temp[i]);
        }
      });
    } else {
      await FlutterTts().speak(story);
    }
  }

  /*
  Stopping the reader sound
   */
  Future stop() async {
    await FlutterTts().stop();
  }

  /*
  Sharing across other social media apps
   */
  share() {
    Share.share(story +
        "\n This story was written by " +
        displayName +
        ".\n © By Storify app");
  }

  /*
  Deleting the story from storiesRef, userRef and commentRef database
   */
  deleteStory() async {
    storiesRef.doc(widget.storyId).delete();
    // Check if exists in commentsRef and then delete
    DocumentSnapshot dc = await commentsRef.doc(widget.storyId).get();
    if (dc.exists) {
      commentsRef.doc(widget.storyId).delete();
    }

    userRef.doc(widget.ownerId).update({
      'stories': FieldValue.arrayRemove([widget.storyId])
    });
  }

  /*
  Alert dialog that will ask us if we want to delete the story
 */
  Future<void> confirmDelete(BuildContext context) async {
    try {
      final didRequestSignOut = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete story'),
          content: Text('Are you sure you want to delete?'),
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
        deleteStory(); // Deleting story
        Navigator.pop(context); // Going back
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: FutureBuilder(
        future: storiesRef.where('sid', isEqualTo: widget.storyId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loadingCircular();
          }
          // Taking the data in inserting them in the page
          snapshot.data.docs.forEach((doc) {
            displayName = doc.data()['displayName'];
            photoUrl = doc.data()['photoUrl'];
            title = doc.data()['title'];
            categories = List.from(doc.data()['categories']);
            storyPhoto = doc.data()['storyPhoto'];
            story = doc.data()['story'];
            timeStamp = doc.data()['timeStamp'];
            ownerUserId = doc.data()['uid'];
            average = doc.data()['average'];
          });
          return Scaffold(
            backgroundColor: Color(0xff09031D),
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white,
              ), //Color(0xff1C1A32)
              backgroundColor: Color(0xff09031D),
              actions: <Widget>[
                Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        showProfile(context, profileId: ownerUserId);
                      },
                      child: Center(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    showProfile(context, profileId: ownerUserId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 27,
                      backgroundImage: CachedNetworkImageProvider(photoUrl),
                    ),
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
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontFamily: 'Pacifico',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 8.0,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            timeStamp.toDate().day.toString() +
                                '.' +
                                timeStamp.toDate().month.toString() +
                                '.' +
                                timeStamp.toDate().year.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (var category in categories)
                            Text(
                              category + '  ',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 15),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          currentUserId == this.ownerUserId
                              ? BuildIcon(
                                  color: Colors.grey,
                                  padding: 8.0,
                                  size: 27.0,
                                  icon: Icons.delete,
                                  onPressed: () {
                                    confirmDelete(context);
                                  },
                                )
                              : Container(),
                          BuildIcon(
                            color: Colors.grey,
                            padding: 8.0,
                            size: 27.0,
                            icon: Icons.share,
                            onPressed: () {
                              share();
                            },
                          ),
                          BuildIcon(
                            color: Colors.grey,
                            padding: 8.0,
                            size: 27.0,
                            icon: Icons.headset,
                            onPressed: () {
                              speak(story);
                            },
                          ),
                          BuildIcon(
                            color: Colors.grey,
                            padding: 8.0,
                            size: 27.0,
                            icon: Icons.stop,
                            onPressed: () {
                              stop();
                            },
                          ),
                          BuildIcon(
                            color: Colors.grey,
                            padding: 8.0,
                            size: 27.0,
                            icon: Icons.report_problem,
                            onPressed: () {
                              currentUserId == ownerUserId
                                  ? showMessage(context,
                                      "You can't report your own story!")
                                  : showReport(
                                      context, currentUserId, widget.storyId);
                            },
                          ),
                          BuildIcon(
                            color: Colors.grey,
                            padding: 8.0,
                            size: 27.0,
                            icon: favorite.isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            onPressed: () {
                              setState(() {
                                favorite.addOrRemoveFromFavorites(
                                    widget.storyId, currentUserId);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ratingStars(average, 30.0, true),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ReadMoreText(
                        story,
                        delimiter: ' ',
                        trimCollapsedText: ' read more',
                        trimExpandedText: ' show less',
                        trimLength: 300,
                        colorClickableText: Colors.grey,
                        style: TextStyle(
                          color: Colors.white,
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
                        showComments(
                          context,
                          storyId: widget.storyId,
                          currentUserId: currentUserId,
                          ownerUserId: widget.ownerId,
                        );
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
