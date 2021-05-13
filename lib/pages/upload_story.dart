import 'package:flutter/material.dart';
import 'package:storify/services/categories.dart';

// The page where we uploading the story to the data base.
class UploadStory extends StatefulWidget {
  final String userId;

  UploadStory({this.userId});
  @override
  _UploadStoryState createState() => _UploadStoryState();
}
// TODO: If the user wont pick any photo, he will get a default photo

// Mixin - help us save he state of this page when we move to another page
class _UploadStoryState extends State<UploadStory>
    with AutomaticKeepAliveClientMixin<UploadStory> {
  // This variable is to keep the state of the screen alive,
  // Even if we move to another screen.
  // Super.build(context) is also part of that.

  // Text fields variables
  TextEditingController titleStory = TextEditingController();
  TextEditingController story = TextEditingController();

  // All the categories in Storify app.
  List<String> allCategories = [
    'Drama',
    'Poetry',
    'Fantasy',
    'Horror',
    'Humor',
    'Mystery',
    'Reality',
    'Parody',
    'Romantic',
    'Novel',
    'Science',
  ];

  // Chosen categories -> up to 3 categories
  // User will have to pick at least 1 category
  List<String> chosenCategories = [];

  // We are picking a category, removing it from the AllCategories
  // And adding it to chosenCategories, if chosenCategories length is 3,
  // We will get an error message that we cant take more categories
  pickACategory(int index) {
    if (chosenCategories.length < 3) {
      String category = allCategories.removeAt(index);
      chosenCategories.add(category);
    } else {
      final snackBar = SnackBar(
        content: Text('You already have 3 genres'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {}, // No need to put anything, just click "Undo"
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // Will remove the category from the chosenCategories list and add it
  // Into AllCategories
  removeACategory(int index) {
    String category = chosenCategories.removeAt(index);
    allCategories.add(category);
  }

  // When we quit the app
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleStory.dispose();
    story.dispose();
    super.dispose();
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Upload Story',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: titleStory,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.menu_book,
                  color: Colors.black,
                ),
                hintText: 'Write your title here...',
              ),
              maxLength: 30,
            ),
            Text(
              'Pick the story genre - up to 3 genres:',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 12,
            ),
            GridView.builder(
                // All categories
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    childAspectRatio: 8 / 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10),
                itemCount: allCategories.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        pickACategory(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Colors.greenAccent,
                      ),
                      child: Center(child: Text(allCategories[index])),
                      height: 25,
                    ),
                  );
                }),
            SizedBox(
              height: 12,
            ),
            Text(
              'Your categories:',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 12,
            ),
            GridView.builder(
                // All categories
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    childAspectRatio: 8 / 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10),
                itemCount: chosenCategories.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        removeACategory(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Colors.lightBlueAccent,
                      ),
                      child: Center(child: Text(chosenCategories[index])),
                      height: 25,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
