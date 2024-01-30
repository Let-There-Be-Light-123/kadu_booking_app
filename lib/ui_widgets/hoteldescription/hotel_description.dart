// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:kadu_booking_app/models/review_model.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/booknow/book_screen.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/bookingcalendar/booking_calendar.dart';
import 'package:kadu_booking_app/ui_widgets/hoteldescription/image_carousel.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDescription extends StatefulWidget {
  final Function(bool) onAvailabilityChanged;
  final Property propertyData;
  final UserDetailsProvider? userDetailsProvider; // Make it optional

  HotelDescription({
    Key? key,
    required this.onAvailabilityChanged,
    required this.propertyData,
    this.userDetailsProvider,
  }) : super(key: key);

  @override
  State<HotelDescription> createState() => _HotelDescriptionState();
}

class _HotelDescriptionState extends State<HotelDescription> {
  String baseUrl = '${dotenv.env['API_URL']}';
  bool _isAvailable = false;
  late DateTime checkInDate;
  late DateTime checkOutDate;
  List<Room>? availableRooms;
  late List<Widget> carouselItems;
  bool isPropertyFavorite = false;

  bool isReviewCollapsed = false;
  late List<Review> allReviews;
  int reviewsToShow = 5;
  List<Review> sampleReviews = [
    Review(
      id: '1',
      userId: 'user1',
      propertyId: 'property1',
      rating: 4,
      comment: 'Great experience! Highly recommended.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: '2',
      userId: 'user2',
      propertyId: 'property1',
      rating: 5,
      comment: 'Fantastic service and amenities.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Review(
      id: '3',
      userId: 'user3',
      propertyId: 'property2',
      rating: 3,
      comment: 'Good place, but could be better.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Review(
      id: '4',
      userId: 'user4',
      propertyId: 'property3',
      rating: 2,
      comment: 'Disappointing experience. Needs improvement.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Review(
      id: '5',
      userId: 'user5',
      propertyId: 'property4',
      rating: 4,
      comment: 'Enjoyed my stay. Clean and comfortable.',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Review(
      id: '6',
      userId: 'user6',
      propertyId: 'property3',
      rating: 3,
      comment: 'Average place. Not bad, not great.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Review(
      id: '7',
      userId: 'user7',
      propertyId: 'property2',
      rating: 5,
      comment: 'Absolutely amazing! Will come back again.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Review(
      id: '8',
      userId: 'user8',
      propertyId: 'property5',
      rating: 4,
      comment: 'Friendly staff and beautiful surroundings.',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Review(
      id: '9',
      userId: 'user9',
      propertyId: 'property4',
      rating: 1,
      comment: 'Terrible experience. Avoid at all costs.',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    Review(
      id: '10',
      userId: 'user10',
      propertyId: 'property5',
      rating: 5,
      comment: 'Paradise on Earth! Exceeded my expectations.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    )
  ];

  late UserDetailsProvider userDetailsProvider;

  final Completer<GoogleMapController> _controller = Completer();

  void _handleAvailabilityChange(bool isAvailable, List<Room> rooms,
      DateTime _checkInDate, DateTime _checkOutDate) {
    setState(() {
      checkInDate = _checkInDate;
      checkOutDate = _checkOutDate;
      _isAvailable = isAvailable;
      availableRooms = rooms;
    });
    widget.onAvailabilityChanged(_isAvailable);
  }

  void _launchGoogleMaps(LatLng center) async {
    final latitude = widget.propertyData.lat ?? 0.0;
    final longitude = widget.propertyData.lng ?? 0.0;

    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint('Could not launch Google Maps.');
    }
  }

  void _navigateToBookingScreen() {
    if (_isAvailable && availableRooms != null && availableRooms!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            propertyId: availableRooms?[0].propertyId ?? '',
            roomId: availableRooms?[0].roomId ?? '',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available rooms.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userDetailsProvider = widget.userDetailsProvider ?? UserDetailsProvider();
    checkFavoriteStatus();
    printImageURL();
    setCarouselImages();
    fetchReviews(); // Fetch the initial set of reviews
  }

  void printImageURL() {
    if (widget.propertyData != null &&
        widget.propertyData.files != null &&
        widget.propertyData.files.isNotEmpty) {
    } else {}
  }

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  LatLng getPropertyLocation() {
    var latitude = widget.propertyData.lat ?? 0.0;
    var longitude = widget.propertyData.lng ?? 0.0;
    return LatLng(latitude, longitude);
  }

  setCarouselImages() {
    if (widget.propertyData != null &&
        widget.propertyData.propertyId != null &&
        widget.propertyData.files != null &&
        widget.propertyData.files.isNotEmpty) {
      carouselItems = widget.propertyData.files.map((file) {
        return FadeInImage.memoryNetwork(
          fit: BoxFit.cover,
          placeholder: kTransparentImage,
          image:
              '$baseUrl/storage/public/uploads/properties/${widget.propertyData.propertyId}/${file.filename}',
          imageErrorBuilder: (context, error, stacktrace) {
            return const Center(child: Text('Image Not Available'));
          },
        );
      }).toList();
    } else {
      carouselItems = [
        FadeInImage.memoryNetwork(
          fit: BoxFit.cover,
          placeholder: kTransparentImage,
          image: 'default_image_url',
          imageErrorBuilder: (context, error, stacktrace) {
            return const Center(child: Text('Image Not Available'));
          },
        ),
      ];
    }
  }

  void openImage(Widget imageWidget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context)
                .size
                .width, // Set the width to screen width
            child: imageWidget,
          ),
        );
      },
    );
  }

  void _navigateToImageCarousel(List<Widget> carouselItems) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCarouselPage(carouselItems: carouselItems),
      ),
    );
  }

  void toggleFavorite() async {
    final String propertyId = widget.propertyData.propertyId ?? '';
    try {
      userDetailsProvider.toggleFavoriteProperty(propertyId);
      setState(() {
        isPropertyFavorite =
            userDetailsProvider.isPropertyInFavorites(propertyId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPropertyFavorite
                ? 'Property added to favorites!'
                : 'Property removed from favorites!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      debugPrint('Error toggling favorite: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error toggling favorite'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void fetchReviews() {
    setState(() {
      sampleReviews = List.generate(
          20,
          (index) => Review(
                id: index.toString(),
              ));
    });
  }

  void loadMoreReviews() {
    setState(() {
      reviewsToShow += 5;
    });
  }

  void checkFavoriteStatus() {
    final String propertyId = widget.propertyData.propertyId ?? '';

    if (userDetailsProvider.userDetails != null) {
      setState(() {
        isPropertyFavorite =
            userDetailsProvider.isPropertyInFavorites(propertyId);
      });
    } else {
      // User details not available yet, wait for userDetailsProvider to be updated
      userDetailsProvider.addListener(() {
        setState(() {
          isPropertyFavorite =
              userDetailsProvider.isPropertyInFavorites(propertyId);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          verticalSpaceLarge,
          Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FadeInImage.memoryNetwork(
                fit: BoxFit.cover,
                placeholder: kTransparentImage,
                image:
                    '$baseUrl/storage/public/uploads/properties/${widget.propertyData.propertyId}/${widget.propertyData.files[0].filename}',
                imageErrorBuilder: (context, error, stacktrace) {
                  return FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image:
                        '$baseUrl/storage/public/uploads/properties/${widget.propertyData.propertyId}/${widget.propertyData.files[0].filename}',
                    imageErrorBuilder: (context, error, stacktrace) {
                      return FadeInImage.memoryNetwork(
                        fit: BoxFit.cover,
                        placeholder: kTransparentImage,
                        image:
                            '$baseUrl/storage/public/uploads/properties/${widget.propertyData.propertyId}/${widget.propertyData.files[0].filename}',
                        imageErrorBuilder: (context, error, stacktrace) {
                          return const Center(
                              child: Text('Image Not Available'));
                        },
                      );
                    },
                  );
                }),
          ),
          verticalSpaceRegular,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.propertyData.propertyName ??
                                'Default Property Name',
                            style: GoogleFonts.poppins(
                              color: AppColors.textColorPrimary,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: IconButton(
                          icon: Icon(
                            isPropertyFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            toggleFavorite();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 24,
                        color: AppColors.primaryColorOrange,
                      ),
                      Expanded(
                        child: Text(
                          widget.propertyData.address ?? '',
                          style: GoogleFonts.poppins(
                            color: AppColors.textColorPrimary,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpaceRegular,
                const Divider(
                  indent: 5,
                  endIndent: 5,
                  thickness: 2.0,
                  color: Colors.grey,
                ),
                verticalSpaceRegular,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gallery Photos',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColorPrimary,
                          fontSize: 20,
                        ),
                      ),
                      verticalSpaceRegular,
                      verticalSpaceRegular,
                      TextButton(
                        onPressed: () {
                          _navigateToImageCarousel(carouselItems);
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: AppColors.primaryColorOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    items: carouselItems.map((item) {
                      return GestureDetector(
                        onTap: () {
                          openImage(item);
                        },
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: item,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      padEnds: false,
                      height: 100,
                      scrollDirection: Axis.horizontal,
                      viewportFraction: .3,
                      enableInfiniteScroll: false,
                      initialPage: 1,
                    ),
                  ),
                ),
                verticalSpaceRegular,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 20,
                    ),
                  ),
                ),
                const Divider(
                  indent: 5,
                  endIndent: 5,
                  thickness: 2.0,
                  color: Colors.grey,
                ),
                verticalSpaceSmall,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.propertyData.propertyDescription ?? '',
                    style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
                verticalSpaceRegular,
                const Divider(
                  indent: 5,
                  endIndent: 5,
                  thickness: 2.0,
                  color: Colors.grey,
                ),
                verticalSpaceRegular,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Check Availability',
                    style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 20,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BookingCalendar(
                        onAvailabilityChanged: _handleAvailabilityChange,
                        onBookNowPressed: _navigateToBookingScreen,
                        propertyId: widget.propertyData.propertyId ?? ''),
                  ),
                ),
                verticalSpaceRegular,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Location',
                    style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 20,
                    ),
                  ),
                ),
                verticalSpaceRegular,
                GestureDetector(
                  onTap: () {
                    _launchGoogleMaps(getPropertyLocation());
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      onTap: (_) => _launchGoogleMaps(_),
                      mapToolbarEnabled: false,
                      mapType: MapType.normal,
                      zoomGesturesEnabled: false,
                      zoomControlsEnabled: false,
                      // Add this line to enable zoom controls
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: getPropertyLocation(),
                        zoom: 11.0,
                      ),
                      markers: <Marker>{
                        Marker(
                          markerId: const MarkerId('property_location'),
                          position: getPropertyLocation(),
                          infoWindow: InfoWindow(
                            title:
                                widget.propertyData.propertyName ?? 'Property',
                            snippet: widget.propertyData.address ?? '',
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                verticalSpaceRegular,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reviews',
                    style: GoogleFonts.poppins(
                      color: AppColors.textColorPrimary,
                      fontSize: 20,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: isReviewCollapsed ? 5 : reviewsToShow,
                        itemBuilder: (context, index) {
                          final review = sampleReviews[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User: ${review.userId}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review.comment ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Add a collapse button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isReviewCollapsed = !isReviewCollapsed;
                          });
                        },
                        child: Text(
                          isReviewCollapsed
                              ? 'Expand Reviews'
                              : 'Collapse Reviews',
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: loadMoreReviews,
                  child: const Text('Load More'),
                ),
                verticalSpaceMedium,
                verticalSpaceMassive
              ],
            ),
          ),
        ],
      ),
    );
  }
}
