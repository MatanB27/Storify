import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/*
  All the reference to the database collection
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
  DocumentSnapshot doc = await storiesRef
      .doc(ownerUserId)
      .collection('storyId')
      .doc(storyId)
      .get();
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
