import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/homescreen/hotel_tile.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class BookingsPage extends StatelessWidget {
  final String tab;

  const BookingsPage({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          verticalSpaceLarge,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            width: MediaQuery.of(context).size.height,
            child: Text(
              'Bookings Page',
              style: GoogleFonts.poppins(
                  color: AppColors.primaryColorOrange, fontSize: 30),
            ),
          ),
          BookingList(),
        ],
      )),
    );
  }
}

class BookingList extends StatefulWidget {
  const BookingList({super.key});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: context.height,
        child: Material(
            child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Column(children: [
                    verticalSpaceRegular,
                    HotelTile(
                        imageUrl:
                            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
                        description: 'This is booked hotel'),
                  ]);
                })));
  }
}
