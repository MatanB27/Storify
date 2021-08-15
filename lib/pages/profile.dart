import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/user.dart';
import 'package:storify/services/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import 'package:storify/widgets/story_ticket.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Loading boolean
  bool isLoading = false;

  // The current user who is logged in
  final String currentUserId = auth.currentUser?.uid;

  // The current room we are entering
  var currentRoomId;

  //Story count variable
  int storyCount = 0;

  // Following / Followers variables.
  bool isFollowing = false;
  int followingCount = 0;
  int followerCount = 0;
  List<String> followingList = [];
  List<String> followersList = [];

  /*
     Will give us the number of the followers and a list of all the followers ids
     We will use it at the init state
   */
  getFollowers() async {
    followingList.clear();
    followersList.clear();
    await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                followersList.add(element.id);
              }),
              if (mounted) // Won't give us the set state error after dispose
                {
                  setState(() {
                    followerCount = value.docs.length;
                  }),
                }
            });
    return followersList;
  }

  /*
     Will give us the number of the following and a list of all the followers ids
     We will use it at the init state
   */
  getFollowing() async {
    followingList.clear();
    followersList.clear();
    await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                followingList.add(element.id);
              }),
              if (mounted) // Won't give us the set state error after dispose
                {
                  setState(() {
                    followingCount = value.docs.length;
                  }),
                }
            });
    return followingList;
  }

  /*
     Will make the user follow the other user.
     It will be updated in firebase, We are updating both followingRef
     And followersRef
   */
  void handleFollow() async {
    setState(() {
      isFollowing = true;
    });

    var doc1 = userRef.doc(currentUserId).get();
    doc1.then((value) => {
          // Im creating first the doc - so it wont be a dummy JSON
          followersRef.doc(widget.profileId).set({}),
          followersRef
              .doc(widget.profileId)
              .collection('userFollowers')
              .doc(currentUserId)
              .set({
            'displayName': value.get('displayName'),
            'photoUrl': value.get('photoUrl'),
            'id': value.get('id'),
          }),
        });

    var doc2 = userRef.doc(widget.profileId).get();
    doc2.then((value) => {
          followingRef.doc(currentUserId).set({}),
          followingRef
              .doc(currentUserId)
              .collection('userFollowing')
              .doc(widget.profileId)
              .set({
            'displayName': value.get('displayName'),
            'photoUrl': value.get('photoUrl'),
            'id': value.get('id'),
          }),
        });
    /*
      In this code we are adding the current user id to the followers
      array in the firebase of the other user - so the current user can
      See the stories of the user he just follow.
    */
    await storiesRef
        .where('uid', isEqualTo: widget.profileId)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                element.reference.update({
                  'followers': FieldValue.arrayUnion([currentUserId]),
                });
              })
            });
  }

  /*
     Will remove the follow from the other user.
     It will delete the data from both following and followers database.
   */
  void handleUnfollow() {
    setState(() {
      isFollowing = false;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .delete();
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .delete();

    /*
      In this code we are removing the current user id from the followers
      array in the firebase of the other user - so the current user
      will no longer see the stories of that user in his feed
    */
    storiesRef.where('uid', isEqualTo: widget.profileId).get().then((value) => {
          value.docs.forEach((element) {
            element.reference.update({
              'followers': FieldValue.arrayRemove([currentUserId]),
            });
          })
        });
  }

  /*
     This method will remember if we are following the other user or not
     We will use it in the init state
   */
  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    isFollowing = doc.exists;
  }

  // Create room in chatRef and also
  createRoomInFirebase() async {
    DocumentReference doc;

    DocumentSnapshot myDocUser = await userRef.doc(currentUserId).get();
    Map<dynamic, dynamic> myMapCheck = await myDocUser.get('messages');

    if (!myMapCheck.containsKey(widget.profileId) || myMapCheck.isEmpty) {
      doc = await chatRef.add({}); // Creating the room
      await userRef.doc(currentUserId).set({
        'messages': {
          widget.profileId: doc.id,
        },
      }, SetOptions(merge: true));
    }

    DocumentSnapshot otherDocUser = await userRef.doc(widget.profileId).get();
    Map<dynamic, dynamic> otherMapCheck = await otherDocUser.get('messages');

    if (!otherMapCheck.containsKey(currentUserId) || otherMapCheck.isEmpty) {
      userRef.doc(widget.profileId).set({
        'messages': {
          currentUserId: doc.id,
        },
      }, SetOptions(merge: true));
    }
    currentRoomId = doc?.id; // Ignores null
    myMapCheck.forEach((key, value) {
      if (key == widget.profileId) {
        currentRoomId = value;
      }
    });
  }

  profileHeader() {
    // Future: help us to get the user information base on their id.

    return FutureBuilder(
      future: userRef
          .doc(widget.profileId)
          .get(), // We are taking the profile id that we passed
      builder: (context, snapshot) {
        // Reload until all the data will gather up
        if (!snapshot.hasData) {
          return loadingCircular();
        }
        UserClass user = UserClass.fromDocuments(snapshot.data);

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0, top: 7.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.lightBlueAccent,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                        radius: 44,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            storyCount.toString(),
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 23.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Stories',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      color: Colors.white,
                      width: 0.8,
                      height: 22,
                    ),
                    GestureDetector(
                      onTap: () {
                        showFollowers(context,
                            profileId: widget.profileId,
                            followersList: followingList);
                      },
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                followerCount.toString(),
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Followers',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      width: 0.6,
                      height: 22,
                    ),
                    GestureDetector(
                      onTap: () {
                        showFollowing(context,
                            profileId: widget.profileId,
                            followingList: followingList);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              followingCount.toString(),
                              style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 23.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Following',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // This button is change depends if it us or not
                      onPressed: currentUserId == widget.profileId
                          ? editProfile
                          : !isFollowing
                              ? handleFollow
                              : handleUnfollow,
                      color: currentUserId == widget.profileId
                          ? Color(0xff479BF0)
                          : Colors.lightBlue,
                      child: currentUserId == widget.profileId
                          ? Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              !isFollowing ? 'Follow' : 'Unfollow',
                              style: TextStyle(color: Colors.white),
                            ),
                      padding: currentUserId == widget.profileId
                          ? EdgeInsets.symmetric(
                              horizontal: 85.0, vertical: 8.0)
                          : EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 8.0),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        currentUserId == widget.profileId
                            ? Container() //empty container
                            : FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                onPressed: () async {
                                  await createRoomInFirebase();
                                  await showPrivateMessage(context,
                                      privateId: widget.profileId,
                                      roomId: currentRoomId);
                                },
                                color: Colors.orangeAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50.0, vertical: 8.0),
                                child: Text(
                                  'Message',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueAccent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 12.0,
                          height: 5,
                        ),
                        Text(
                          'Biography',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 8.0,
                              width: 12.0,
                            ),
                            Expanded(
                              child: Center(
                                child: user.bio != ''
                                    ? Text(
                                        user.bio,
                                        style: TextStyle(
                                            color: Colors.grey[200],
                                            fontSize: 14.0),
                                      )
                                    : Text(
                                        'Nothing here',
                                        style: TextStyle(
                                            color: Colors.grey[200],
                                            fontSize: 14.0),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 60.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /*
    This method will count us how many stories the user have.
    Its looks like buildProfileStories but its different
   */
  getStoriesCount() async {
    await storiesRef
        .doc(widget.profileId)
        .collection('storyId')
        .get()
        .then((value) => {
              if (mounted) // Won't give us the set state error after dispose
                {
                  setState(() {
                    storyCount = value.docs.length;
                  }),
                }
            });
    return storyCount;
  }

  // Building the stories tickets according to two queries,
  // One is the userRef and the other storiesRef
  buildProfileStories() {
    return FutureBuilder(
      future: storiesRef
          .where('uid', isEqualTo: widget.profileId)
          .orderBy('timeStamp', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingCircular();
        }
        List<StoryTickets> tickets = [];
        snapshot.data.docs.forEach((doc) {
          List<String> categories = List.from(doc.data()['categories']);
          StoryTickets ticket = StoryTickets(
            displayName: doc.data()['displayName'],
            categories: categories,
            storyId: doc.data()['sid'],
            commentId: doc.data()['cid'],
            ownerId: doc.data()['uid'],
            rating: doc.data()['average'],
            storyPhoto: doc.data()['storyPhoto'],
            timestamp: doc.data()['timeStamp'],
            title: doc.data()['title'],
            countRating: doc.data()['countRating'],
          );
          tickets.add(ticket);
          storyCount = tickets.length;
        });
        return SizedBox(
          height: 500.0,
          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: tickets,
          ),
        );
      },
    );
  }

  // When we are in our own profile - we can click this button
  void editProfile() {
    showEditProfile(context, currentUserId);
  }

  // Init state of the app
  @override
  void initState() {
    super.initState();
    getFollowers();
    getFollowing();
    getStoriesCount();
    checkIfFollowing();
  }

  // When we quit the page its disposing it
  @override
  void dispose() {
    followersList.clear();
    followingList.clear();

    super.dispose();
  }

  // When we pull the page, it will refresh it and fetch the new data.
  Future<Null> pullToRefresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      profileHeader();
      getFollowing();
      getFollowers();
      buildProfileStories();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Color(0xff09031D),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xff09031D),
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.book_sharp),
                onPressed: () {
                  showFavorites(context, currentUserId);
                }),
            Padding(
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: pullToRefresh,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                profileHeader(),
                buildProfileStories(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
