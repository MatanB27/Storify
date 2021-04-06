import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/user.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance; //instance of firebase auth
  User get currentUser =>
      _firebaseAuth.currentUser; //current user from firebase

  //notify about changes to the user sign in state(sign in or sign out)
  Stream<User> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    await _firebaseAuth.signOut();
  }

  //login with facebook
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
        //Storing the user data in the firestore database
        //if dosent exist - we create it
        if (!doc.exists) {
          userRef.doc(currentUser.uid).set({
            "id": currentUser.uid,
            "displayName": currentUser.displayName,
            "photoUrl": currentUser.photoURL,
            "email": currentUser.email,
            "bio": "",
            "timestamp": timestampNow,
          });
          //now all the set data we are storing in doc
          doc = await userRef.doc(currentUser.uid).get();
        }
        //current user is now this data
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

  //sign in with google
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
        //Storing the user data in the firestore database
        //if dosent exist - we create it
        if (!doc.exists) {
          userRef.doc(currentUser.uid).set({
            "id": currentUser.uid,
            "displayName": currentUser.displayName,
            "photoUrl": currentUser.photoURL,
            "email": currentUser.email,
            "bio": "",
            "timestamp": timestampNow,
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
