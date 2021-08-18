import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff09031D),
      appBar: AppBar(
        title: Text('Error 404 - Page not found'),
        backgroundColor: Color(0xff09031D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          child: Text(
            'The page you are looking for has been deleted',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
