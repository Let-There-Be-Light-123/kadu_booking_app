class Review {
  final String? id;
  final String? userId;
  final String? propertyId;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;

  Review({
    this.id,
    this.userId,
    this.propertyId,
    this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      propertyId: json['property_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // If you're sending reviews to the server, you might want a toJson method as well.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
