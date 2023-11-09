import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/favorite.dart/favorite.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class HotelTile extends StatelessWidget {
  final String imageUrl;
  final String description;

  HotelTile({required this.imageUrl, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width - 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.white),
        padding: EdgeInsets.all(5),
        height: 100,
        child: Row(
          children: [
            Container(
              width: 100, // You can adjust the image width as needed
              height: 100, // You can adjust the image height as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 20,
                            width: 20,
                            child: Image.asset('assets/bundlow.png'),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: StackedIconsButton(),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Luxurious Haven villa',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          Container(
                            height: 22,
                            width: 22,
                            child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                  size: 10,
                                )),
                          ),
                          Text(
                            'BHuj-Kutch',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.textColorPrimary,
                            ),
                          )
                        ],
                      ),
                    ),
                  ]),
            )),
          ],
        ));
  }
}
