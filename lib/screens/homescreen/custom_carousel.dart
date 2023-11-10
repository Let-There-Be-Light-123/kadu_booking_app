import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kadu_booking_app/screens/homescreen/hotel_carousel_item.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({super.key});

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: NoonLoopingDemo(),
    );
  }
}

final List<Map<String, String>> imageData = [
  {
    'imageUrl':
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'description': 'HOTEL 1',
    'id': '1'
  },
  {
    'imageUrl':
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'description': 'HOTEL 2',
    'id': '2'
  },
  {
    'imageUrl':
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'description': 'HOTEL 3',
    'id': '3'
  },
  {
    'imageUrl':
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'description': 'HOTEL 4',
    'id': '4'
  },
];

class NoonLoopingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        initialPage: 1,
      ),
      items: imageData.map((data) {
        return CarouselWidget(
          imageURL: data['imageUrl']!,
          title: data['description']!,
          subTitle: 'This is hotel',
          // id: '',
        );
      }).toList(),
    ));
  }
}
