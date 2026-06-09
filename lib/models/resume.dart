// models/resume.dart
class Resume {
  final String id;
  String? about;
  String? phoneNumber;

  Resume({required this.id, this.about, this.phoneNumber});

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'],
      about: json['about'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'about': about,
      'phoneNumber': phoneNumber,
    };
  }
}