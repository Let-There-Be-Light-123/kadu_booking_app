import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/propertydetails/property_detail_page.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/horizontalcard/horizontal_card.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:provider/provider.dart';

class FavouritesPage extends StatefulWidget {
  final String tab;
  final List<Property>? properties;

  const FavouritesPage({Key? key, required this.tab, this.properties})
      : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  late UserDetailsProvider userDetailsProvider;
  late UserDetails userDetails;
  late Future<List<Property>> favoriteProperties;

  Future<void> _loadFavoriteProperties() async {
    try {
      userDetailsProvider =
          Provider.of<UserDetailsProvider>(context, listen: false);
      // print('Loading favorite properties...');
      List<Property> properties =
          await userDetailsProvider.getFavoriteProperties();
      // print('Favorite Properties: $properties');
      setState(() {
        favoriteProperties = Future.value(properties);
      });
    } catch (error) {
      // print('Error loading favorite properties: $error');
      // Handle error gracefully, show a snackbar or a user-friendly message
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing FavouritesPage...');
    UserDetailsProvider userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);
    userDetails = userDetailsProvider.userDetails!;
    _loadFavoriteProperties();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('FavouritesPage: didChangeDependencies');
    _loadFavoriteProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadFavoriteProperties();
        },
        child: Material(
          child: Column(
            children: [
              verticalSpaceLarge,
              Text(
                'Favorites',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColorOrange,
                  fontSize: 30,
                ),
              ),
              verticalSpaceRegular,
              Expanded(
                child: FavoriteList(
                  onToggleFavorite: _onToggleFavorite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this function to handle toggling favorites in the FavoriteList
  Future<void> _onToggleFavorite(String propertyId, bool isFavorite) async {
    try {
      userDetailsProvider.toggleFavoriteProperty(propertyId);
      await userDetailsProvider.getFavoriteProperties();
      setState(() {});
    } catch (error) {
      print('Error toggling favorite property: $error');
      // Handle error gracefully, show a snackbar or a user-friendly message
    }
  }
}

class FavoriteList extends StatefulWidget {
  final Function(String, bool) onToggleFavorite;

  const FavoriteList({Key? key, required this.onToggleFavorite})
      : super(key: key);

  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, userDetailsProvider, child) {
        return FutureBuilder<List<Property>>(
          future: userDetailsProvider.getFavoriteProperties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error loading favorite properties. Please try again.',
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No favorite properties found.'),
              );
            } else {
              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final Property property = snapshot.data![index];
                        final String propertyId =
                            property.propertyId.toString();

                        return Column(
                          children: [
                            verticalSpaceSmall,
                            GestureDetector(
                              onTap: () {
                                print('Navigating to PropertyDetailPage...');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetailPage(
                                      propertyId: propertyId,
                                      userDetailsProvider:
                                          Provider.of<UserDetailsProvider>(
                                              context,
                                              listen: false),
                                    ),
                                  ),
                                );
                              },
                              child: HorizontalCard(
                                propertyId: propertyId,
                                imageUrl: property.files.isNotEmpty
                                    ? '${dotenv.env['API_URL']}/storage/public/uploads/properties/${property.propertyId}/${property.files[0].filename}'
                                    : 'assets/fallback_image.png', // Use a default image from your assets
                                title: property.propertyName ?? '',
                                subtitle: property.address ?? '',
                                isFavorite: userDetailsProvider
                                    .isPropertyInFavorites(propertyId),
                                onToggleFavorite: (_) {
                                  print('Toggling favorite property...');
                                  widget.onToggleFavorite(
                                      propertyId,
                                      userDetailsProvider
                                          .isPropertyInFavorites(propertyId));
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: snapshot.data!.length,
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}
