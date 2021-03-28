import 'dart:async';

import 'package:flutter/material.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/widgets/loading.dart';

class Logo extends StatefulWidget {
  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  @override
  void initState() {
    super.initState();

    Timer(
        Duration(seconds: 2),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 350.0,
          ),
          SizedBox(
            height: 30.0,
          ),
          Loading(),
        ],
      ),
    );
  }
}
