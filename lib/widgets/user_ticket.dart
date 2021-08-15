import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:avatar_view/avatar_view.dart';
import 'package:line_icons/line_icons.dart';

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
    return Column(
      children: [
        SizedBox(
          height: 12,
        ),
        Container(
          child: FlatButton(
            child: ListTile(
              leading: AvatarView(
                radius: 30,
                borderColor: Colors.white,
                avatarType: AvatarType.CIRCLE,
                //  backgroundColor: Colors.red,
                imagePath: this.photoUrl,
                placeHolder: Container(
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
              ),
              title: Text(
                this.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              dense: true,
            ),
            onPressed: () {
              showProfile(context, profileId: this.id);
            },
          ),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
