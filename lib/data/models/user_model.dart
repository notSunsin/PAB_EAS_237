import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  String? profileImagePath;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImagePath,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        profileImagePath: json['profileImagePath'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImagePath': profileImagePath,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String s) =>
      UserModel.fromJson(jsonDecode(s));

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImagePath,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        profileImagePath: profileImagePath ?? this.profileImagePath,
      );
}
