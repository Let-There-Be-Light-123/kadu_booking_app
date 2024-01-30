import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/bookingcalendar/clean_calendar.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingCalendar extends StatefulWidget {
  final Function(bool, List<Room>, DateTime, DateTime) onAvailabilityChanged;
  final String propertyId;
  final VoidCallback onBookNowPressed;

  const BookingCalendar(
      {Key? key,
      required this.onAvailabilityChanged,
      required this.propertyId,
      required this.onBookNowPressed})
      : super(key: key);

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  bool _isAvailable = false;

  Future<void> _checkAvailability() async {
    final apiUrl = '${dotenv.env['API_URL']}/api/available-rooms';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'property_id': widget.propertyId,
          'check_in_date': _checkInDate?.toIso8601String(),
          'check_out_date': _checkOutDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        var availableRooms = jsonData['available_rooms'];
        List<Room> rooms = Room.listFromJson(availableRooms);
        if (rooms.length != 0) {
          setState(() {
            _isAvailable = true;
            widget.onAvailabilityChanged(
              _isAvailable,
              rooms,
              _checkInDate!,
              _checkOutDate!,
            );
          });
          _showPopup('Property is available for booking!');
        } else {
          _showPopup('Unavailable for booking. Please check another property.');
        }
      } else {
        print(
            'Failed to check availability. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while checking availability: $error');
    }
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Availability Check'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          verticalSpaceRegular,
          Calendar(
            onDateValueChanged: (List<DateTime?> dates) {
              // Set the _checkInDate and _checkoutDate
              setState(() {
                _checkInDate = dates.isNotEmpty ? dates[0] : null;
                _checkOutDate = dates.length > 1 ? dates[1] : null;
              });
            },
          ),
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _checkAvailability,
                child: Text('Check Availability'),
              ),
              const SizedBox(width: 16), // Adjust the spacing as needed
              ElevatedButton(
                onPressed: widget.onBookNowPressed,
                style: ElevatedButton.styleFrom(
                  primary: AppColors
                      .primaryColorOrange, // Set the background color to orange
                  onPrimary: Colors.white, // Set the text color to white
                ),
                child: Text('Book Now'),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
