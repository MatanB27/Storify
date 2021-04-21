import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/chat.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storify/pages/edit_profile.dart';
import '../auth_service.dart';
import 'package:storify/widgets/story_ticket.dart';
import 'package:storify/widgets/user_ticket.dart';

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
  bool isLoading = false;
  final String currentUserId = currentUserHome?.id;

  //TODO: use for each from firebase
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
                //TODO CHECK BUGS
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                //TODO CHECK BUGS
                user.displayName,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
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
                          "Following",
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
                    child: Column(
                      children: [
                        Text(
                          'Followers',
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
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    splashColor: Colors.white10,
                    onPressed: editProfile,
                    color: Colors.black,
                    child: Text(
                      'Edit profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 8.0),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  OutlineButton(
                    onPressed: () {},
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 8.0),
                    child: Text('message'),
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
                    "Biography",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
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
                    child: Text(user.bio),
                  ), //TODO might be a bug
                  SizedBox(
                    height: 20.0,
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
        body: ListView(
          children: [
            profileHeader(),
            tickets[0],
          ],
        ),
      ),
    );
  }
}
