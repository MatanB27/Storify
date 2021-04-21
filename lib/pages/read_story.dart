import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lipsum/lipsum.dart' as lipsum;
import 'package:storify/widgets/story_ticket.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:line_icons/line_icons.dart';
import 'package:storify/user.dart';
import 'package:slider_button/slider_button.dart';
import 'package:storify/pages/read_story_data.dart';
import 'package:animated_button/animated_button.dart';

class ReadStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                child: Hero(
                  tag: 'animation',
                  child: ClipPath(
                    clipper: OvalBottomBorderClipper(),
                    child: Image(
                      height: 400.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        'https://m.media-amazon.com/images/M/MV5BNWRiZGRjOGQtZjIzYy00MDc0LWIwYzktYTJlMTJlMWVkZjk5XkEyXkFqcGdeQXVyMjc4NzY1MTM@._V1_.jpg',
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.only(left: 30.0),
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    iconSize: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Escape from Alcatraz',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              CircleAvatar(
                radius: 56,
                backgroundImage: NetworkImage(
                    'https://i.ytimg.com/vi/NjWJ5iGjhL0/maxresdefault.jpg'),
              ),
              Text(
                'alfonso milan',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'rating',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                ),
              ),

              Text(
                '9.3',
                style: TextStyle(fontSize: 25.0),
              ),
              SizedBox(
                height: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        'date',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        '14.04.2021',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        'category',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'action',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: 2.0),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 50.0),

              SizedBox(
                height: 10,
              ),
              //     Container(
              //     height: 120.0,
              //    child: SingleChildScrollView(
              //       child: Text(
              //     lipsum.createParagraph(numParagraphs: 3),
              //       style: TextStyle(
              //       color: Colors.black54,
              //         fontSize: 25,
              //         ),
              //        ),
              //      ),
              //     ),

              AnimatedButton(
                child: Text(
                  'go to read',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReadStoryData()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
