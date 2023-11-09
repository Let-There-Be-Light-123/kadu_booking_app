import 'dart:ffi';

class RegisteredUser {
  String id; // Unique user ID
  String email;
  bool is_verified;
  Int ssnid;

  RegisteredUser({
    required this.ssnid,
    required this.id,
    required this.email,
    required this.is_verified,
  });

  // Convert Firestore document to Dart object
  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
      ssnid: json['ssnid'] ?? null,
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      is_verified: json['is_verified'] ?? false,
    );
  }

  // Convert Dart object to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'ssnid': ssnid,
      'id': id,
      'email': email,
      'is_verified': is_verified,
    };
  }
}
