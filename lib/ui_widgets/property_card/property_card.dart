import 'package:flutter/material.dart';
import 'package:kadu_booking_app/api/property_service.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  PropertyCard({required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120, // Adjust the height as needed
              child: Image.network(
                '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              widget.property.propertyName ?? '',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
