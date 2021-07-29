import 'package:flutter/material.dart';

/*
  This service is used for building the icon button in the read story page
*/
class BuildIcon extends StatelessWidget {
  final IconData icon;
  final Function onPressed;

  BuildIcon({this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        this.icon,
        color: Colors.grey,
        size: 27,
      ),
      onPressed: this.onPressed,
    );
  }
}
// GestureDetector BuildIcon(Icon icon, Function onTap) {
//   return GestureDetector(
//     child: Icon(
//       Icons.play_arrow,
//       color: Colors.grey,
//       size: 28,
//     ),
//     onTap: () {
//       speak(story);
//     },
//   );
// }
// }
