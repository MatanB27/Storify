import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/pages/signin.dart';
import 'package:storify/services/database.dart';
import 'package:storify/widgets/loading.dart';

import '../services/auth_service.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    // Stream builder will check if the user is sign in or not
    // If he is - he will go to the homepage, else signinpage
    final auth = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          if (user == null) {
            return SigninPage();
          }
          return HomePage();
        }
        return loadingCircular();
      },
    );
  }
}
