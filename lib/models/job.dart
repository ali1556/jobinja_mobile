class Job {
  final String id;
  final String title;
  final String companyName;
  final String companySlug;
  final String? companyLogo;
  final String location;
  final String contractType;
  final String salaryDisplay;
  final String publishedAt;
  final bool isRemote;
  final String? description;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companySlug,
    this.companyLogo,
    required this.location,
    required this.contractType,
    required this.salaryDisplay,
    required this.publishedAt,
    this.isRemote = false,
    this.description,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      companyName: json['company']['name'],
      companySlug: json['company']['slug'],
      companyLogo: json['company']['logo'],
      location: json['location']['province'] + (json['location']['city'] != null ? ' - ${json['location']['city']}' : ''),
      contractType: json['contract_type'],
      salaryDisplay: json['salary']['display'],
      publishedAt: json['published_at'],
      isRemote: json['is_remote'] ?? false,
      description: json['description'],
    );
  }
}