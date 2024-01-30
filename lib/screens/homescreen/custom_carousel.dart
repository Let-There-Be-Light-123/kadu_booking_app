import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kadu_booking_app/blocs/favorite/favorite_bloc.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/homescreen/hotel_carousel_item.dart';
import 'package:kadu_booking_app/screens/propertydetails/property_detail_page.dart';
import 'package:provider/provider.dart';

class CustomCarousel extends StatefulWidget {
  final propertyData;

  const CustomCarousel({Key? key, required this.propertyData})
      : super(key: key);
  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  String baseUrl = '${dotenv.env['API_URL']}';

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> carouselData = [];
    if (widget.propertyData != null &&
        widget.propertyData is List &&
        widget.propertyData.length > 0) {
      for (var property in widget.propertyData) {
        Map<String, String> carouselItem = {
          'property_id': property['property_id'] ?? '',
          'title': property['property_name'] ?? '',
          'description': property['property_description'] ?? '',
          'imageURL': (property['files'] != null &&
                  property['files']!.isNotEmpty)
              ? '$baseUrl/storage/public/uploads/properties/${property['property_id']}/${property['files']![0]['filename']}'
              : '$baseUrl/storage/public/uploads/default/not_found.png',
          'address': property['address'] ?? '',
        };
        carouselData.add(carouselItem);
      }
      // print("Setting data for carousel");
    }

    return Container(
      alignment: Alignment.centerLeft,
      child: NoonLoopingDemo(imageData: carouselData),
    );
  }
}

class NoonLoopingDemo extends StatelessWidget {
  final List<Map<String, String>> imageData;

  NoonLoopingDemo({required this.imageData});

  @override
  Widget build(BuildContext context) {
    String baseUrl = '${dotenv.env['API_URL']}';
    return ChangeNotifierProvider(
      create: (context) => FavoriteModel(),
      child: Container(
        alignment: Alignment.centerLeft,
        child: CarouselSlider(
          options: CarouselOptions(
            padEnds: false,
            enableInfiniteScroll: false,
            initialPage: 0,
          ),
          items: imageData.map((data) {
            String? filePath = data['imageURL'];
            print('$baseUrl$filePath');
            return CarouselWidget(
              imageURL: data['imageURL'] ?? '',
              title: data['title'] ?? '',
              subTitle: data['address'] ?? '',
              id: data['property_id'] ?? '',
              onTapCallback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetailPage(
                        userDetailsProvider: Provider.of<UserDetailsProvider>(
                            context,
                            listen: false),
                        propertyId: data['property_id'] ?? ''),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
