import 'package:flutter/material.dart';

/*
  This service is used for building the icon button in the read story page
*/
class BuildIcon extends StatelessWidget {
  final IconData icon;
  final Function onPressed;
  final double size;
  final double padding;
  final Color color; // Color is optional
  BuildIcon({this.icon, this.onPressed, this.size, this.padding, this.color});
  @override
  Widget build(BuildContext context) {
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
