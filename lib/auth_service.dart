import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:storify/pages/home.dart';
import 'user.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  Stream<User> authStateChanges() => _firebaseAuth.authStateChanges();
  User get currentUser => _firebaseAuth.currentUser;

  Future<User> signInWithFacebook() async {
    final fb = FacebookLogin();
    final response = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    switch (response.status) {
      case FacebookLoginStatus.Success:
        final accessToken = response.accessToken;
        final userCredential = await _firebaseAuth.signInWithCredential(
          FacebookAuthProvider.credential(accessToken.token),
        );
        User currentUser = await FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          print('user is logged in');

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
          currentUserClass = UserClass.fromDocuments(doc);
        }
        return userCredential.user;
      case FacebookLoginStatus.Cancel:
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      case FacebookLoginStatus.Error:
        throw FirebaseAuthException(
          code: 'ERROR_FACEBOOK_LOGIN_FAILED',
          message: response.error.developerMessage,
        );
      default:
        UnimplementedError();
    }
  }

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
        final GoogleSignInAccount user = googleSignIn.currentUser;
        //variable that store userid document, we check if it exist or not
        DocumentSnapshot doc = await userRef.doc(user.id).get();

        //if dosent exist - we create it
        if (!doc.exists) {
          userRef.doc(user.id).set({
            "id": user.id,
            "displayName": user.displayName,
            "photoUrl": user.photoUrl,
            "email": user.email,
            "bio": "",
            "timestamp": timestampNow,
          });
          //now all the set data we are storing in doc
          doc = await userRef.doc(user.id).get();
        }
        //current user is now this data
        currentUserClass = UserClass.fromDocuments(doc);
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

  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    await _firebaseAuth.signOut();
    // setState(() {
    //   isAuth = false;
    // });
    print("user is logged out");
  }
}
