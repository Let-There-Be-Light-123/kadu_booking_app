import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:kadu_booking_app/models/file_model.dart';
import 'package:kadu_booking_app/models/property_model.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kadu_booking_app/ui_widgets/horizontalcard/horizontal_card.dart';
import 'package:kadu_booking_app/ui_widgets/property_card/property_card.dart';
import 'package:provider/provider.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});
  @override
  State<CustomSearchBar> createState() => Custom_SearchBarState();
}

class Custom_SearchBarState extends State<CustomSearchBar> {
  TextEditingController _locationController = TextEditingController();
  List<Property> _properties = [];
  late UserDetails userDetails;
  Timer? _debounce;
  final int _debounceDuration = 300;

  UserDetailsProvider _userDetailsProvider = UserDetailsProvider();

  Future<List<Property>> _searchProperties(String location) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/search-properties-in-city'),
        body: {'city': location},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        var data = jsonData['data'];
        if (data is List) {
          List<Property> propertyData = data.map((item) {
            return Property(
              propertyId: item['property_id'],
              files: (item['files'] as List)
                  .map((fileItem) => FileModel.fromJson(fileItem))
                  .toList(),
              propertyName: item['property_name'],
              address: item['address'],
              lat: item['lat'],
              lng: item['lng'],
            );
          }).toList();

          return propertyData;
        } else {
          print('Unexpected response format: $jsonData');
          return [];
        }
      } else {
        // print('Failed to load properties. Status Code: ${response.statusCode}');
        throw Exception('Failed to load properties');
      }
    } catch (e, stackTrace) {
      print('Error fetching properties: $e');
      throw Exception('Failed to load properties');
    }
  }

  Future<List<Property>> _onLocationChanged(String location) async {
    if (_debounce != null) {
      _debounce!.cancel();
    }

    try {
      List<Property> properties = await _searchProperties(location);
      return properties;
    } catch (e, stackTrace) {
      print('Error fetching properties: $e');
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);
    userDetails = _userDetailsProvider.userDetails!;
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = '${dotenv.env['API_URL']}';

    return Container(
      height: 50,
      color: AppColors.backgroundColorDefault,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: SearchAnchor(
            dividerColor: Colors.amber,
            viewHintText: "Search Location",
            viewBackgroundColor: AppColors.backgroundColorDefault,
            builder:
                (BuildContext context, SearchController locationController) {
              return SearchBar(
                backgroundColor:
                    MaterialStateProperty.all(AppColors.backgroundColorDefault),
                controller: locationController,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onTap: () {
                  locationController.openView();
                },
                onChanged: (_) {
                  locationController.openView();
                },
                leading: const Icon(
                  Icons.search,
                  color: AppColors.primaryColorOrange,
                ),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController locationController) {
              return Future.microtask(() async {
                _properties = await _onLocationChanged(locationController.text);
                if (_properties == []) {
                  return [];
                }
                List<Widget> horizontalCards = _properties.map((property) {
                  return HorizontalCard(
                    propertyId: property.propertyId ?? '',
                    imageUrl:
                        '$baseUrl/storage/public/uploads/properties/${property.propertyId}/${property.files[0].filename}',
                    title: property.propertyName ?? '',
                    subtitle: property.address ?? '',
                    isFavorite: _userDetailsProvider
                        .isPropertyInFavorites(property.propertyId ?? ''),
                    onToggleFavorite: (_isFavorite) => _toggleFavourite(
                      propertyId: property.propertyId ?? '',
                      title: property.propertyName ?? '',
                      subtitle: property.address ?? '',
                      isFavorite: _isFavorite,
                    ),
                  );
                }).toList();

                return horizontalCards;
              });
            },
          ),
        ),
      ),
    );
  }

  _toggleFavourite({
    required String propertyId,
    required String title,
    required String subtitle,
    required bool isFavorite,
  }) {
    _userDetailsProvider.toggleFavoriteProperty(propertyId);

    Set<String> currentFavorites =
        Set.from(_userDetailsProvider.userDetails!.favoriteProperties ?? []);

    if (isFavorite && !currentFavorites.contains(propertyId)) {
      currentFavorites.add(propertyId);
    } else if (!isFavorite && currentFavorites.contains(propertyId)) {
      currentFavorites.remove(propertyId);
    }

    _userDetailsProvider.setUserFavoriteProperties(currentFavorites.toList());
  }
}
