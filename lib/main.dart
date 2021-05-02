import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/landing.dart';
import 'auth_service.dart';

//TODO: repair design
//TODO: login google & facebook with the same email bug
//TODO: animation text at feed page
//TODO: make stars functions in rating
void main() async {
  //this method need to be called before any firebase plugin
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
