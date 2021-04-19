import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lipsum/lipsum.dart' as lipsum;
import 'package:storify/widgets/story_ticket.dart';
import 'package:line_icons/line_icons.dart';

class ReadStoryData extends StatefulWidget {
  @override
  _ReadStoryDataState createState() => _ReadStoryDataState();
}

class _ReadStoryDataState extends State<ReadStoryData> {
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
                    //  clipper: OvalBottomBorderClipper(),
                    child: Image(
                      height: 250.0,
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
              Positioned.fill(
                bottom: 10.0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RawMaterialButton(
                    padding: EdgeInsets.all(10.0),
                    elevation: 12.0,
                    onPressed: () => print('Play Video'),
                    shape: CircleBorder(),
                    fillColor: Colors.white,
                    child: Icon(
                      LineIcons.headphones,
                      size: 35,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Positioned(
                bottom: 0.0,
                left: 20.0,
                child: IconButton(
                  onPressed: () => print('Add to My List'),
                  icon: Icon(Icons.report_problem),
                  iconSize: 40.0,
                  color: Colors.black,
                ),
              ),
              Positioned(
                bottom: 0.0,
                right: 25.0,
                child: IconButton(
                  onPressed: () => print('Share'),
                  icon: Icon(Icons.share),
                  iconSize: 35.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Escape from Alcatraz',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[],
                    ),
                    Column(
                      children: <Widget>[],
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(height: 2.0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              lipsum.createParagraph(numParagraphs: 10),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
