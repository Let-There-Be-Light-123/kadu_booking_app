import 'dart:convert'; // Import for decoding JSON data
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kadu_booking_app/models/property_model.dart';
import 'package:kadu_booking_app/models/file_model.dart';

class Room {
  final String? roomId;
  final String? propertyId;
  final String? roomName;
  final bool? isActive;
  final String? roomDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Room({
    this.roomId,
    this.propertyId,
    this.roomName,
    this.isActive,
    this.roomDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['room_id'],
      propertyId: json['property_id'],
      roomName: json['room_name'],
      isActive: json['is_active'] == 1,
      roomDescription: json['room_description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static List<Room> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Room.fromJson(json)).toList();
  }
}

class Property {
  final String? propertyId;
  final String? propertyName;
  final String? propertyType;
  final bool? isActive;
  final bool? isFeatured;
  final bool? isMostLiked;
  final int? likes;
  final bool? onHomepage;
  final String? propertyDescription;
  final String? contact;
  final double? lat; // Change the type to double
  final double? lng; // Change the type to double
  final String? address;
  final int? addressId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<FileModel> files;

  Property({
    this.propertyId,
    this.propertyName,
    this.propertyType,
    this.isActive,
    this.isFeatured,
    this.isMostLiked,
    this.likes,
    this.onHomepage,
    this.propertyDescription,
    this.contact,
    this.lat,
    this.lng,
    this.address,
    this.addressId,
    this.createdAt,
    this.updatedAt,
    this.files = const [],
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      propertyId: json['property_id'],
      propertyName: json['property_name'],
      propertyType: json['property_type'],
      isActive: json['is_active'] == 1,
      isFeatured: json['is_featured'] == 1,
      isMostLiked: json['is_most_liked'] == 1,
      likes: json['likes'],
      onHomepage: json['on_homepage'] == 1,
      propertyDescription: json['property_description'],
      contact: json['contact'],
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
      address: json['address'],
      files: (json['files'] as List<dynamic>)
          .map<FileModel>((dynamic file) => FileModel.fromJson(file))
          .toList(),
      addressId: json['address_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

Future<Property?> fetchPropertyData(String propertyId) async {
  final response = await http
      .get(Uri.parse('${dotenv.env['API_URL']}/api/properties/$propertyId'));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);
    var data = jsonData['data'];
    Property property = Property.fromJson(data);
    debugPrint('Property files ${property}');
    return property;
  } else {
    throw Exception('Failed to load property data');
  }
}
