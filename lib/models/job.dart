// models/job.dart
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
  final int? minSalary;      // numeric min salary (in millions or raw)
  final int? maxSalary;      // optional
  final DateTime publishedAtDate; // parsed date for sorting

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
    this.minSalary,
    this.maxSalary,
    required this.publishedAtDate,
  });

}