import 'package:flutter/material.dart';

class StackedIconsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isLiked = false;
    return GestureDetector(
      onTap: () {
        // Handle the button tap action here.
        isLiked = !isLiked;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circle Icon
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,
            ),
          ),
          // Heart Icon (Stacked on top of Circle)
          Icon(
            Icons.favorite,
            color: Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
