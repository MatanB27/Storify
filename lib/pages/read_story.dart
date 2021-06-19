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
import 'package:storify/services/loading.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/services/rating.dart';
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

  // The init state of the app, we are getting the info
  // of the story from here
  @override
  void initState() {
    super.initState();
    // print(widget.storyId);
    // print(widget.commentsId);
    // print(widget.ownerId);

    // getInfo();
  }

  // getInfo() async { //TODO: maybe delete
  //   DocumentSnapshot doc = await storiesRef
  //       .doc(widget.ownerId)
  //       .collection('storyId')
  //       .doc(widget.storyId)
  //       .get();
  //   if (!doc.exists) {
  //     return loading();
  //   }
  //   photoUrl = doc.get('photoUrl');
  //   displayName = doc.get('displayName');
  //   title = doc.get('title');
  //   categories = doc.get('categories');
  //   storyPhoto = doc.get('storyPhoto');
  //   story = doc.get('story');
  //   print(story.length);
  // }

  /*
    This method will used when we click on the play button.
    as long as it play - the system will read us the story.
    There is a limitation of how many chars we can from a string
    We cut the string to 2 parts: 3000 chars and 3500 chars
           (Each story have maximum of 7500 chars)
  */
  Future speak(String story) async {
    //TODO: add stop button
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

  Future stop() async {
    //TODO:
    await FlutterTts().stop();
  }

  share() {
    Share.share(story +
        "\n This story was written by " +
        displayName +
        ".\n © By Storify app");
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: FutureBuilder(
        future: storiesRef.where('sid', isEqualTo: widget.storyId).get(),
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
            timeStamp = doc.data()['timeStamp'];
            ownerUserId = doc.data()['uid'];
            average = doc.data()['average'];
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
                    GestureDetector(
                      onTap: () {
                        showProfile(context, profileId: ownerUserId);
                      },
                      child: Center(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: Colors.black,
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
                    ratingStars(average, 50.0, true),
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
                                '/' +
                                timeStamp.toDate().month.toString() +
                                '/' +
                                timeStamp.toDate().year.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BuildIcon(
                          // Share icon
                          color: Colors.lightBlueAccent[200],
                          icon: Icons.share,
                          onPressed: () {
                            share();
                          },
                        ),
                        BuildIcon(
                          // Play icon
                          color: Colors.greenAccent[200],
                          icon: Icons.play_arrow,
                          onPressed: () {
                            speak(story);
                          },
                        ), // play
                        BuildIcon(
                          color: Colors.yellowAccent[400],
                          icon: Icons.stop,
                          onPressed: () {
                            stop();
                          },
                        ), // pause
                        BuildIcon(
                          color: Colors.red[300],
                          icon: Icons.report_problem,
                          onPressed: () {
                            currentUserId == ownerUserId
                                ? showMessage(
                                    context, "You can't report your own story!")
                                : showReport(
                                    context, currentUserId, widget.storyId);
                          },
                        ), // report
                      ],
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
