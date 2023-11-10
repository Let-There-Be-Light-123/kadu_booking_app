import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:provider/provider.dart';
import 'package:kadu_booking_app/blocs/favorite/favorite_bloc.dart';

class CarouselWidget extends StatelessWidget {
  final String id;
  final String imageURL;
  final String title;
  final String subTitle;

  CarouselWidget({
    Key? key,
    required this.id,
    required this.imageURL,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        Consumer<FavoriteModel>(
          builder: (context, favoriteModel, _) {
            return CarouselItem(
              id: id,
              image: imageURL,
              title: title,
              subtitle: subTitle,
              isFavorite: favoriteModel.isFavorite(id),
            );
          },
        ),
        // Add more CarouselItem widgets as needed
      ],
    );
  }
}

class CarouselItem extends StatelessWidget {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final bool isFavorite;

  CarouselItem({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 700,
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
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '', // Add null check for title
                      style: GoogleFonts.poppins(
                        fontSize: 15.0,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 15.0, // Adjust the size as needed
                              color: AppColors
                                  .textColorPrimary, // Adjust the color as needed
                            ),
                          ),
                          Text(
                            '123 Palm Road',
                            style: GoogleFonts.poppins(
                              fontSize: 10.0, // Adjust the size as needed
                              color: Colors.grey, // Adjust the color as needed
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
