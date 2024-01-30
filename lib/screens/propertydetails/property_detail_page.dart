import 'package:flutter/material.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/hoteldescription/hotel_description.dart';
import 'package:share/share.dart';

class PropertyDetailPage extends StatefulWidget {
  final String propertyId;
  final UserDetailsProvider? userDetailsProvider; // Pass userDetailsProvider

  const PropertyDetailPage({
    Key? key,
    required this.propertyId,
    this.userDetailsProvider,
  }) : super(key: key);

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  late Property propertyData = Property();
  bool isLoading = true;
  bool isError = false;

  String buildShareableUrl(String propertyId) {
    String baseUrl = 'your_base_url';
    Uri shareableUri =
        Uri.parse('$baseUrl/property-details?propertyId=$propertyId');
    return shareableUri.toString();
  }

  Future<void> _loadPropertyData() async {
    try {
      var data = await fetchPropertyData(widget.propertyId);
      Future.delayed(Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            propertyData = data!;
            isLoading = false;
          });
        }
      });
    } catch (error) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            isError = true;
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPropertyData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Image.asset('assets/shelter_360.gif'),
      );
    } else if (isError) {
      return Text('Failed to load property data. Please try again.');
    }

    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            color: AppColors.backgroundColorDefault,
          ),
          HotelDescription(
            propertyData: propertyData,
            userDetailsProvider: widget.userDetailsProvider,
            onAvailabilityChanged: (bool availability) {},
          ),
          Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 25,
                  color: AppColors.primaryColorOrange,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share_rounded),
                  iconSize: 25,
                  color: AppColors.primaryColorOrange,
                  onPressed: () {
                    String propertyId = widget.propertyId;
                    String shareableUrl = buildShareableUrl(propertyId);
                    Share.share(shareableUrl,
                        subject: 'Check out this property!');
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
