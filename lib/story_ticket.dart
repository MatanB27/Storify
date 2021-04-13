import 'package:flutter/material.dart';

class StoryTickets extends StatelessWidget {
  final String photoURL;
  final String displayName;
  final String title;
  final String categories;
  final String rating;
  final String timestamp;

  StoryTickets(this.photoURL, this.title, this.categories, this.rating,
      this.timestamp, this.displayName);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.only(bottom: 20.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  height: 65.0,
                  width: 65.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(this.photoURL),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                Text(
                  this.displayName,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    this.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    this.categories,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 5.0,
                      ),
                      Icon(Icons.star),
                      Text(
                        this.rating,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(Icons.date_range),
                      Text(this.timestamp),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
