import 'package:flutter/cupertino.dart'; //import the fonts package
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart'; //import the sign up buttons package

final GoogleSignIn googleSignIn = GoogleSignIn(); //google variable

class SigninPage extends StatefulWidget {
  //we are using it so we can quicly navigate to our home page from other pages
  static const String id = 'Signin_screen';
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  //the function that will sign us in with google account
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signInWithGoogle();
    } catch (e) {
      print(e.toString());
    }
  }

//this method sign us with the facebook account
  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signInWithFacebook();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    //if the user is not logged in he will see this page
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        //this is the up container design
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
            ),
            image: DecorationImage(
              image: AssetImage(
                  'assets/land1.jpg'), //the image that we see in the up container
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //the custom up container have to children texts widgets
                    children: [
                      //the text style
                      Text(
                        'sign in',
                        //the text
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      //the space between the texts widgets
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'keep your readers close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    //this is the part the we see down the up container
                    //the children of the column are : text, and 2 buttons
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //texts widget with a custom font
                        Text(
                          'storify',
                          style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontSize: 40,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //the space between the text widget and the buttons
                        SizedBox(
                          height: 70,
                        ),
                        //sign in button
                        SignInButton(
                          //the button it self
                          Buttons.Google,
                          text: "Signin with Google",
                          //when the button is get pressed we need to sign up with are google account
                          onPressed: () => _signInWithGoogle(context),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        //the button to sign up with facebook
                        SignInButton(
                          Buttons.Facebook,
                          text: "Signin with Facebook",
                          //when the button get pressed we need to sign up with are facebook account
                          onPressed: () => _signInWithFacebook(context),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //inside the row we have text child
                            Text(
                              'powered by dart',
                              style: TextStyle(
                                color: Colors.blue[800],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Container(
                              child: Row(
                                children: [],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
