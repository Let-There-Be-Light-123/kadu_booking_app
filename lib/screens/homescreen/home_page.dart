import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:kadu_booking_app/api/file_service.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/editprofile/edit_profile.dart';
import 'package:kadu_booking_app/screens/homescreen/custom_carousel.dart';
import 'package:kadu_booking_app/screens/homescreen/locationsearch.dart';
import 'package:kadu_booking_app/screens/homescreen/search_bar.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/bookingcalendar/booking_calendar.dart';
import 'package:kadu_booking_app/ui_widgets/bookingcalendar/clean_calendar.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:http/http.dart'
    as http; // Add this import for making HTTP requests
import 'dart:convert'; // Add this import for working with JSON data
import 'package:google_maps_webservice/places.dart' as google_places;
import 'package:provider/provider.dart';

var featuredProperties;

class HomePage extends StatefulWidget {
  final String tab;
  const HomePage({super.key, required this.tab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  final fileService = FileService();
  var mostLikedProperties = [];
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFeaturedProperties();
    _mostLikedProperties();
  }

  Future<void> _mostLikedProperties() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/properties/mostliked'),
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final List<dynamic>? propertyList = responseData['data'];
          if (propertyList != null) {
            propertyList.sort((a, b) => b['likes'].compareTo(a['likes']));
            final List mostLikedProperties = propertyList.take(10).toList();
            setState(() {
              this.mostLikedProperties = mostLikedProperties;
            });
          } else {
            print(
                'Invalid response format. "data" field is null or not a List.');
          }
        } else {
          print('Invalid response format. Expected a Map with "data" field.');
        }
      } else if (response.statusCode == 404) {
        print('No properties found');
      } else {
        throw Exception(
            'Failed to load properties. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching properties: $e');
      throw Exception(
          'Failed to load properties. Check your internet connection and try again.');
    }
  }

  Future<void> fetchFeaturedProperties() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/properties/featured'),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final List<dynamic> propertyList = responseData['data'];
          List<Map<String, dynamic>> updatedProperties = [];

          for (final property in propertyList) {
            final files = property['files'];

            List<String> fileUrls = [];

            for (final file in files) {
              final String filename = file['filename'];
              final String filePath =
                  '${dotenv.env['API_URL']}/storage/' + file['filepath'];
              final String fileUrl = '$filePath/$filename';
              fileUrls.add(fileUrl);
            }
            property['fileUrls'] = fileUrls;
            updatedProperties.add(property);
          }

          setState(() {
            featuredProperties =
                List<Map<String, dynamic>>.from(updatedProperties);
          });
        } else {
          // print(
          //     'Invalid response format. Expected a Map with "data" field but received: $responseData');
        }
      } else if (response.statusCode == 404) {
      } else {
        throw Exception(
            'Failed to load featured properties. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Failed to load featured properties. Check your internet connection and try again.');
    }
  }

  Future<void> displayFilesForProperty(String propertyId) async {
    try {
      final List<Map<String, dynamic>> files =
          await fileService.getFilesForProperty(propertyId);

      for (final file in files) {
        final String filename = file['filename'];
        final String filepath = file['file_path'];
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'An error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // You can add logic here to fetch updated data or perform any refresh operation
    await fetchFeaturedProperties();
    await _mostLikedProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
        builder: (context, userDetailsProvider, child) {
      final userLocation = userDetailsProvider.getUserAddress();
      String baseUrl = '${dotenv.env['API_URL']}';

      return RefreshIndicator(
        onRefresh: () async {
          await _handleRefresh();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false, // Add this line
          body: Padding(
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return const SearchPlacesScreen();
                              }));
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
                                          color: const Color.fromARGB(
                                              255, 230, 229, 229))),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.primaryColorOrange,
                                    size: 25,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  height: 40,
                                  width: 250,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Column(children: [
                                    Text(
                                      userLocation ?? "Select Location",
                                      style: GoogleFonts.poppins(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const EditProfile(
                                          myProfile: 'User')));
                            },
                            child: Container(
                              width: 20 * 2,
                              height: 20 * 2,
                              child: ClipOval(
                                child:
                                    userDetailsProvider.userDetails != null &&
                                            userDetailsProvider
                                                    .userDetails?.files !=
                                                null &&
                                            userDetailsProvider.userDetails!
                                                    .files?.isNotEmpty ==
                                                true &&
                                            userDetailsProvider.userDetails!
                                                    .files![0].filename !=
                                                null
                                        ? Image.network(
                                            '${baseUrl}/storage/public/uploads/users/${userDetailsProvider.userDetails!.socialSecurity}/${userDetailsProvider.userDetails!.files![0].filename}',
                                            width: 20 * 2,
                                            height: 20 * 2,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/avatar2.png',
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
                  const SizedBox(),
                  const CustomSearchBar(),
                  verticalSpaceRegular,
                  const BannerHome(),
                  verticalSpaceRegular,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.topLeft,
                    child: Text('Featured Properties',
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: AppColors.textColorPrimary)),
                  ),
                  verticalSpaceRegular,
                  CustomCarousel(propertyData: featuredProperties ?? []),
                  verticalSpaceRegular,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.topLeft,
                    child: Text('Most Liked',
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: AppColors.textColorPrimary)),
                  ),
                  verticalSpaceRegular,
                  // Add checks for null safety
                  CustomCarousel(propertyData: mostLikedProperties ?? []),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
