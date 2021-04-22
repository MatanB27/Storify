import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';
import 'package:storify/widgets/user_ticket.dart';
import 'package:cached_network_image/cached_network_image.dart';

//TODO: make the search better
//TODO: when i click on tickets open a menu that ask me if i want to
//TODO: send a message / go to profile

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  //mixin - //help us save he state of this page when we move to another page
  //text editor variable
  TextEditingController searchController = TextEditingController();
  //query variable
  Future<QuerySnapshot> searchResults;

  //handeling the query with the firebase
  handleSearch(String query) {
    //query variable
    Future<QuerySnapshot> users =
        userRef.where("displayName", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResults = users;
    });
  }

  //clear the results
  clearSearch() {
    searchController.clear();
  }

  //building the search bar at the app bar position
  AppBar searchBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          prefixIcon: Icon(
            Icons.account_circle,
            size: 30.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  //building the search results
  buildSearchResults() {
    return FutureBuilder(
      future: searchResults,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        List<UserTicket> searchResults = [];
        snapshot.data.docs.forEach((doc) {
          UserClass user = UserClass.fromDocuments(doc);
          UserTicket searchResult = UserTicket(
            displayName: user.displayName,
            photoUrl: user.photoUrl,
            id: user.id,
          );
          searchResults.add(searchResult);
        });

        return ListView(
          children: searchResults,
        );
      },
    );
  }

  //TODO: maybe add a picture
  //what will happend before we see the user results
  Container noContent() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Text(
                'Search users...',
                style: TextStyle(fontSize: 45.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //this variable is to keep the state of the screen alive,
  //even if we move to another screen.
  //super.build(context) is also part of that.
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: searchBar(),
      body: searchResults == null ? noContent() : buildSearchResults(),
    );
  }
}
