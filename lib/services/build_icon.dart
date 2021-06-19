import 'package:flutter/material.dart';

/*
  This service is used for building the icon button in the read story page
*/
class BuildIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Function onPressed;

  BuildIcon({this.icon, this.color, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: this.color),
      child: IconButton(
        icon: Icon(
          this.icon,
          color: Colors.black,
        ),
        onPressed: this.onPressed,
      ),
    );
  }
}
