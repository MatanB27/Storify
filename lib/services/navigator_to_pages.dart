import 'package:flutter/material.dart';
import 'package:storify/pages/comments.dart';
import 'package:storify/pages/edit_profile.dart';
import 'package:storify/pages/feed_filter.dart';
import 'package:storify/pages/followers.dart';
import 'package:storify/pages/following.dart';
import 'package:storify/pages/private_message.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/pages/read_story.dart';
import 'package:storify/pages/report.dart';

/*
  This page will include every navigator method of the app
  If we want to navigator to another page just use the function from here
  Or add them here
 */

/*
  Going back
 */
goBack(BuildContext context) {
  Navigator.pop(context);
}

/*
  With this method we can go into the comment page of the story
   We are getting as arguments userid and storyid
   Storyid - help us to know which comments page are we
   userId =- help us to know the current user so he can write a comment
   ownerUserId = help us to know the id of the story owner

 */
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

/*
  Going into our own profile or another user profile
 */
showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}

/*
  Going into a private message with other users
 */
showPrivateMessage(BuildContext context, {String privateId, String roomId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PrivateMessage(
        privateId: privateId,
        currentRoomId: roomId,
      ),
    ),
  );
}

/*
  Going into the followers page according to the profileId
  We are also getting the followerList argument to show the list of the
  followers
 */
showFollowers(BuildContext context,
    {String profileId, List<String> followersList}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Followers(
        followersId: profileId,
        followersList: followersList,
      ),
    ),
  );
}

/*
  Same thing as showFollowers, It will just get different list and will
  Go to the following page.
 */
showFollowing(BuildContext context,
    {String profileId, List<String> followingList}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Following(
        followingId: profileId,
        followingList: followingList,
      ),
    ),
  );
}

/*
  A user can go to edit profile page only from his own page,
  Edit profile button won't be visible if he is watching somebody else profile.
 */
showEditProfile(BuildContext context, String currentUserId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProfile(
        currentUserId: currentUserId,
      ),
    ),
  );
}

/*
  Method that help us go inside the read story from every story ticket place
  In the app
 */
showReadStory(BuildContext context,
    {String storyId, String commentId, String ownerId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReadStory(
        storyId: storyId,
        ownerId: ownerId,
      ),
    ),
  );
}

/*
  Show the first page that the user is seeing - FilterFeed
*/

showFilterFeed(BuildContext context, String currentUser) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FeedFilter(
        userId: currentUser,
      ),
    ),
  );
}

showReport(BuildContext context, String currentUser, String storyId) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Report(
        currentUserId: currentUser,
        storyId: storyId,
      ),
    ),
  );
}
