import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarouselPage extends StatelessWidget {
  final List<Widget> carouselItems;
  final CarouselController _controller = CarouselController();

  ImageCarouselPage({required this.carouselItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            color: Colors.black.withOpacity(0.1),
            child: CarouselSlider(
              items: carouselItems,
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                initialPage: 0,
                autoPlay: false,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
              ),
              carouselController: _controller,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50.0,
                    color: Colors.black.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            _controller.previousPage();
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            _controller.nextPage();
                          },
                          icon: Icon(Icons.arrow_forward, color: Colors.white),
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
    );
  }
}
