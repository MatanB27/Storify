import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';

/*
  The main page, the user can read the stories of the users he follow
  //TODO: finish
*/
class FeedFilter extends StatefulWidget {
  final String userId;
  FeedFilter({this.userId});
  @override
  _FeedFilterState createState() => _FeedFilterState();
}

class _FeedFilterState extends State<FeedFilter> {
  @override
  void initState() {
    super.initState();
    print(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        body: Container(
          child: Text('FEED'),
        ),
      ),
    );
  }
}
