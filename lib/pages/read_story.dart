import 'package:flutter/material.dart';
import 'package:lipsum/lipsum.dart' as lipsuam;
import 'package:animated_button/animated_button.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'package:readmore/readmore.dart';

class ReadStory extends StatefulWidget {
  final String storyId;
  final String ownerId;
  final String commentsId;

  ReadStory({this.storyId, this.ownerId, this.commentsId});
  @override
  _ReadStoryState createState() => _ReadStoryState();
}

//TODO: make sure it will work with firebase
class _ReadStoryState extends State<ReadStory> {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    'shay ohayon',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 27,
                backgroundImage: NetworkImage(
                    'https://www.pandasecurity.com/en/mediacenter/src/uploads/2013/11/pandasecurity-facebook-photo-privacy.jpg'),
              ),
            ),
          ],
          toolbarHeight: 60,
          elevation: 0,
        ),
        body: ListView(
          children: [
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Science Fiction',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffC3C3E0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'how to make you smile ?',
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://im.rediff.com/getahead/2015/nov/25smile.jpg?w=670&h=900'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '" hello test test "',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffC3C3E0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ReadMoreText(
                    lipsuam.createParagraph(),
                    trimLines: 2,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 100,
                ),
                AnimatedButton(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.chat_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                  height: 40,
                  shadowDegree: ShadowDegree.dark,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
