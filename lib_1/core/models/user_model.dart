class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String phone;
  final String? profilePhotoUrl;
  final bool hasBiometric;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phone,
    this.profilePhotoUrl,
    this.hasBiometric = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'];
      } else if (json['id'] is String) {
        parsedId = int.tryParse(json['id']) ?? 0;
      }
    }

    return UserModel(
      id: parsedId,
      firstName: json['first_name'] ?? json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? json['phone_number'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? json['profile_picture_url'],
      hasBiometric: json['has_biometric'] == true,
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
      'has_biometric': hasBiometric,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}
