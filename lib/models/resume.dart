class Resume {
  final String id;
  String? about;
  String? phoneNumber;
  List<Language> languages;
  List<String> skills;
  List<WorkExperience> workExperiences;

  Resume({
    required this.id,
    this.about,
    this.phoneNumber,
    List<Language>? languages,
    List<String>? skills,
    List<WorkExperience>? workExperiences,
  })  : languages = languages ?? [],
        skills = skills ?? [],
        workExperiences = workExperiences ?? [];

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'],
      about: json['about'],
      phoneNumber: json['phoneNumber'],
      languages: (json['languages'] as List?)
          ?.map((l) => Language.fromJson(l))
          .toList() ??
          [],
      skills: (json['skills'] as List?)?.map((s) => s as String).toList() ?? [],
      workExperiences: (json['workExperiences'] as List?)
          ?.map((w) => WorkExperience.fromJson(w))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'about': about,
      'phoneNumber': phoneNumber,
      'languages': languages.map((l) => l.toJson()).toList(),
      'skills': skills,
      'workExperiences': workExperiences.map((w) => w.toJson()).toList(),
    };
  }

  /// Returns a score from 0 to 100 based on how complete the resume is.
  int completionScore() {
    int points = 0;
    int total = 5; // about, phone, languages, skills, workExperiences

    if (about != null && about!.trim().isNotEmpty) points++;
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) points++;
    if (languages.isNotEmpty) points++;
    if (skills.isNotEmpty) points++;
    if (workExperiences.isNotEmpty) points++;

    return (points / total * 100).round();
  }
}

class Language {
  String name;
  ProficiencyLevel level;

  Language({required this.name, required this.level});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      level: ProficiencyLevel.values.firstWhere(
            (e) => e.toString() == json['level'],
        orElse: () => ProficiencyLevel.beginner,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level.toString(),
    };
  }
}

enum ProficiencyLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  fluent('Fluent'),
  native('Native');

  final String display;
  const ProficiencyLevel(this.display);
}

class WorkExperience {
  String companyId;
  String companyName;
  DateTime startDate;
  DateTime? endDate; // null means currently working
  String? description;

  WorkExperience({
    required this.companyId,
    required this.companyName,
    required this.startDate,
    this.endDate,
    this.description,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      companyId: json['companyId'],
      companyName: json['companyName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
    };
  }
}