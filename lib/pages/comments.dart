import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/loading.dart';
import 'package:storify/widgets/comment_ticket.dart';

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
  int rating = 50;

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
          message('You already rated that story!');
        }

        setState(() {
          rating = 50;
        });
      } else {
        message("You can't rate your own story!");
      }
    }
  }

  // Show an error message for the user
  message(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {}, // No need to put anything, just click "Undo"
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        Text(
          rating.toString(),
          style: TextStyle(fontSize: 17.0),
        ),
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
          child: TextField(
            controller: commentController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              fillColor: Colors.grey[300],
              filled: true,
              icon: Icon(
                Icons.comment,
                color: Colors.black,
              ),
              hintText: 'Add a comment...',
              helperText: 'at least 3 characters',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.black,
                ),
                onPressed: () async {
                  await sendCommentToFirebase();
                },
              ),
            ),
            maxLength: 150,
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

// With this method we can go into the comment page of the story
// We are getting as arguments userid and storyid
// Storyid - help us to know which comments page are we
// userId =- help us to know the current user so he can write a comment
// ownerUserId = help us to know the id of the story owner
showComments(BuildContext context,
    {String storyId, String ownerUserId, String currentUserId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Comments(
        storyId: storyId,
        currentUserId: currentUserId,
        ownerUserId: ownerUserId,
      ),
    ),
  );
}
