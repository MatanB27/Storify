import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

Future<void> _signInWithGoogle(BuildContext context) async {
  try {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signInWithGoogle();
  } catch (e) {
    print(e.toString());
  }
}

Future<void> _signInWithFacebook(BuildContext context) async {
  try {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signInWithFacebook();
  } catch (e) {
    print(e.toString());
  }
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'STORIFY',
              style: TextStyle(
                  fontSize: 60.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40.0,
            ),
            GestureDetector(
              onTap: () => _signInWithGoogle(context),
              child: Container(
                width: 260.0,
                height: 50.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            GestureDetector(
              onTap: () => _signInWithFacebook(context),
              child: Container(
                width: 340.0,
                height: 50.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/continue_with_facebook.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
