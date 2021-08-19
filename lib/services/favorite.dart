import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storify/services/database.dart';

/*
  Class for favorites functions
  Check if the story is favorite or not
   */
class Favorite {
  // I had to init it here so it won't have bugs
  bool isFavorite = false;

  /*
    Check if the current story is favorite or not
  */
  checkIfFavorite(String storyId, String currentUserId) {
    List<String> favorites;
    storiesRef.doc(storyId).get().then((value) => {
          value.data().forEach((key, value) {
            if (key == 'favorites') {
              favorites = List.from(value);
              if (favorites != null) {
                if (favorites.contains(currentUserId)) {
                  isFavorite = true;
                } else {
                  isFavorite = false;
                }
              }
            }
          })
        });
  }

  /*
  Add or remove from user's favorite
   */
  addOrRemoveFromFavorites(String storyId, String currentUser) {
    if (isFavorite) {
      // Removing from favorites
      removeFromFavorites(storyId, currentUser);

      isFavorite = false;
    } else {
      // Adding from favorites
      addToFavorites(storyId, currentUser);

      isFavorite = true;
    }
  }

  /*
  Remove from favorites
   */
  removeFromFavorites(String storyId, String currentUserId) {
    storiesRef.doc(storyId).update({
      "favorites": FieldValue.arrayRemove([currentUserId])
    });
  }

  /*
  Adding to favorites
   */
  addToFavorites(String storyId, String currentUserId) {
    storiesRef.doc(storyId).update({
      "favorites": FieldValue.arrayUnion([currentUserId]),
    });
  }
}
