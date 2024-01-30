import 'package:kadu_booking_app/models/file_model.dart';
import 'package:kadu_booking_app/models/room_model.dart';

class PropertyModel {
  String? id;
  String? title;
  String? category;
  bool? isActive;
  bool? isFeatured;
  bool? isMostLiked;
  int? likes;
  bool? onHomepage;
  String? description;
  String? contact;
  double? lat;
  double? lng;
  String? address;
  int? addressId;
  String? createdAt;
  String? updatedAt;
  List<RoomModel> rooms;
  List<FileModel> files;

  PropertyModel({
    this.id,
    this.title,
    this.category,
    this.isActive,
    this.isFeatured,
    this.isMostLiked,
    this.likes,
    this.onHomepage,
    this.description,
    this.contact,
    this.lat,
    this.lng,
    this.address,
    this.addressId,
    this.createdAt,
    this.updatedAt,
    this.rooms = const [],
    this.files = const [],
  });

  PropertyModel.fromJson(Map<String, dynamic> json)
      : id = json['property_id'],
        title = json['property_name'],
        category = json['property_type'],
        isActive = json['is_active'],
        isFeatured = json['is_featured'],
        isMostLiked = json['is_most_liked'],
        likes = json['likes'],
        onHomepage = json['on_homepage'],
        description = json['property_description'],
        contact = json['contact'],
        lat = json['lat'],
        lng = json['lng'],
        address = json['address'],
        addressId = json['address_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        rooms = (json['rooms'] as List<dynamic>?)
                ?.map((room) => RoomModel.fromJson(room))
                .toList() ??
            [],
        files = (json['files'] as List<dynamic>?)
                ?.map((file) => FileModel.fromJson(file))
                .toList() ??
            [];

  Map<String, dynamic> toJson() {
    return {
      'property_id': id,
      'property_name': title,
      'property_type': category,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_most_liked': isMostLiked,
      'likes': likes,
      'on_homepage': onHomepage,
      'property_description': description,
      'contact': contact,
      'lat': lat,
      'lng': lng,
      'address': address,
      'address_id': addressId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'rooms': rooms.map((room) => room.toJson()).toList(),
      'files': files.map((file) => file.toJson()).toList(),
    };
  }
}
