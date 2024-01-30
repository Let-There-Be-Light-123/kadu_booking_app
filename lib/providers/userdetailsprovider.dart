import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:kadu_booking_app/models/file_model.dart';
import 'package:kadu_booking_app/models/property_model.dart';

class UserDetailsProvider extends ChangeNotifier {
  UserDetails? _userDetails;

  UserDetails? get userDetails => _userDetails;

  List<FileModel>? _files;
  List<FileModel>? get files => _files;
  FileModel _lastFile = new FileModel();
  FileModel get lastFile => _lastFile; // Getter for the last file

  String _cachedAddress = '';

  List<String> _favoritePropertyIds = [];
  List<String> get favoritePropertyIds => _favoritePropertyIds;

  void setUserDetails(UserDetails userDetails) {
    _userDetails = userDetails;

    if (_userDetails?.files != null &&
        _userDetails!.files?.isNotEmpty == true) {
      _lastFile = _userDetails!.files!.first;
    } else if (_userDetails?.files == null || _userDetails!.files!.isEmpty) {
      _userDetails = _userDetails?.copyWith(files: [_lastFile]);
    }

    if (userDetails.address == null || userDetails.address!.isEmpty) {
      // Assign the cached address to userDetails
      userDetails = userDetails.copyWith(address: _cachedAddress);
    } else {
      // Cache the new address
      _cachedAddress = userDetails.address!;
    }
    notifyListeners();
  }

  void updateLastFile() {
    if (_files != null && _files!.isNotEmpty) {
      _lastFile = _files!.last;
    }
  }

  void setUserFiles(List<FileModel>? files) {
    _files = files;
    notifyListeners();
  }

  void setUserFavoriteProperties(List<String> favoriteProperties) {
    if (_userDetails != null) {
      _userDetails =
          _userDetails!.copyWith(favoriteProperties: favoriteProperties);
      notifyListeners();
    }
  }

  int? getSocialSecurity() {
    return _userDetails?.socialSecurity ?? 123;
  }

  void setAddressId(double? longitude, double? latitude) {
    if (_userDetails != null) {
      _userDetails = _userDetails!.copyWith(
        lng: longitude,
        lat: latitude,
      );
      notifyListeners();
    }
  }

  String? getUserAddress() {
    return _cachedAddress.isNotEmpty ? _cachedAddress : _userDetails?.address;
  }

  void setUserAddress(String address) {
    if (_userDetails != null) {
      _userDetails!.address = address;
      _cachedAddress = address;
      notifyListeners();
    }
  }

  List<String> getFavoritePropertyIds() {
    return _favoritePropertyIds;
  }

  void setFavoritePropertyIds(List<String> favoritePropertyIds) {
    _favoritePropertyIds = favoritePropertyIds;
    notifyListeners();
  }

