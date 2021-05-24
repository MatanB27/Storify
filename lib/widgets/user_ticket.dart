import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storify/services/navigator_to_pages.dart';

/*
  This class will show us the user tickets according to the UI
 */
class UserTicket extends StatelessWidget {
  final String id;
  final String displayName;
  final String photoUrl;

  UserTicket({
    this.displayName,
    this.photoUrl,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.lightBlue,
          backgroundImage: CachedNetworkImageProvider(this.photoUrl),
        ),
        title: Text(
          this.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        dense: true,
      ),
      onPressed: () {
        showProfile(context, profileId: this.id);
      },
    );
  }
}
