import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storify/pages/search.dart';

//this class will show us the user tickets
//TODO: when we will have the database of the stories, add stories here!!
class UserTicket extends StatelessWidget {
  final String displayName;
  final String photoUrl;
  //int stories; //TODO

  UserTicket({
    this.displayName,
    this.photoUrl,

    // this.stories, //TODO
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(this.photoUrl),
        ),
        title: Text(
          this.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        //subtitle: Text('Stories: ${this.stories}'), //TODO
        dense: true,
        onTap: () {
          profileOrMessage(); //TODO: the funcion is in the top search page
          print('hello');
        },
      ),
    );
  }
}
