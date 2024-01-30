import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/propertydetails/property_detail_page.dart';
import 'package:provider/provider.dart';

class HorizontalCard extends StatefulWidget {
  final String propertyId;
  final String imageUrl;
  final String title;
  final String subtitle;
  bool isFavorite;
  final Function(bool isFavorite) onToggleFavorite;

  HorizontalCard({
    required this.propertyId,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  _HorizontalCardState createState() => _HorizontalCardState();
}

class _HorizontalCardState extends State<HorizontalCard> {
  Color _iconColor = Colors.red;
  late UserDetails userDetails;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailPage(
                userDetailsProvider:
                    Provider.of<UserDetailsProvider>(context, listen: false),
                propertyId: widget.propertyId ??
                    ''), // Pass the property ID or relevant data
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Favorite IconButton
              IconButton(
                icon: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    widget.isFavorite = !widget.isFavorite;
                  });
                  widget.onToggleFavorite(widget.isFavorite);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
