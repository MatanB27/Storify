import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';
import 'package:storify/widgets/user_ticket.dart';

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

  //TODO: maybe change the query
  // Handling the query with the firebase
  // It will show us in real-time the people we are searching
  handleSearch(String query) async {
    var y = userRef.where('keywords', arrayContains: query).get();
    Future<QuerySnapshot> users;
    y.then(
      (value) => value.docs.forEach((element) {
        if (element.exists) {
          dynamic doc = element.data()['displayNameSearch'];
          print(doc);
          users = userRef.where("displayNameSearch", isGreaterThanOrEqualTo: doc).get();
          setState(() {
            searchResults = users;
          });
        }
      }),
    );
  }

  // Clear the results
  clearSearch() {
    searchController.clear();
  }

  // Building the search bar at the app bar position
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
                          onChanged: (query) {
                            handleSearch(query.toLowerCase());
                            print(query);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: Colors.blue[300],
                            ),
                            border: InputBorder.none,
                          ),
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
                      searchResults = null;
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

  //what will happend before we see the user results
  Container noContent() {
    return Container(
      child: Expanded(
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 160.0,
            ),
            Text(
              'Search users...',
              style: TextStyle(
                fontSize: 38.0,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // This variable is to keep the state of the screen alive,
  // Even if we move to another screen.
  // Super.build(context) is also part of that.
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/search_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
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
      ),
    );
  }
}
