import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:provider/provider.dart';
import 'package:kadu_booking_app/blocs/favorite/favorite_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class CarouselWidget extends StatelessWidget {
  final String id;
  final String imageURL;
  final String title;
  final String subTitle;
  final VoidCallback onTapCallback;

  CarouselWidget({
    Key? key,
    required this.id,
    required this.imageURL,
    required this.title,
    required this.subTitle,
    required this.onTapCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        Consumer<FavoriteModel>(
          builder: (context, favoriteModel, _) {
            return CarouselItem(
              id: id ?? '',
              image: imageURL,
              title: title,
              subtitle: subTitle,
              isFavorite: favoriteModel.isFavorite(id),
              onTapCallback: onTapCallback,
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
  final VoidCallback onTapCallback;
  // var imageUrl = 'https://stays.angels4you.org/storage/public/uploads/room.png';
  CarouselItem({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.isFavorite,
    required this.onTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCallback,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 700,
        width: MediaQuery.of(context).size.width,
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
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(image),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 15.0,
                            color: AppColors.textColorPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    verticalSpaceSmall,
                    GestureDetector(
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 15.0,
                              color: AppColors.textColorPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              subtitle ?? '',
                              style: GoogleFonts.poppins(
                                color: AppColors.textColorPrimary,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
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
