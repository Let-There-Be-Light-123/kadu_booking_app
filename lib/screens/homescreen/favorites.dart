import 'package:flutter/material.dart';
import 'package:kadu_booking_app/screens/homescreen/hotel_tile.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class FavouritesPage extends StatelessWidget {
  final String tab;

  const FavouritesPage({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Column(children: [
                verticalSpaceRegular,
                HotelTile(
                    imageUrl:
                        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
                    description: 'This is booked hotel'),
              ]);
            }));
  }
}
