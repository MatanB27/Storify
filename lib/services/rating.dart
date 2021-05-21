import 'package:flutter/material.dart';

// This page will help us show the rating people give to the story,
// And the average rate of the story itself.
Widget ratingStars(int rating) {
  if (rating == 0) {
    return Text(
      'No rating yet!',
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    );
  } else if (rating > 0 && rating < 20) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        )
      ],
    );
  } else if (rating >= 20 && rating < 40) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
      ],
    );
  } else if (rating >= 40 && rating < 60) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
      ],
    );
  } else if (rating >= 60 && rating < 80) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
      ],
    );
  } else if (rating >= 80) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 32,
        ),
      ],
    );
  }
  return Container();
}
