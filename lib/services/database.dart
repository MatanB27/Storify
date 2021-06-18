import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/feed_filter.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/auth_service.dart';

/*
  All the reference to the database collection.
  Some queries that relates to a certain page will be staying at that page
  And not here.
  If we want to check where every function is being used, press ctrl +
  Mouse on the function
*/
// Users ref
final userRef = FirebaseFirestore.instance.collection('users');

// Storage ref
final storageRef = FirebaseStorage.instance.ref();

// Chat ref
final chatRef = FirebaseFirestore.instance.collection('chatrooms');

// MessageRef
final messageRef = FirebaseFirestore.instance.collection('messages');

// Following ref
final followingRef = FirebaseFirestore.instance.collection('following');

// Followers ref
final followersRef = FirebaseFirestore.instance.collection('followers');

// Stories ref
final storiesRef = FirebaseFirestore.instance.collection('stories');

// Comments ref
final commentsRef = FirebaseFirestore.instance.collection('comments');

// Reports ref
final reportsRef = FirebaseFirestore.instance.collection('reports');

///-----------------------------------------------------------------------------
/*
  This method will check the scores in the commentsRef and will return us
  The average of each story.
  Square bracelets means the argument is not required
 */
getAverageRatingFromStoriesRef([String storyId]) async {
  double average = 0;
  int counter = 0;
  await commentsRef.doc(storyId).collection('userId').get().then((value) => {
        value.docs.forEach((element) {
          average += element.get('rating');
          counter++;
        }),
      });

  average = average / counter;
  print(average);
  print(counter);
  return average;
}

/*
  Every time a use is giving his review on some story,
  It will be updated in the storiesRef
 */
updateAverageStoryRating(
    dynamic rating, String storyId, String ownerUserId) async {
  DocumentSnapshot doc = await storiesRef.doc(storyId).get();
  dynamic total = await doc.get('total');
  dynamic countRating = await doc.get('countRating');
  dynamic average = await doc.get('average');

  total += rating;
  countRating++;
  average = (total / countRating); // Casting
  doc.reference.set({
    'average': average,
    'countRating': countRating,
    'total': total,
  }, SetOptions(merge: true));
}

///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/*
  Logout method that will send us back go the sign in screen
  This method will be used inside the confirmed sign out method
 */
Future<void> _signOut(BuildContext context) async {
  try {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
  } catch (e) {
    print(e.toString());
  }
  Navigator.popUntil(context, ModalRoute.withName("/"));
}

/*
  Alert dialog that will ask us if we want to log out.
  Will be used in the edit profile screen.
 */
Future<void> confirmSignOut(BuildContext context) async {
  try {
    final didRequestSignOut = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Accept'),
          ),
        ],
      ),
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  } catch (e) {
    print(e.toString());
  }
}

///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/*
  SignInWithGoogle && SignInWithFacebook will both be in the sign in page.
  Each of them will sign us in with a token from facebook or google.
 */
Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signInWithGoogle();
  } catch (e) {
    print(e.toString());
  }
}

Future<void> signInWithFacebook(BuildContext context) async {
  try {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signInWithFacebook();
  } catch (e) {
    print(e.toString());
  }
}

///-----------------------------------------------------------------------------
/*
  This method will return us a list of the user ids that the user is currently
  following.
  The user ids will be the ids of the followers of the current user.
*/
Future<List<String>> getFollowers(String userId) async {
  List<String> followersList = [];
  QuerySnapshot snapshot =
      await followersRef.doc(userId).collection('userFollowers').get();
  followersList = snapshot.docs.map((e) => e.id).toList();
  print(followersList);
  return followersList;
}
