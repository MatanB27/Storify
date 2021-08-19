import 'package:flutter/material.dart';

/*
  This service is used for building the icon button in the read story page
*/
class BuildIcon extends StatelessWidget {
  //Attributes
  final IconData icon;
  final Function onPressed;
  final double size;
  final double padding;
  final Color color;
  //Builder
  BuildIcon({this.icon, this.onPressed, this.size, this.padding, this.color});
  @override
  Widget build(BuildContext context) {
    // UI
    return IconButton(
      padding: EdgeInsets.all(this.padding),
      constraints: BoxConstraints(),
      icon: Icon(
        this.icon,
        color: this.color,
        size: this.size,
      ),
      onPressed: this.onPressed,
    );
  }
}