  Future<List<Property>> getFavoriteProperties() async {
    final List<String> favoritePropertyIds = getFavoritePropertyIds();

    if (favoritePropertyIds.isEmpty) {
      // print('No favorite property IDs to fetch.');
      return [];
    }
    final httpClient = HttpClient();
    try {
      final request = await httpClient.postUrl(
        Uri.parse('${dotenv.env['API_URL']}/api/properties/details'),
      );
      request.headers.set('Content-Type', 'application/json');
      final payload = jsonEncode({
        'property_ids': favoritePropertyIds,
      });
      request.write(payload);
      final response = await request.close();
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(
          await utf8.decodeStream(response),
        );

        if (responseData['data'] is List) {
          List<Property> propertyData =
              (responseData['data'] as List).map((item) {
            return Property(
              propertyId: item['property_id'],
              files: (item['files'] as List)
                  .map((fileItem) => FileModel.fromJson(fileItem))
                  .toList(),
              propertyName: item['property_name'],
              address: item['address'],
              lat: item['lat'],
              lng: item['lng'],
            );
          }).toList();
          // print("The fav properties are $propertyData");
          return propertyData;
        } else {
          print('Unexpected response format: $responseData');
          return [];
        }
      } else {
        print(
            'Failed to fetch favorite properties. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('Error fetching favorite properties: $e');
      return [];
    } finally {
      httpClient.close();
    }
  }

  Future<void> addFavoriteProperty(int? userId, String propertyId) async {
    var httpClient = HttpClient();
    try {
      var apiUrl = '${dotenv.env['API_URL']}/api/user/favorite-properties';
      var request = await httpClient.postUrl(Uri.parse(apiUrl));
      request.headers.set('Content-Type', 'application/json');
      var requestBody = jsonEncode({
        "social_security": userId,
        "property_id": propertyId,
      });

      request.write(requestBody);
      var response = await request.close();
      if (response.statusCode == 200) {
        var responseData = jsonDecode(await utf8.decodeStream(response));
        Fluttertoast.showToast(msg: 'Success: ${responseData['message']}');
      } else {
        Fluttertoast.showToast(msg: 'Error: ${response.reasonPhrase}');
        var errorResponse = jsonDecode(await utf8.decodeStream(response));
        Fluttertoast.showToast(msg: 'Server error: ${errorResponse['error']}');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error: $error');
    } finally {
      httpClient.close();
    }
  }

  Future<void> removeFavoriteProperty(int? userId, String propertyId) async {
    var httpClient = HttpClient();
    try {
      var apiUrl =
          '${dotenv.env['API_URL']}/api/user/favorite-properties/remove';
      var request = await httpClient.postUrl(Uri.parse(apiUrl));
      request.headers.set('Content-Type', 'application/json');
      var requestBody = jsonEncode({
        "social_security": userId,
        "property_id": propertyId,
      });

      request.write(requestBody);
      var response = await request.close();
      if (response.statusCode == 200) {
        var responseData = jsonDecode(await utf8.decodeStream(response));
        Fluttertoast.showToast(msg: 'Success: ${responseData['message']}');
      } else {
        Fluttertoast.showToast(msg: 'Error: ${response.reasonPhrase}');
        var errorResponse = jsonDecode(await utf8.decodeStream(response));
        Fluttertoast.showToast(msg: 'Server error: ${errorResponse['error']}');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error: $error');
    } finally {
      httpClient.close();
    }
  }

  void updateFavoritePropertyIds(List<String>? propertyIds) {
    _favoritePropertyIds ??= [];
    _favoritePropertyIds = propertyIds ?? [];
    notifyListeners();
  }

  bool isPropertyInFavorites(String propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }

  void toggleFavoriteProperty(String propertyId) {
    final List<String> updatedFavoriteProperties = [..._favoritePropertyIds];

    if (_favoritePropertyIds.contains(propertyId)) {
      removeFavoriteProperty(_userDetails?.socialSecurity, propertyId);
      updatedFavoriteProperties.remove(propertyId);
    } else {
      addFavoriteProperty(_userDetails?.socialSecurity, propertyId);
      updatedFavoriteProperties.add(propertyId);
    }

    updateFavoritePropertyIds(updatedFavoriteProperties);
  }
}

extension UserDetailsExtension on UserDetails {
  UserDetails copyWith(
      {int? socialSecurity,
      String? name,
      String? email,
      int? phone,
      String? address,
      String? roleId,
      bool? isVerified,
      bool? isActive,
      String? emailVerifiedAt,
      bool? isHomeless,
      String? createdAt,
      String? updatedAt,
      List<String>? favoriteProperties,
      String? addressId,
      double? lng,
      double? lat, // New field for address ID,
      List<FileModel>? files}) {
    return UserDetails(
        socialSecurity: socialSecurity ?? this.socialSecurity,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        roleId: roleId ?? this.roleId,
        isVerified: isVerified ?? this.isVerified,
        isActive: isActive ?? this.isActive,
        isHomeless: isHomeless ?? this.isHomeless,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        favoriteProperties: favoriteProperties ?? this.favoriteProperties,
        addressId: addressId ?? '',
        lng: lng ?? 0.0,
        lat: lat ?? 0.0,
        files: files ?? []);
  }
}

class UserDetails {
  final int socialSecurity;
  final String? name;
  final String? email;
  final int? phone;
  String? address;
  final String roleId;
  final bool isVerified;
  final bool isActive;
  final bool? isHomeless;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<String>? favoriteProperties;
  final String? addressId; // New field for address ID
  final double? lng; // New field for longitude
  final double? lat; // New field for latitude
  final List<FileModel>? files;

  UserDetails({
    required this.socialSecurity,
    this.name = "",
    this.email = "",
    this.phone = 0,
    this.address = "",
    required this.roleId,
    this.isVerified = false,
    this.isActive = false,
    this.isHomeless = false,
    this.emailVerifiedAt = "",
    this.createdAt = "",
    this.updatedAt = "",
    this.favoriteProperties = const [],
    this.addressId = "",
    this.lng = 0.0,
    this.lat = 0.0,
    this.files,
  });

  // Factory method to create a UserDetails instance from JSON data
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UserDetails(
        socialSecurity: data['social_security'],
        name: data['name'],
        email: data['email'] ?? '',
        phone: data['phone'] ?? 0,
        roleId: data['role_id'],
        isVerified: data['is_verified'],
        isActive: data['is_active'] ?? false,
        isHomeless: data['is_homeless'],
        emailVerifiedAt: data['email_verified_at'],
        address: data['address'],
        createdAt: data['created_at'],
        updatedAt: data['updated_at'],
        favoriteProperties:
            List<String>.from(data['favorite_properties'] ?? []),
        addressId: data['address_id'], // New field for address ID
        lng: data['lng'],
        lat: data['lat'],
        files: (data['files'] as List)
            .map((fileItem) => FileModel.fromJson(fileItem))
            .toList());
  }
}
