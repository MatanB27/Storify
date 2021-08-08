import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/services/rating.dart';
import 'package:storify/widgets/comment_ticket.dart';
import 'package:storify/services/scaffold_message.dart';

class Comments extends StatefulWidget {
  final String storyId;
  final String currentUserId;
  final String ownerUserId;
  Comments({this.storyId, this.currentUserId, this.ownerUserId});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  void initState() {
    super.initState();
    print(widget.currentUserId);
    print(widget.storyId);
  }

  // The current rating a user can choose. it can be changed
  dynamic rating = 50;

  // comment controller for the text field
  TextEditingController commentController = TextEditingController();

  // We are taking those values from userRef
  String displayName;
  String photoUrl;

  //TODO: maybe add no content button
  // Then we press the send button - The data will be send to the firebase.
  sendCommentToFirebase() async {
    if (commentController.text.toString().trim().length >= 3) {
      if (widget.ownerUserId != widget.currentUserId) {
        String comment = commentController.text.toString();
        commentController.clear();

        DocumentSnapshot doc = await userRef.doc(widget.currentUserId).get();
        displayName = await doc.get('displayName');
        photoUrl = await doc.get('photoUrl');

        // A user can give his opinion only once on each story.
        // If he already commented - he will be forbidden from posting again.
        DocumentSnapshot commentDoc = await commentsRef
            .doc(widget.storyId)
            .collection('userId')
            .doc(widget.currentUserId)
            .get();

        if (!commentDoc.exists) {
          // Creating first the document

          await updateAverageStoryRating(
              rating, widget.storyId, widget.ownerUserId);
          commentsRef.doc(widget.storyId).set({});
          commentsRef
              .doc(widget.storyId)
              .collection('userId')
              .doc(widget.currentUserId)
              .set({
            'displayName': displayName,
            'photoUrl': photoUrl,
            'comment': comment,
            'uid': widget.currentUserId,
            'rating': rating,
            'timeStamp': Timestamp.now(),
          });
        } else {
          showMessage(context, 'You already rated that story!');
        }

        setState(() {
          rating = 50;
        });
      } else {
        showMessage(context, "You can't rate your own story!");
      }
    } else {
      showMessage(context, "Comment must have at least 3 characters.");
    }
  }

  // Taking the comments from the firebase and showing them in the UI.
  commentTickets() {
    return StreamBuilder(
      stream: commentsRef
          .doc(widget.storyId)
          .collection('userId')
          .orderBy('timeStamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        final comments = snapshot.data.docs;
        List<CommentTicket> tickets = [];
        for (var comment in comments) {
          CommentTicket ticket = new CommentTicket(
            timeStamp: comment.data()['timeStamp'],
            comment: comment.data()['comment'],
            uid: comment.data()['uid'],
            photoUrl: comment.data()['photoUrl'],
            displayName: comment.data()['displayName'],
            rating: comment.data()['rating'],
          );
          tickets.add(ticket);
        }
        return Expanded(
          child: ListView(
            shrinkWrap: true,
            children: tickets,
          ),
        );
      },
    );
  }

  // The comment block where the user can send hit comment.
  sendCommentBlock() {
    return Column(
      children: [
        ratingStars(rating, 22, true),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Color(0xFF8D8E98),
            thumbColor: Colors.blue,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: rating.toDouble(),
            min: 1,
            max: 100,
            onChanged: (double newValue) {
              setState(() {
                rating = newValue.toInt();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: EdgeInsets.all(15.0),
            height: 61,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35.0),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 3),
                            blurRadius: 5,
                            color: Colors.grey)
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.comment,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                              controller: commentController,
                              maxLength: 150,
                              obscureText: false,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintText: 'Add a comment...',
                                  hintStyle:
                                      TextStyle(color: Colors.blueAccent),
                                  border: InputBorder.none)),
                        ),
                        SizedBox(width: 15),
                        Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                              color: Colors.blueAccent, shape: BoxShape.circle),
                          child: InkWell(
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              await sendCommentToFirebase();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // When we are closing the page
  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Color(0xff09031D),
        body: SafeArea(
          child: Column(
            children: [
              commentTickets(),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: sendCommentBlock(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
