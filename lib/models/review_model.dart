// ignore_for_file: prefer_typing_uninitialized_variables

class Review {
  final String? id;
  var userId;
  final String? propertyId;
  final String? userName;
  double? rating;
  final String? comment;
  final DateTime? createdAt;
  final List<String>? photos;

  Review(
      {this.id,
      this.userId,
      this.userName,
      this.propertyId,
      this.rating,
      this.comment,
      this.createdAt,
      this.photos});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      propertyId: json['property_id'],
      rating: json['rating'],
      comment: json['comment'],
      photos: json['photos'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // If you're sending reviews to the server, you might want a toJson method as well.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'property_id': propertyId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
