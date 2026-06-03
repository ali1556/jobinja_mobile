class Company {
  final String id;
  final String name;
  final String slug;
  final String? logo;
  final String? industry;
  final String? website;
  final String? description;

  Company({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.industry,
    this.website,
    this.description,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      logo: json['logo'],
      industry: json['industry'],
      website: json['website'],
      description: json['description'],
    );
  }
}