class RoomModel {
  int? roomId;
  int? propertyId;
  String? roomName;
  bool? isActive;
  String? roomDescription;
  String? createdAt;
  String? updatedAt;

  RoomModel({
    this.roomId,
    this.propertyId,
    this.roomName,
    this.isActive,
    this.roomDescription,
    this.createdAt,
    this.updatedAt,
  });

  RoomModel.fromJson(Map<String, dynamic> json)
      : roomId = json['room_id'],
        propertyId = json['property_id'],
        roomName = json['room_name'],
        isActive = json['is_active'],
        roomDescription = json['room_description'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'property_id': propertyId,
      'room_name': roomName,
      'is_active': isActive,
      'room_description': roomDescription,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
