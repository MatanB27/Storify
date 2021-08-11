import 'package:flutter/material.dart';
import 'package:storify/services/database.dart';

Icon star(double size) {
  return Icon(
    Icons.star,
    color: Colors.amber,
    size: size,
  );
}

/*
 This page will help us show the rating people give to the story,
 And the average rate of the story itself.
 We are using this method in both story and comment page, so we have to check
 In which page we are to adjust the UI
 */
Widget ratingStars(dynamic rating, double size, bool isStory) {
  /*
    This "if" will only be visible on the story, because when someone is
    Rating the story, it will be from 1 to 100
   */

  if (rating == 0 || rating == null) {
    return Text(
      ' No rating yet ',
      style: TextStyle(color: Colors.grey[500], fontSize: 27),
    );
  } else if (rating > 0 && rating < 20) {
    return Row(
      mainAxisAlignment:
          isStory ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        star(size),
      ],
    );
  } else if (rating >= 20 && rating < 40) {
    return Row(
      mainAxisAlignment:
          isStory ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        star(size),
        star(size),
      ],
    );
  } else if (rating >= 40 && rating < 60) {
    return Row(
      mainAxisAlignment:
          isStory ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        star(size),
        star(size),
        star(size),
      ],
    );
  } else if (rating >= 60 && rating < 80) {
    return Row(
      mainAxisAlignment:
          isStory ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        star(size),
        star(size),
        star(size),
        star(size),
      ],
    );
  } else if (rating >= 80) {
    return Row(
      mainAxisAlignment:
          isStory ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        star(size),
        star(size),
        star(size),
        star(size),
        star(size),
      ],
    );
  }

  return Container();
}
