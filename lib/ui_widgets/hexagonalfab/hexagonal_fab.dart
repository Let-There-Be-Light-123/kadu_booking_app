import 'dart:math';

import 'package:flutter/material.dart';

class HexagonalFab extends StatelessWidget {
  const HexagonalFab({super.key});

  void _showIconSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Image.asset('assets/coming-soon.gif'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: 90 * 3.14159265359 / 180,
        child: ClipPath(
          clipper: HexagonalClipper(),
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            elevation: 1,
            onPressed: () {
              debugPrint("Add Button pressed");
              _showIconSelectionSheet(context);
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ));
  }
}

class HexagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = size.width / 2;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Calculate the points for the hexagon
    for (int i = 0; i < 6; i++) {
      final angle = 2.0 * i * 3.14159265359 / 6;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class VerticalHexagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = size.height / 2;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Calculate the points for the vertical hexagon
    for (int i = 0; i < 6; i++) {
      final angle = 2.0 * i * 3.14159265359 / 6;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
