class FileModel {
  int? id;
  String? propertyId;
  String? bookingId;
  int? userId;
  String? filename;
  String? filepath;
  String? filetype;
  String? createdAt;
  String? updatedAt;

  FileModel({
    this.id,
    this.propertyId,
    this.bookingId,
    this.userId,
    this.filename,
    this.filepath,
    this.filetype,
    this.createdAt,
    this.updatedAt,
  });

  FileModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        propertyId = json['property_id'] ?? '',
        bookingId = json['booking_reference'] ?? '',
        userId = json['social_security'] ?? 0,
        filename = json['filename'] ?? '',
        filepath = json['filepath'] ?? '',
        filetype = json['filetype'] ?? '',
        createdAt = json['created_at'] ?? '',
        updatedAt = json['updated_at'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'property_id': propertyId ?? '',
      'booking_reference': bookingId ?? '',
      'social_security': userId ?? 0,
      'filename': filename ?? '',
      'filepath': filepath ?? '',
      'filetype': filetype ?? '',
      'created_at': createdAt ?? '',
      'updated_at': updatedAt ?? '',
    };
  }
}
