import 'package:flutter/material.dart';

class HotelTile extends StatelessWidget {
  final String imageUrl;
  final Map<String, dynamic> stayData;
  final description;
  final VoidCallback onTapCallback; // Callback function

  HotelTile({
    required this.imageUrl,
    required this.stayData,
    required this.description,
    required this.onTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: onTapCallback, // Call the callback function on tap
          child: ListTile(
            leading: Image.network(
              imageUrl, // Use imageUrl from stayData
              fit: BoxFit.cover,
            ),
            title: Text(
              stayData['stayName'], // Use stayName from stayData
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              stayData['location'], // Use location from stayData
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () {
                // Handle favorite icon toggle logic here
                // You can use a state management solution (e.g., Provider, Bloc, etc.)
              },
            ),
          ),
        ),
      ),
    );
  }
}
