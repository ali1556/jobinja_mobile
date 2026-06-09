import 'resume.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final Resume? resume; // new field

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.resume,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      resume: json['resume'] != null ? Resume.fromJson(json['resume']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'resume': resume?.toJson(),
    };
  }
}