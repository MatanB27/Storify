import 'package:flutter/material.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/database.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/loading.dart';
import 'package:storify/widgets/user_ticket.dart';

// Followers page where we will show the user tickets of the followers
// Users
class Following extends StatefulWidget {
  // We are getting the user id, and the following list from the profile page.
  final String followingId;
  final List<dynamic> followingList;

  Following({this.followingId, this.followingList});

  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  // When we pull the page, it will refresh it and fetch the new data.
  Future<Null> pullToRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      buildFollowingTickets();
      getIds();
    });
    return null;
  }

  getIds() {
    var doc = followingRef.get();
    doc.then((value) => {print(value.docs)});
  }
  // Here we are building the following tickets according to who are
  // We following, and it will build a user ticket to each one!

  buildFollowingTickets() {
    if (!widget.followingList.isEmpty) {
      return StreamBuilder(
        stream: followingRef
            .doc(widget.followingId)
            .collection('userFollowing')
            .orderBy('displayName', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loadingCircular();
          }

          List<UserTicket> userFollowing = [];
          final followings = snapshot.data.docs;
          for (var following in followings) {
            final id = following.data()['id'];
            final displayName = following.data()['displayName'];
            final photoUrl = following.data()['photoUrl'];
            final UserTicket userTicket = UserTicket(
              displayName: displayName,
              photoUrl: photoUrl,
              id: id,
            );
            userFollowing.add(userTicket);
          }
          return ListView(
            children: userFollowing,
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    //print(widget.followingList);
    print(widget.followingId);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: pullToRefresh,
      child: Scaffold(
        backgroundColor: Color(0xff1C1A32),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: Header(
            title: 'Following',
          ),
        ),
        body: Container(
          child: buildFollowingTickets(),
        ),
      ),
    );
  }
}
