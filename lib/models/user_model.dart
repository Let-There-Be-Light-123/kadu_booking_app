class AppUser {
  int user_id;
  String user_social_security;
  String user_name;
  String user_email;
  String user_password;

  AppUser(this.user_id, this.user_social_security, this.user_email,
      this.user_name, this.user_password);

  Map<String, dynamic> toJson() => {
        'user_id': user_id.toString(),
        'user_social_security': user_social_security,
        'user_name': user_name,
        'user_email': user_email,
        'user_password': user_password
      };
}
