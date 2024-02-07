// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kadu_booking_app/models/review_model.dart';
import 'package:kadu_booking_app/screens/editprofile/edit_profile.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:rate_in_stars/rate_in_stars.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewForm extends StatefulWidget {
  final propertyId;
  const ReviewForm({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<XFile> _selectedImages = [];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {}
  }

  Future<TokenResponse> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String tokenString = prefs.getString('token') ?? '';
    final Map<String, dynamic> tokenMap = json.decode(tokenString);
    final TokenResponse tokenResponse = TokenResponse.fromJson(tokenMap);
    return tokenResponse;
  }

  Future<void> _submitReview() async {
    var getToken = await _getToken();
    var token = getToken.token;

    final String apiUrl = '${dotenv.env['API_URL']}/api/reviews';

    final Uri uri = Uri.parse(apiUrl);
    final http.MultipartRequest request = http.MultipartRequest('POST', uri);

    debugPrint('${_rating.toInt()}');

    request.fields['property_id'] = widget.propertyId;
    request.fields['rating'] = _rating.toInt().toString();
    request.fields['comment'] = _commentController.text;
    request.headers['Authorization'] = 'Bearer $token';

    for (XFile image in _selectedImages) {
      request.files.add(await http.MultipartFile.fromPath(
        'images[]',
        image.path,
      ));
    }
    // Print the deconstructed request
    debugPrint('Request URL: ${request.url}');
    debugPrint('Request Headers: ${request.headers}');
    debugPrint('Request Fields: ${request.fields}');
    debugPrint('Request Files: ${request.files}');
    try {
      final http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _rating = 0;
          _commentController.clear();
          _selectedImages = [];
        });
      } else {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting review. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Your Review',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Rating: ',
                style: TextStyle(fontSize: 18),
              ),
              RatingBar.builder(
                itemSize: 30,
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
                  debugPrint("$rating");
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          if (_selectedImages.isNotEmpty) const SizedBox(height: 20),
          if (_selectedImages.isNotEmpty)
            Container(
              height: 80.0,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30.0)),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(_selectedImages[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.grey,
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 10.0),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              verticalSpaceRegular,
              ElevatedButton(
                onPressed: _submitReview,
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
