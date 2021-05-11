import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/following.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/services/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storify/pages/edit_profile.dart';
import '../services/auth_service.dart';
import 'package:storify/widgets/story_ticket.dart';
import 'package:storify/pages/private_message.dart';
import 'package:storify/pages/followers.dart';

//todo: here you need to put the stores list from the fire base
List<String> imagePost = [
  'https://static.wikia.nocookie.net/arthur/images/e/e9/Buster%27s_Summer_Clothes.PNG/revision/latest?cb=20110719105405',
  'https://i.pinimg.com/originals/1b/ed/e3/1bede357d643bc08060ee9d59b7fc59c.png',
  'https://i.ytimg.com/vi/RY4bQKLT4J4/maxresdefault.jpg'
];

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

  // Following / Followers variables.
  bool isFollowing = false;
  int followingCount = 0;
  int followerCount = 0;
  List<String> followingList = [];
  List<String> followersList = [];
  // Will give us the number of the followers and a list of all the followers ids
  // We will use it at the init state
  getFollowers() async {
    await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                followersList.add(element.id);
              }),
              followerCount = value.docs.length,
            });
    return followersList;
  }

  // Will give us the number of the following and a list of all the followers ids
  // We will use it at the init state
  getFollowing() async {
    await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                followingList.add(element.id);
              }),
              followingCount = value.docs.length,
            });
    return followingList;
  }

  // Will make the user follow the other user.
  // It will be updated in firebase, We are updating both followingRef
  // And followersRef
  void handleFollow() {
    setState(() {
      isFollowing = true;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
  }

  // Will remove the follow from the other user.
  // It will delete the data from both following and followers database.
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
  }

  // This method will remember if we are following the other user or not
  // We will use it in the init state
  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    isFollowing = doc.exists;
  }

  //TODO: use for each from firebase, its just an example. delete later
  List<StoryTickets> tickets = [
    StoryTickets("https://picsum.photos/250?image=9", "Best story ever",
        "Comedy, Horror", "Raiting : 100", "13.04.2021", "Matan Baruch"),
    StoryTickets(
        "https://picsum.photos/250?image=9",
        "Biggest story ever",
        "Adventure, Drama, Sci-fi",
        "Raiting : 100",
        "14.04.2021",
        "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Coolest story ever",
        "Action", "Raiting : 100", "14.04.2021", "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "14.04.2021", "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "14.04.2021", "Shay Ohayon"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "13.04.2021", "Matan Baruch"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "13.04.2021", "Matan Baruch"),
    StoryTickets("https://picsum.photos/250?image=9", "Title", "Categories",
        "Raiting : 100", "13.04.2021", "Matan Baruch"),
  ];

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
    //future: help us to get the user information base on their id.
    return FutureBuilder(
      future: userRef
          .doc(widget.profileId)
          .get(), //we are taking the profile id that we passed
      builder: (context, snapshot) {
        //reload untill all the data will gather up
        if (!snapshot.hasData) {
          return loading();
        }
        UserClass user = UserClass.fromDocuments(snapshot.data);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 8.0,
              ),
              CircleAvatar(
                radius: 56,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                user.displayName,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0),
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Stories',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        Text(
                          '255k',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Followers(
                              followersId: widget.profileId,
                              followersList: followersList,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'Followers',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                          Text(
                            followerCount.toString(),
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Following(
                              followingId: widget.profileId,
                              followingList: followingList,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            "Following",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                          Text(
                            followingCount.toString(),
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    // This button is change depends if it us or not
                    onPressed: currentUserId == widget.profileId
                        ? editProfile
                        : !isFollowing
                            ? handleFollow
                            : handleUnfollow,
                    color: currentUserId == widget.profileId
                        ? Colors.green
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
                        ? EdgeInsets.symmetric(horizontal: 85.0, vertical: 8.0)
                        : EdgeInsets.symmetric(horizontal: 50.0, vertical: 8.0),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  currentUserId == widget.profileId
                      ? Container() //empty container
                      : FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () async {
                            await createRoomInFirebase();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivateMessage(
                                  privateId: widget.profileId,
                                  currentRoomId: currentRoomId,
                                ),
                              ),
                            );
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
              SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 12.0,
                  ),
                  Text(
                    'Biography',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    height: 8.0,
                    width: 12,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        user.bio,
                        style: TextStyle(color: Colors.grey[800], fontSize: 18),
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
        );
      },
    );
  }

  profileStories() {
    //TODO: build the stories tickets
  }

  //when we are in our own profile - we can click this button
  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  // Init state of the app
  @override
  void initState() {
    super.initState();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  // When we pull the page, it will refresh it and fetch the new data.
  Future<Null> pullToRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      profileHeader();
      getFollowing();
      getFollowers();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: Header(
            title: 'Profile',
          ),
        ),
        body: RefreshIndicator(
          onRefresh: pullToRefresh,
          child: ListView(
            children: [
              profileHeader(),
              tickets[0],
            ],
          ),
        ),
      ),
    );
  }
}

// When we click on the user tickets - it will send us to the profile page
// We are using this method in user_ticket widget
showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
