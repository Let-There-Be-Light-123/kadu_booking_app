import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  String imageURL;
  String title;
  String subTitle;

  CarouselWidget(
      {super.key,
      required this.imageURL,
      required this.title,
      required this.subTitle});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        CarouselItem(
          image: widget.imageURL,
          title: widget.title,
          subtitle: widget.subTitle,
          isFavorite: isFavorite,
          onFavoriteToggle: () {
            setState(() {
              isFavorite = !isFavorite;
              print(isFavorite);
            });
          },
        ),
        // Add more CarouselItem widgets as needed
      ],
    );
  }
}

class CarouselItem extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  CarouselItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                children: [
                  Image.network(
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
