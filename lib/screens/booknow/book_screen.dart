import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/editprofile/edit_profile.dart';
import 'package:kadu_booking_app/screens/homescreen/main_screen.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

class BookingScreen extends StatefulWidget {
  String propertyId;
  String roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  BookingScreen({
    super.key,
    required this.propertyId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int numberOfGuests = 1;
  var exportedImage;
  late UserDetailsProvider userDetailsProvider;
  late UserDetails userDetails;

  final GlobalKey<FormState> _bookingFormKey = GlobalKey<FormState>();
  final GlobalKey<SignatureState> _signaturePadKey = GlobalKey();

  ByteData _img = ByteData(0);

  List<Guest> guests = List.generate(1, (index) => Guest());

  SignatureController signControl = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.blue,
      exportBackgroundColor: Colors.transparent);

  Future<TokenResponse> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String tokenString = prefs.getString('token') ?? '';
    final Map<String, dynamic> tokenMap = json.decode(tokenString);
    final TokenResponse tokenResponse = TokenResponse.fromJson(tokenMap);
    return tokenResponse;
  }

  Future<void> _submitBooking() async {
    if (!_bookingFormKey.currentState!.validate()) {
      return;
    }
    List<Map<String, String>> guestDataList = [];
    List<int> guestIds = [];
    for (int i = 0; i < numberOfGuests; i++) {
      Guest guest = guests[i];
      guestDataList.add({
        'name': guest.firstName + guest.lastName,
        'social_security': guest.socialSecurity,
        // 'email': guest.email,
        'phone': guest.phone,
      });
      guestIds.add(int.parse(guest.socialSecurity));
    }
    Map<String, dynamic> requestBody = {
      'property_id': widget.propertyId,
      'check_in_date': DateFormat('yyyy-MM-dd').format(widget.checkInDate),
      'check_out_date': DateFormat('yyyy-MM-dd').format(widget.checkOutDate),
      'booked_by': userDetails.socialSecurity,
      'guests': guestDataList,
      'room_id': widget.roomId,
    };

    var apiUrl = '${dotenv.env['API_URL']}/api/book-room';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String bookingId = responseData['booking_reference'];
        await _saveSignature(bookingId);
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thank You!'),
              content: const Text(
                  'Your booking has been submitted. Wait for approval.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage = errorResponse['error'] ?? 'Unknown error';

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Try Again'),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the current dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to submit booking. Status code: ${response.statusCode}'),
            duration: Duration(seconds: 3), // Adjust the duration as needed
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while submitting booking: $error'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _saveSignature(String bookingId) async {
    try {
      var _getToken = await getToken();
      var token = _getToken.token;
      exportedImage = await signControl.toPngBytes();
      var signatureApiUrl = '${dotenv.env['API_URL']}/api/signatures';
      List<int> bytes = exportedImage.buffer.asUint8List();

      var request = http.MultipartRequest('POST', Uri.parse(signatureApiUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes(
          'signature',
          bytes,
          filename: 'signature.png',
        ))
        ..fields['booking_id'] = bookingId;

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        final Map<String, dynamic> signatureErrorResponse =
            json.decode(response.body);
        final String signatureErrorMessage =
            signatureErrorResponse['error'] ?? 'Unknown error';
        return {'success': false, 'message': signatureErrorMessage};
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while saving signature: $error'),
          duration: Duration(seconds: 3),
        ),
      );
      return {'success': false, 'message': 'Error saving signature'};
    }
  }

  @override
  void initState() {
    super.initState();
    userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);
    userDetails = userDetailsProvider.userDetails!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Number of Guests',
                style: TextStyle(fontSize: 18),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (numberOfGuests > 0) {
                          numberOfGuests--;
                          if (guests.isNotEmpty) {
                            guests.removeLast();
                          }
                        }
                      });
                    },
                  ),
                  Text(
                    '$numberOfGuests',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (numberOfGuests < 3) {
                        setState(() {
                          numberOfGuests++;
                          guests.add(Guest());
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _bookingFormKey,
                child: Column(
                  children: [
                    for (int i = 0; i < numberOfGuests; i++)
                      GuestDetailsForm(
                        guest: guests[i],
                        index: i + 1,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Signature',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.black, width: 0.6), // Add border
                  borderRadius: BorderRadius.circular(
                      8.0), // Optional: Add border radius for rounded corners
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Signature(
                      height: 200,
                      controller: signControl,
                      backgroundColor: Colors.transparent,
                    )),
              ),
              const SizedBox(height: 20),
              // MaterialButton(
              //     color: Colors.green,
              //     onPressed: () async {
              //       exportedImage = await signControl.toPngBytes();
              //       final directory = await getDownloadsDirectory();
              //       final path = "${directory?.path}/signature.png";
              //       // await File(path).writeAsBytes(exportedImage);
              //       await io.File(path).writeAsBytes(exportedImage);

              //       setState(() {});
              //     },
              //     child: Text("Save")),
              // verticalSpaceRegular,
              ElevatedButton(
                onPressed: () async {
                  signControl.clear();
                },
                child: const Text('Reset Signature'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_bookingFormKey.currentState!.validate()) {
                    _submitBooking();
                  }
                },
                child: const Text('Submit Booking'),
              ),
              // if (exportedImage != null) Image.memory(exportedImage!),
            ],
          ),
        ),
      ),
    );
  }
}

class GuestDetailsForm extends StatelessWidget {
  final Guest guest;
  final int index;

  GuestDetailsForm({required this.guest, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guest $index Details',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: (value) => guest.firstName = value,
          decoration: const InputDecoration(labelText: 'First Name'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter first name';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: (value) => guest.lastName = value,
          decoration: const InputDecoration(labelText: 'Last Name'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter last name';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: (value) => guest.socialSecurity = value,
          decoration: const InputDecoration(labelText: 'Social Security'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter social security';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        // TextFormField(
        //   onChanged: (value) => guest.email = value,
        //   decoration: const InputDecoration(labelText: 'Email'),
        //   validator: (value) {
        //     if (value!.isEmpty) {
        //       return 'Please enter email';
        //     }
        //     return null;
        //   },
        // ),
        // const SizedBox(height: 8),
        TextFormField(
          onChanged: (value) => guest.phone = value,
          decoration: const InputDecoration(labelText: 'Phone'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class Guest {
  String firstName = '';
  String lastName = '';
  String socialSecurity = '';
  String email = '';
  String phone = '';
}
