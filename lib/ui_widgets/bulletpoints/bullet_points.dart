import 'package:flutter/material.dart';

class BulletPoint extends StatelessWidget {
  final String text;

  BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.only(top: 6.0), // Adjust the top padding as needed
          child: Icon(
            Icons
                .brightness_1, // You can use a different icon or custom bullet here
            size: 12,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8.0), // Adjust the width as needed
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
