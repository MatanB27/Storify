import 'package:flutter/material.dart';
import 'package:storify/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'logo.dart';

Future<void> main() async {
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
    return MaterialApp(
      title: 'Storify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.lightBlue[900],
        accentColor: Colors.teal[900],
      ),
      home: Logo(),
    );
  }
}
