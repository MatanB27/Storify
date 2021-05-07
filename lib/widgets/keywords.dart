// If we are editing the displayName, we will edit the keywords
// Search as well.
setSearchParam(String name) {
  List<String> keywords = [];
  String temp = "";
  for (int i = 0; i < name.length; i++) {
    temp = temp + name[i].toLowerCase();
    keywords.add(temp);
  }
  return keywords;
}
