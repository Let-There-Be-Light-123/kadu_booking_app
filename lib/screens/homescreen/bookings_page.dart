import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/booking_status.dart/booking_status.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui_widgets/customcard/custom_card.dart';

class TokenResponse {
  final String? token;

  TokenResponse({this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'],
    );
  }
}

class BookingsPage extends StatefulWidget {
  final String tab;

  const BookingsPage({Key? key, required this.tab});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> bookedBookings = [];
  List<Map<String, dynamic>> checkedInBookings = [];
  List<Map<String, dynamic>> checkedOutBookings = [];
  List<Map<String, dynamic>> pendingVerificationBookings = [];
  List<Map<String, dynamic>> upcomingBookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    var apiUrl = '${dotenv.env['API_URL']}/api/user/bookings';
    var _getToken = await getToken();
    var token = _getToken.token;
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiBookings = data['bookings'];
        setState(() {
          bookings = List<Map<String, dynamic>>.from(apiBookings);
        });
      } else {
        if (kDebugMode) {
          print('Error fetching bookings. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching bookings: $error');
      }
    }
  }

  Future<TokenResponse> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String tokenString = prefs.getString('token') ?? '';
    final Map<String, dynamic> tokenMap = json.decode(tokenString);
    final TokenResponse tokenResponse = TokenResponse.fromJson(tokenMap);
    return tokenResponse;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            verticalSpaceLarge,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text(
                    'Bookings Page',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryColorOrange,
                      fontSize: 30,
                    ),
                  ),
                  verticalSpaceRegular,
                  DefaultTabController(
                    length: 3,
                    initialIndex: 1,
                    child: Column(
                      children: [
                        TabBar(
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.primaryColorOrange,
                          indicator: BoxDecoration(
                              color: AppColors.primaryColorOrange,
                              borderRadius: BorderRadius.circular(10.0)),
                          indicatorPadding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: -8.0),
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(
                              child: Text(
                                'Previous',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Pending',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Confirmed',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 700,
                          child: TabBarView(
                            children: [
                              BookingList(
                                  type: 'previous',
                                  bookings: bookings,
                                  onTabChange: fetchBookings),
                              BookingList(
                                  type: 'pending',
                                  bookings: bookings,
                                  onTabChange: fetchBookings),
                              BookingList(
                                  type: 'confirmed',
                                  bookings: bookings,
                                  onTabChange: fetchBookings),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingList extends StatefulWidget {
  final String type;
  final List<Map<String, dynamic>> bookings;
  final Function onTabChange;

  const BookingList({
    Key? key,
    required this.type,
    required this.bookings,
    required this.onTabChange,
  }) : super(key: key);

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  List<Map<String, dynamic>> _filterBookings(
    List<Map<String, dynamic>> bookings,
    String type,
  ) {
    final DateTime currentDate = DateTime.now();
    switch (type) {
      case 'previous':
        final confirmedBookings = bookings
            .where((booking) =>
                DateTime.parse(booking['check_out_date']).isBefore(currentDate))
            .toList();
        return confirmedBookings;

      case 'confirmed':
        final upcomingBookings = bookings
            .where((booking) =>
                booking['status'] == 'booked' &&
                DateTime.parse(booking['check_in_date']).isAfter(currentDate))
            .toList();

        return upcomingBookings;
      case 'pending':
        final pending = bookings
            .where((booking) =>
                booking['status'] == 'pending verification' &&
                DateTime.parse(booking['check_in_date']).isAfter(currentDate))
            .toList();
        return pending;

      default:
        return bookings;
    }
  }

  Future<void> _handleRefresh() async {
    await widget.onTabChange();
  }

  @override
  void initState() {
    super.initState();
    widget.onTabChange();
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = '${dotenv.env['API_URL']}';

    final List<Map<String, dynamic>> filteredBookings =
        _filterBookings(widget.bookings, widget.type);

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SizedBox(
        height: context.height,
        child: Material(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of cards in each row
              crossAxisSpacing: 8.0, // Spacing between cards horizontally
              mainAxisSpacing: 8.0, // Spacing between cards vertically
            ),
            itemCount: filteredBookings.length, // Use filteredBookings.length
            itemBuilder: (context, index) {
              final Map<String, dynamic> bookingData = filteredBookings[index];
              if (kDebugMode) {
                print(
                    '$baseUrl/storage/public/uploads/properties/${bookingData['room_details'][0]['property_details']['files'][0]['filename']}');
              }
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingStatus(
                          bookingData: bookingData,
                          imageUrl:
                              '$baseUrl/storage/public/uploads/properties/${bookingData['room_details'][0]['property_details']['property_id']}/${bookingData['room_details'][0]['property_details']['files'][0]['filename']}'),
                    ),
                  );
                },
                child: CustomCard(
                  imageUrl:
                      '$baseUrl/storage/public/uploads/properties/${bookingData['room_details'][0]['property_details']['property_id']}/${bookingData['room_details'][0]['property_details']['files'][0]['filename']}',
                  title: bookingData['room_details'][0]['property_details']
                      ['property_name'],
                  subtitle: bookingData['room_details'][0]['property_details']
                      ['address'],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
