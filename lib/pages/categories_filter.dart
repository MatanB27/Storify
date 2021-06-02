import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';

/*
  The page where the user can choose to filter stories by choosing categories
  //TODO: might delete or finish
*/
class CategoriesFilter extends StatefulWidget {
  final String userId;
  CategoriesFilter({this.userId});
  @override
  _CategoriesFilterState createState() => _CategoriesFilterState();
}

class _CategoriesFilterState extends State<CategoriesFilter> {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        body: Container(
          child: Text('Categories'),
        ),
      ),
    );
  }
}
