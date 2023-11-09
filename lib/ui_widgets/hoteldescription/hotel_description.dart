import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class HotelDescription extends StatelessWidget {
  const HotelDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Image.asset('assets/hotel_1.png'),
        verticalSpaceRegular,
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presidential Hotel',
                  style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 30,
                      decorationThickness: 0),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 24, color: AppColors.primaryColorOrange),
                    Text(
                      '12 Eze Adedle Road ',
                      style: GoogleFonts.poppins(
                          color: AppColors.textColorPrimary,
                          fontSize: 20,
                          decorationThickness: 0.0),
                    ),
                  ],
                ),
                verticalSpaceRegular,
                Divider(
                  indent: 5,
                  endIndent: 5,
                  thickness: 2.0,
                  color: Colors.grey,
                ),
                verticalSpaceRegular,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gallery Photos',
                      style: GoogleFonts.poppins(
                          color: AppColors.textColorPrimary,
                          fontSize: 20,
                          decorationThickness: 0),
                    ),
                    verticalSpaceRegular,
                    verticalSpaceRegular,
                    TextButton(
                        onPressed: () {
                          print("See all");
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: AppColors.primaryColorOrange),
                        ))
                  ],
                ),
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    items: carouselItems,
                    options: CarouselOptions(
                      height: 80,
                      scrollDirection: Axis.horizontal,
                      viewportFraction: .3,
                      enableInfiniteScroll: false,
                      initialPage: 1,
                    ),
                  ),
                ),
                verticalSpaceRegular,
                Text(
                  'Details',
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20,
                      decorationThickness: 0),
                ),
                verticalSpaceLarge,
                Text(
                  'Description',
                  style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 20,
                      decorationThickness: 0),
                ),
                Divider(
                  indent: 5,
                  endIndent: 5,
                  thickness: 2.0,
                  color: Colors.grey,
                ),
                verticalSpaceSmall,
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt aliqua.',
                  style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 15,
                      decorationThickness: 0),
                ),
                verticalSpaceRegular,
                Text(
                  'Facilitites',
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20,
                      decorationThickness: 0),
                ),
                verticalSpaceRegular,
                Text(
                  'Location',
                  style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 20,
                      decorationThickness: 0),
                ),
                verticalSpaceRegular,
                Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(37.422131, -122.084801)),
                    )),
                verticalSpaceMedium,
                Text(
                  'Reviews',
                  style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 20,
                      decorationThickness: 0),
                ),
                verticalSpaceMassive

                // CarouselSlider(items: items, options: options)
              ],
            ))
      ],
    ));
  }
}

List<Widget> carouselItems = [
  Image.asset('assets/hotel_2.png'),
  Image.asset('assets/hotel_2.png'),
  Image.asset('assets/hotel_3.png'),
  Image.asset('assets/hotel_4.png'),
  Image.asset('assets/hotel_3.png'),
];
