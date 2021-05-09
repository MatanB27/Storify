import 'package:flutter/material.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/loading.dart';
import 'package:storify/widgets/user_ticket.dart';

// Followers page where we will show the user tickets of the followers
// Users
class Followers extends StatefulWidget {
  // We are getting the user id, and the following list from the profile page.
  final String followersId;
  final List<String> followersList;

  Followers({this.followersId, this.followersList});

  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  // Here we are building the followers tickets according to who are
  // Following us, and it will build a user ticket to each one!
  buildFollowerTickets() {
    if (!widget.followersList.isEmpty) {
      return FutureBuilder(
        future: userRef.where('id', whereIn: widget.followersList).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }

          List<UserTicket> userFollowers = [];
          final followers = snapshot.data.docs;
          for (var follower in followers) {
            final id = follower.data()['id'];
            final displayName = follower.data()['displayName'];
            final photoUrl = follower.data()['photoUrl'];
            final UserTicket userTicket = UserTicket(
              displayName: displayName,
              photoUrl: photoUrl,
              id: id,
            );
            userFollowers.add(userTicket);
          }
          return ListView(
            children: userFollowers,
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: Header(
          title: 'Followers',
        ),
      ),
      body: Container(
        child: buildFollowerTickets(),
      ),
    );
  }
}
