import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/hoteldescription/hotel_description.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

final List<Map<String, String>> imageData = [
  {'imageUrl': 'assets/hotel_2.png', 'imageDesc': ''},
  {'imageUrl': 'assets/hotel_3.png', 'imageDesc': ''},
  {'imageUrl': 'assets/hotel_4.png', 'imageDesc': ''},
  {'imageUrl': 'assets/hotel_1.png', 'imageDesc': ''}
];

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          color: AppColors.backgroundColorDefault,
        ),
        HotelDescription(),
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 25,
            color: AppColors.primaryColorOrange,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              child: Container(
                color: Colors.transparent,
                height: 50,
                width: 200,
                child: MaterialButton(
                  onPressed: () {},
                  child: Text('Book now'),
                  textColor: Colors.white,
                  color: AppColors.primaryColorOrange,
                ),
              ),
            ))
      ],
    );
  }
}

class DetailPageWrapper extends StatelessWidget {
  const DetailPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 25,
          color: AppColors.primaryColorOrange,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Container(
          color: AppColors.backgroundColorDefault,
          alignment: Alignment.bottomCenter,
          child: MaterialButton(
            onPressed: () {},
            minWidth: 300,
            child: Text('Book now'),
            textColor: Colors.white,
            color: AppColors.primaryColorOrange,
          ),
        )
      ],
    );
  }
}

// Navigator.pop(context);

    // Material(
    //     child: Column(
    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
    //   children: [
    //     Container(
    //       // height: MediaQuery.of(context).size.height,
    //       color: AppColors.backgroundColorDefault,
    //       child: Column(
    //           mainAxisAlignment: MainAxisAlignment.spaceAround,
    //           children: [
    //             Stack(
    //               children: <Widget>[
    //                 HotelDescription(),
    //                 Material(
    //                   color: Colors.transparent,
    //                   child: IconButton(
    //                     icon: Icon(Icons.arrow_back),
    //                     iconSize: 25,
    //                     color: AppColors.primaryColorOrange,
    //                     onPressed: () {
    //                       Navigator.pop(context);
    //                     },
    //                   ),
    //                 )
    //               ],
    //             ),
    //             Container(
    //               color: AppColors.backgroundColorDefault,
    //               alignment: Alignment.bottomCenter,
    //               child: MaterialButton(
    //                 onPressed: () {},
    //                 minWidth: 300,
    //                 child: Text('Book now'),
    //                 textColor: Colors.white,
    //                 color: AppColors.primaryColorOrange,
    //               ),
    //             )
    //           ]),
    //     ),
    //   ],
    // ));