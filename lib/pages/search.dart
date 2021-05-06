import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';
import 'package:storify/widgets/user_ticket.dart';

//TODO: make the search better

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
  bool _folded = true;

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
  Widget searchBar() {
    return Center(
      child: AnimatedContainer(
        duration: Duration(microseconds: 400),
        width: _folded ? 56 : 200,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: kElevationToShadow[6],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 16),
                  child: !_folded
                      ? TextFormField(
                          decoration: InputDecoration(
                            hintText: 'search',
                            hintStyle: TextStyle(
                              color: Colors.blue[300],
                            ),
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: handleSearch,
                        )
                      : null),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_folded ? 32 : 0),
                    topRight: Radius.circular(32),
                    bottomLeft: Radius.circular(_folded ? 32 : 0),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      _folded ? Icons.search : Icons.close,
                      color: Colors.blue[900],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _folded = !_folded;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
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

        return Expanded(
          child: ListView(
            children: searchResults,
          ),
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
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          searchBar(),
          SizedBox(
            height: 15.0,
          ),
          searchResults == null ? noContent() : buildSearchResults(),
        ],
      ),
    );
  }
}
