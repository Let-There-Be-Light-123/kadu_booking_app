import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageService {
  Widget loadImage(String imageUrl) {
    if (isBase64Image(imageUrl)) {
      return _buildBase64Image(imageUrl);
    } else {
      return _buildNetworkImage(imageUrl);
    }
  }

  bool isBase64Image(String imageUrl) {
    return imageUrl.startsWith('data:image/');
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
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
        return Text('Error loading image');
      },
    );
  }

  Widget _buildBase64Image(String base64Image) {
    // Remove the data URI prefix
    String base64Data = base64Image.split(',')[1];

    List<int> imageBytes = base64.decode(base64Data);
    Uint8List uint8List = Uint8List.fromList(imageBytes);

    return Image.memory(
      uint8List
      // loadingBuilder: (BuildContext context, Widget child,
      //     ImageChunkEvent? loadingProgress) {
      //   if (loadingProgress == null) {
      //     return child;
      //   } else {
      //     return Center(
      //       child: CircularProgressIndicator(
      //         value: loadingProgress.expectedTotalBytes != null
      //             ? loadingProgress.cumulativeBytesLoaded /
      //                 (loadingProgress.expectedTotalBytes ?? 1)
      //             : null,
      //       ),
      //     );
      //   }
      // },
      // errorBuilder:
      //     (BuildContext context, Object error, StackTrace? stackTrace) {
      //   return Text('Error loading base64 image');
      // },
    );
  }
}


//Usage
//ImageService imageService = ImageService();
// Widget imageWidget = imageService.loadImage('https://example.com/image.jpg');