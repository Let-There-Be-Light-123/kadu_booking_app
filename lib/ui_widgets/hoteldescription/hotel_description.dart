// ignore_for_file: deprecated_member_use, use_key_in_widget_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
import 'package:rate_in_stars/rate_in_stars.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:http/http.dart' as http;

class HotelDescription extends StatefulWidget {
  final Function(bool) onAvailabilityChanged;
  final Property propertyData;
  final UserDetailsProvider? userDetailsProvider;

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
  int offset = 0;
  List<Review> reviews = [];

  bool isReviewCollapsed = false;
  late List<Review> allReviews;
  int reviewsToShow = 5;

  late UserDetailsProvider userDetailsProvider;

  final Completer<GoogleMapController> _controller = Completer();

  void _handleAvailabilityChange(bool isAvailable, List<Room> rooms,
      DateTime checkInDate, DateTime checkOutDate) {
    setState(() {
      checkInDate = checkInDate;
      checkOutDate = checkOutDate;
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
    // printImageURL();
    setCarouselImages();
    fetchReviews();
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
            width: MediaQuery.of(context).size.width,
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

  fetchReviews() async {
    debugPrint('Review funtion');

    final url = Uri.parse('${dotenv.env['API_URL']}/api/properties/reviews');
    final body = json.encode(
        {'property_id': widget.propertyData.propertyId, 'offset': offset});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> reviewData = jsonData['data'];
      final List<Review> tempReviews = reviewData.map((reviewJson) {
        List<String> photoPaths = extractPhotoPaths(reviewJson);
        return Review(
          id: reviewJson['id'],
          rating: reviewJson['rating'].toDouble(), // Convert int to double
          comment: reviewJson['comment'],
          userId: reviewJson['user']['id'],
          userName: reviewJson['user']['name'],
          photos: photoPaths,
          createdAt: DateTime.parse(reviewJson['created_at']),
        );
      }).toList();
      setState(() {
        reviews.addAll(tempReviews);
      });
      final nextOffset = jsonData['next_offset'];
      offset = nextOffset;
      debugPrint('Reviews count: ${reviews.length}');

      for (var review in reviews) {
        debugPrint('Review ID: ${review.id}');
        debugPrint('Rating: ${review.rating}');
        debugPrint('Comment: ${review.comment}');
        debugPrint('User ID: ${review.userId}');
        debugPrint('User Name: ${review.userName}');
        debugPrint('Photos:');
        if (review.photos != null) {
          for (var photoPath in review.photos!) {
            debugPrint('- $photoPath');
          }
        }
        debugPrint('Created At: ${review.createdAt}');
        debugPrint('-------------------------------------');
      }
      debugPrint('Next Offset $nextOffset');
    } else {
      throw Exception('Failed to load property reviews');
    }
  }

  List<String> extractPhotoPaths(Map<String, dynamic> reviewJson) {
    List<dynamic> files = reviewJson['files'];
    List<String> photoPaths = [];

    for (var file in files) {
      String filePath = file['filepath'];
      String fileName = file['filename'];
      String completeFilePath =
          '${dotenv.env['API_URL']}/storage/$filePath/$fileName';
      photoPaths.add(completeFilePath);
    }

    return photoPaths;
  }

  void loadMoreReviews() async {
    debugPrint('Offset is  $offset');
    await fetchReviews();
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
                        itemCount: isReviewCollapsed
                            ? 5
                            : min(reviewsToShow, reviews.length),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return ExpansionTile(
                            title: Text(
                              '${review.userName}: ${review.comment}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    verticalSpaceSmall,
                                    Row(
                                      children: [
                                        const Text(
                                          'Rating: ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        RatingStars(
                                          rating: review.rating ?? 0.0,
                                          color: Colors.amber,
                                          iconSize: 32,
                                          editable: false,
                                        ),
                                      ],
                                    ),
                                    verticalSpaceSmall,
                                    Text(
                                      review.comment ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                      softWrap: true,
                                    ),
                                    verticalSpaceRegular,
                                    if (review.photos!.isNotEmpty)
                                      Container(
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: review.photos?.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                // Navigate to fullscreen image view
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        FullScreenImageView(
                                                      imageUrls:
                                                          review.photos ?? [],
                                                      initialIndex: index,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.network(
                                                    review.photos![index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    verticalSpaceRegular,
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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

class ZoomableImageGallery extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ZoomableImageGallery(
      {required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageView({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Full Screen Image View'),
          ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
