import 'package:flutter/cupertino.dart'; // The font package
import 'package:storify/pages/feed_filter.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/pages/top_filter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/pages/all_filter.dart';
import 'package:storify/services/categories.dart';

//==============================The main feed code================//

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with SingleTickerProviderStateMixin {
  /*
     This is a part of the top menu
    With all the tabs : all,top,popular...... 5 tabs

  */
  List<Tab> tabList = [
    Tab(
      child: Text('Feed'),
    ),
    Tab(
      child: Text('All'),
    ),
    Tab(
      child: Text('Top'),
    ),
    Tab(
      child: Text('Category'),
    ),
  ];

  // Current user id
  final String currentUser = auth.currentUser?.uid;

  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabList.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();

    /// When we are disposing the page - the
    removedCategories = [
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ];
    chosenCategories = List.from(allCategories);

    for (int i = 0; i < isChecked.length; i++) {
      isChecked[i] = true;
    }
  }

  /*
    List that will include all of the categories the user wants to see.
    If we are removing a category from this list - the index will become null
    And will move into the removedCategory list.
*/
  List<String> chosenCategories = List.from(allCategories);

  // Remove the category from the filter
  removeChosenCategory(int index) {
    removedCategories[index] = chosenCategories[index];
    chosenCategories[index] = '';
  }

  // Add category back to the chosenCategory
  addChosenCategory(int index) {
    chosenCategories[index] = removedCategories[index];
    removedCategories[index] = '';
  }

  /*
    This list will include all of the removed categories.
    We are keeping them here so we can retrieve the data
  */
  /// This list must be at the same size of the allCategories!!!!!!!!!!!
  List<String> removedCategories = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
  ];

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        //the app bar code with the title, the tab menu and the chat button
        appBar: AppBar(
          toolbarHeight: 110.0,
          backgroundColor: Color(0xff09031D),
          centerTitle: true,
          title: Text(
            'storify',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: TabBar(
              indicatorColor: Colors.white,
              isScrollable: false,
              controller: tabController,
              tabs: tabList,
              labelColor: Colors.white,
            ),
          ),
        ),
        //-------------------The end of the app bar----------//
        // Now we use the lists to show them
        body: TabBarView(
          controller: tabController,
          /*
            The tabs - we can switch between those pages in the "Home" page.
           */
          children: [
            /// Feed page
            FeedFilter(
              userId: currentUser,
              categoriesFilter: chosenCategories,
            ),

            /// All stories page
            AllFilter(
              userId: currentUser,
              categoriesFilter: chosenCategories,
            ),

            /// Top rating page
            TopFilter(
              userId: currentUser,
              categoriesFilter: chosenCategories,
            ),

            /// Filter categories
            /*
              The only Page that doesn't need another page
            */
            Scaffold(
              body: ListView.builder(
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    tileColor: Color(0xff09031D),
                    controlAffinity: ListTileControlAffinity.leading,
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    value: isChecked[index],
                    title: Text(
                      allCategories[index],
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (newValue) {
                      setState(
                        () {
                          isChecked[index] = !isChecked[index];
                          !isChecked[index]
                              ? removeChosenCategory(index)
                              : addChosenCategory(index);
                          //print(isChecked);
                          print('chosen cagetories:');
                          print(chosenCategories);
                          print('removed categories:');
                          print(removedCategories);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
