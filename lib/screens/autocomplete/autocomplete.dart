import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class LocationSearchScreen extends StatefulWidget {
  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final placesApiClient =
      GoogleMapsPlaces(apiKey: 'AIzaSyB6Tu751DZ1ZP9iq3dQaZTC9hqf_bRNGcs');

  TextEditingController searchController = TextEditingController();
  List<Prediction> predictions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search for a location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchPlaces();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      predictions[index].description ?? 'Default Description'),
                  onTap: () {
                    getPlaceDetails(
                        predictions[index].placeId ?? 'Default PlaceId');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void searchPlaces() async {
    if (searchController.text.isNotEmpty) {
      PlacesAutocompleteResponse response = await placesApiClient.autocomplete(
        searchController.text,
        language: 'en',
        types: ['geocode'],
      );

      setState(() {
        predictions = response.predictions;
      });
    }
  }

  void getPlaceDetails(String placeId) async {
    PlacesDetailsResponse response =
        await placesApiClient.getDetailsByPlaceId(placeId);

    if (response.status == 'OK') {
      double latitude = response.result.geometry!.location.lat;
      double longitude = response.result.geometry!.location.lng;

      // Use the latitude and longitude as needed
      print('Selected Location: $latitude, $longitude');

      // Optionally, you can navigate to a map screen or perform other actions
    } else {
      print('Failed to get place details. Status: ${response.status}');
    }
  }
}
