import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/landing.dart';
import 'services/auth_service.dart';
import 'package:flutter/services.dart';

// This is the main page.
// From this page we are reaching all of the other pages and widgets in the app.
void main() async {
  // This method need to be called before any firebase plugin
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Change the color of the status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white70,
      ),
    );
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Storify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.lightBlue[900],
          accentColor: Colors.teal[900],
        ),
        home: Landing(),
      ),
    );
  }
}
