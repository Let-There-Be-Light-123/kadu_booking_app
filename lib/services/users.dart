class RegisteredUser {
  String id; // Unique user ID
  String email;
  bool is_verified;
  String social_security;
  String name;
  String phone;

  RegisteredUser({
    required this.social_security,
    required this.id,
    required this.email,
    required this.is_verified,
    required this.name,
    required this.phone,
  });

  // Convert Firestore document to Dart object
  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
      social_security: json['social_security'] ?? '',
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      is_verified: json['is_verified'] ?? false,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  // Convert Dart object to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'social_security': social_security,
      'id': id,
      'email': email,
      'is_verified': is_verified,
      'name': name,
      'phone': phone,
    };
  }
}
