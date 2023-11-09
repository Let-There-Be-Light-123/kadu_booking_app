import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/editprofile/edit_profile.dart';
import 'package:kadu_booking_app/screens/homescreen/custom_carousel.dart';
import 'package:kadu_booking_app/screens/homescreen/hotel_carousel_item.dart';
import 'package:kadu_booking_app/screens/homescreen/search_bar.dart';
import 'package:kadu_booking_app/screens/homescreen/searchpage.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class HomePage extends StatefulWidget {
  final String tab;
  const HomePage({super.key, required this.tab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 30, left: 15, right: 15),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              verticalSpaceMedium,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                        onTap: () {
                          print('open location search');
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 230, 229, 229))),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primaryColorOrange,
                                size: 25,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(children: [
                                Text(
                                  'Location',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  'California USA',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                )
                              ]),
                            ),
                          ],
                        )),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditProfile(myProfile: ' User')),
                          );
                        },
                        child: Container(
                          width: 20 * 2,
                          height: 20 * 2,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/hotel_1.png',
                              width: 20 * 2,
                              height: 20 * 2,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )),
                ],
              ),

              verticalSpaceRegular,

              SizedBox(),
              CustomSearchBar(),
              verticalSpaceRegular,
              BannerHome(),
              verticalSpaceRegular,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.topLeft,
                child: Text('Featured Properties',
                    style: GoogleFonts.poppins(
                        fontSize: 20, color: AppColors.textColorPrimary)),
              ),
              verticalSpaceRegular,
              // CustomCarousel(),

              // ImageWithDescription(),
            ],
          ),
        ),
      ),
    );
  }
}

class BannerHome extends StatefulWidget {
  const BannerHome({super.key});

  @override
  State<BannerHome> createState() => _BannerState();
}

class _BannerState extends State<BannerHome> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      child: Image.asset('assets/banner_image.png'),
    );
  }
}

class CarouselCustom extends StatefulWidget {
  const CarouselCustom({super.key});

  @override
  State<CarouselCustom> createState() => _CarouselCustomState();
}

class _CarouselCustomState extends State<CarouselCustom> {
  final List<String> imgList = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Carousel'),
    );
  }
}
