class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String phone;
  final String? profilePhotoUrl;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phone,
    this.profilePhotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? json['phone_number'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}
