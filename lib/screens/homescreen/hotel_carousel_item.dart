import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';

class ImageWithDescription extends StatefulWidget {
  final String imageUrl;
  final String description;

  ImageWithDescription({required this.imageUrl, required this.description});

  @override
  _ImageWithDescriptionState createState() => _ImageWithDescriptionState();
}

class _ImageWithDescriptionState extends State<ImageWithDescription> {
  bool isLiked = false;
  int likes = 0;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likes++;
      } else {
        likes--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          // Image
          Image.network(
            widget.imageUrl,
            fit: BoxFit.fill,
            height: 100,
            width: MediaQuery.of(context).size.width - 20,
          ),
          // Like button at the bottom-right corner
          Positioned(
            right: 8.0,
            bottom: 8.0,
            child: IconButton(
              icon: isLiked
                  ? Icon(Icons.favorite, color: Colors.red)
                  : Icon(Icons.favorite_border),
              onPressed: toggleLike,
            ),
          ),
          Column(
            children: [
              SizedBox(
                  height:
                      150), // Spacer to ensure the button appears at the bottom
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: AppColors.textColorPrimary,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Description extends StatelessWidget {
  const Description({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
