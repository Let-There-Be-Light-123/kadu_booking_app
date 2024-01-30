import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:location/location.dart' as location;
import 'package:provider/provider.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

const kGoogleApiKey = 'AIzaSyB6Tu751DZ1ZP9iq3dQaZTC9hqf_bRNGcs';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);

  Set<Marker> markersList = {};
  late GoogleMapController googleMapController;
  final Mode _mode = Mode.overlay;
  Prediction?
      selectedPrediction; // Add this line to store the selected prediction

  late UserDetailsProvider userDetailsProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: const Text("Select Your location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markersList,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _handlePressButton,
                child: const Text("Search Your Location"),
              ),
              ElevatedButton(
                onPressed: _detectCurrentLocation,
                child: const Text("Detect Current Location"),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Call the method to confirm the location
                  _confirmLocation();
                },
                child: const Text("Confirm Location"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      language: 'en',
      strictbounds: false,
      types: [""],
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      components: [Component(Component.country, "usa")],
    );

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  Future<void> _detectCurrentLocation() async {
    location.Location _location = location.Location();

    try {
      location.LocationData currentLocation = await _location.getLocation();
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(currentLocation.latitude!, currentLocation.longitude!),
            18.0,
          ),
        );

        markersList.clear();
        markersList.add(
          Marker(
            markerId: const MarkerId("0"),
            position: LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
            infoWindow: const InfoWindow(
              title: "Current Location",
            ),
          ),
        );

        setState(() {});

        // Get prediction for the current location
        Prediction? prediction = await _getPlacePrediction(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        // Assign the prediction to the selectedPrediction object
        setState(() {
          selectedPrediction = prediction;
        });

        userDetailsProvider.setAddressId(
            currentLocation.longitude!, currentLocation.latitude!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error detecting current location.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error detecting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error detecting current location.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Prediction?> _getPlacePrediction(double lat, double lng) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    try {
      PlacesSearchResponse response = await places.searchNearbyWithRadius(
        Location(lat: lat, lng: lng),
        50, // Adjust the radius as needed
        type: "address", // Use the appropriate type based on your needs
      );

      if (response.results != null && response.results!.isNotEmpty) {
        // Extract details from the first result
        PlacesSearchResult result = response.results!.first;

        return Prediction(
          placeId: result.placeId,
          description: result.name,
          types: [''],
        );
      }
    } catch (e) {
      print('Error getting place prediction: $e');
    }

    return null;
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'An error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> displayPrediction(
    Prediction p,
    ScaffoldState? currentState,
  ) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    debugPrint(' Detail result ${json.encode(detail.result.placeId)}');

    markersList.clear();
    markersList.add(
      Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name),
      ),
    );

    setState(() {});

    googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lat, lng),
        18.0,
      ),
    );
    selectedPrediction = p;
  }

  void _confirmLocation() {
    UserDetailsProvider userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);

    UserDetails userDetails = userDetailsProvider.userDetails!;
    if (userDetailsProvider != null) {
      String formattedAddress = _getFormattedAddress(selectedPrediction);

      userDetailsProvider.setUserAddress(formattedAddress);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location before confirming.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getFormattedAddress(Prediction? prediction) {
    if (prediction != null && prediction.structuredFormatting != null) {
      List<String> mainTextParts =
          prediction.structuredFormatting!.mainText.split(',');
      List<String> lastThreeParts = [];

      if (mainTextParts.length >= 3) {
        int startIndex = mainTextParts.length - 3;
        lastThreeParts = mainTextParts
            .sublist(startIndex)
            .map((part) => part.trim())
            .toList();

        print(lastThreeParts);
      } else {
        lastThreeParts = mainTextParts.map((part) => part.trim()).toList();
      }
      String formattedAddress = lastThreeParts.join(', ');
      return formattedAddress.trim();
    } else {
      return '';
    }
  }
}
