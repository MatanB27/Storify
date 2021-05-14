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
      message('You already have 3 genres');
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

  // Will give some kind of a message at the bottom of the screen
  message(String text) {
    final snackBar = SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {}, // No need to put anything, just click "Undo"
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Publish story method, it will only work if the user have story title,
  // Categories or the story itself
  // It will all add to the firebase.
  //TODO: use database
  publishStory() {
    print(story.text.toString().trim().length);
    print(titleStory.text.toString().trim().length);
    print(chosenCategories);
    if (story.text.toString().trim().length < 20 ||
        titleStory.text.toString().trim().length < 3 ||
        chosenCategories.length == 0) {
      message('Make sure you fill everything correctly.');
    } else {
      message('Congratulations, You posted a new story!');
    }
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
            TextFormField(
              controller: titleStory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                fillColor: Colors.white,
                filled: true,
                icon: Icon(
                  Icons.title,
                  color: Colors.black,
                ),
                hintText: 'Write your title...',
                helperText: 'at least 3 characters',
              ),
              maxLength: 30,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Pick the story genres - up to 3 genres:',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 12,
            ),
            GridView.builder(
                // All categories
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                        color: Colors.red[300],
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
              'Your genres:',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 12,
            ),
            GridView.builder(
                // All categories
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
            Divider(
              color: Colors.black,
              thickness: 4.0,
            ),
            TextField(
              controller: story,
              maxLength: 5000,
              maxLines: 30,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                hintText: 'Tell us your story here...',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            FloatingActionButton(
                child: Icon(
                  Icons.add,
                  size: 35,
                ),
                backgroundColor: Colors.lightBlueAccent,
                onPressed: () {
                  publishStory();
                }),
            SizedBox(
              height: 10,
            ),
            Text(
              'By clicking the publish button - you are agreeing '
              'that you are the owner of the story and you didnt stole it from other places.'
              ' Breaking those rules will result in deleting your story or deleting your account',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
