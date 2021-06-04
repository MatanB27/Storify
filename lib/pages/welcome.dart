import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        body: Text(
          'Welcome to Storify!',
          style: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
