import 'package:flutter/material.dart';

class LoadedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;

  LoadedNetworkImage({required this.imageUrl, this.fit = BoxFit.fill});

  @override
  _LoadedNetworkImageState createState() => _LoadedNetworkImageState();
}

class _LoadedNetworkImageState extends State<LoadedNetworkImage> {
  bool _isImageLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.imageUrl,
      fit: widget.fit,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          _isImageLoaded = true;
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        print('Error loading image: $error');
        return Center(
          child: Icon(
            Icons.error,
            color: Colors.red,
          ),
        );
      },
    );
  }
}
