import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/user.dart';
import 'package:storify/services/keywords.dart';

class AuthService {
  // Instance of firebase auth
  final _firebaseAuth = FirebaseAuth.instance;

  // Current user from firebase
  User get currentUser => _firebaseAuth.currentUser;

  // Notify about changes to the user sign in state(sign in or sign out)
  Stream<User> authStateChanges() => _firebaseAuth.authStateChanges();

  // Signout method
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    await _firebaseAuth.signOut();
  }

  // Login with facebook
  Future<User> signInWithFacebook() async {
    final fb = FacebookLogin();
    final response = await fb.logIn(['email']);
    switch (response.status) {
      case FacebookLoginStatus.loggedIn:
        final accessToken = response.accessToken;
        final userCredential = await _firebaseAuth.signInWithCredential(
          FacebookAuthProvider.credential(accessToken.token),
        );
        DocumentSnapshot doc = await userRef.doc(currentUser.uid).get();
        Map<String, String> messageMap = {
          // for chat
        };
        // Storing the user data in the firestore database
        // If doesnt exist - we create it
        if (!doc.exists) {
          userRef.doc(currentUser.uid).set({
            "id": currentUser.uid,
            "displayName": currentUser.displayName,
            "displayNameSearch": currentUser.displayName.toLowerCase(),
            "photoUrl": currentUser.photoURL,
            "email": currentUser.email,
            "bio": "",
            "keywords": setSearchParam(currentUser.displayName),
            "messages": messageMap,
            "timestamp": timestampNow,
          });
          // Now all the set data we are storing in doc
          doc = await userRef.doc(currentUser.uid).get();
        }
        // Current user is now this data
        currentUserHome = UserClass.fromDocuments(doc);
        return userCredential.user;
      case FacebookLoginStatus.cancelledByUser:
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
        );
      case FacebookLoginStatus.error:
        throw FirebaseAuthException(
          code: 'ERROR_FACEBOOK_LOGIN_FAILED',
        );
      default:
        UnimplementedError();
    }
  }

  // Sign in with google
  Future<User> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        final userCredential = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
        DocumentSnapshot doc = await userRef.doc(currentUser.uid).get();
        // Storing the user data in the firestore database
        // If doesnt exist - we create it
        Map<String, String> messageMap = {
          // for chat
        };
        if (!doc.exists) {
          userRef.doc(currentUser.uid).set({
            "id": currentUser.uid,
            "displayName": currentUser.displayName,
            "displayNameSearch": currentUser.displayName.toLowerCase(),
            "photoUrl": currentUser.photoURL,
            "keywords": setSearchParam(currentUser.displayName),
            "email": currentUser.email,
            "bio": "",
            "timestamp": timestampNow,
            "messages": messageMap,
          });
          //now all the set data we are storing in doc
          doc = await userRef.doc(currentUser.uid).get();
        }
        //current user is now this data
        currentUserHome = UserClass.fromDocuments(doc);
        return userCredential.user;
      } else {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_ID_TOKEN',
          message: 'Missing Google id token',
        );
      }
    } else {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }
}
