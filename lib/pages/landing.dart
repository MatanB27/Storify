import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/pages/signin.dart';
import 'package:storify/widgets/loading.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<User>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          if (user == null) {
            return SignIn();
          }
          return Home();
        } else {
          return Scaffold(
            body: Center(
              child: Loading(),
            ),
          );
        }
      },
    );
  }
}
