import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resume.dart';
import '../models/user.dart';
import '../models/job.dart';
import '../models/company.dart';

class MockApiService {
  String? _currentToken;
  User? _currentUser;

  MockApiService();


  Future<Map<String, dynamic>> signup(String name, String email,
      String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final storedPassword = prefs.getString('pass_$normalizedEmail');

    if (storedPassword != null) {
      throw Exception('Email already exists');
    }

    // Generate a new ID
    int newId = (prefs.getInt('next_user_id') ?? 1);
    await prefs.setInt('next_user_id', newId + 1);


    await prefs.setString('user_${newId}_name', name.trim());
    await prefs.setString('user_${newId}_email', normalizedEmail);
    await prefs.setString('pass_$normalizedEmail', password);

    final newUser = User(id: newId, name: name.trim(), email: normalizedEmail);
    _currentUser = newUser;
    _currentToken = 'mock_token_$newId';
    await prefs.setString('auth_token', _currentToken!);
    return {'user': newUser, 'token': _currentToken};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final storedPassword = prefs.getString('pass_$normalizedEmail');

    if (storedPassword == null || storedPassword != password) {
      throw Exception('Invalid email or password');
    }

    int? userId;
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('user_') && key.endsWith('_email')) {
        final savedEmail = prefs.getString(key);
        if (savedEmail == normalizedEmail) {
          userId = int.parse(key.split('_')[1]);
          break;
        }
      }
    }
    if (userId == null) throw Exception('User not found');

    final name = prefs.getString('user_${userId}_name') ?? 'User';
    final user = User(id: userId, name: name, email: normalizedEmail);
    _currentUser = user;
    _currentToken = 'mock_token_$userId';
    await prefs.setString('auth_token', _currentToken!);
    return {'user': user, 'token': _currentToken};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _currentUser = null;
    _currentToken = null;
  }

  Future<User> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || !token.startsWith('mock_token_')) {
      throw Exception('Not authenticated');
    }
    final userId = int.parse(token
        .split('_')
        .last);
    final name = prefs.getString('user_${userId}_name') ?? 'User';
    final email = prefs.getString('user_${userId}_email') ?? '';
    _currentUser = User(id: userId, name: name, email: email);
    return _currentUser!;
  }


  Future<User> updateUserProfile(String name, String email,
      {String? avatarPath}) async {
    final user = await getCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    await prefs.setString('user_${user.id}_name', name.trim());
    await prefs.setString('user_${user.id}_email', normalizedEmail);
    if (user.email != normalizedEmail) {
      final oldPass = prefs.getString('pass_${user.email}');
      if (oldPass != null) {
        await prefs.setString('pass_$normalizedEmail', oldPass);
        await prefs.remove('pass_${user.email}');
      }
    }
    final updatedUser = User(id: user.id,
        name: name.trim(),
        email: normalizedEmail,
        avatar: avatarPath);
    _currentUser = updatedUser;
    return updatedUser;
  }

  Future<void> applyToJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> applied = prefs.getStringList('applied_jobs') ?? [];
    if (!applied.contains(jobId)) {
      applied.add(jobId);
      await prefs.setStringList('applied_jobs', applied);
    }
  }

  Future<List<Job>> getAppliedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final appliedIds = prefs.getStringList('applied_jobs') ?? [];
    final allJobs = await _createMockJobs();
    return allJobs.where((job) => appliedIds.contains(job.id)).toList();
  }

  Future<List<Map<String, dynamic>>> getJobAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getStringList('job_alerts') ?? [];
    return alertsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> createJobAlert(String keyword, String? location) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getJobAlerts();
    final newAlert = {
      'id': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      'keyword': keyword.trim(),
      'location': location?.trim(),
      'created_at': DateTime.now().toIso8601String(),
    };
    alerts.add(newAlert);
    final alertsJson = alerts.map((alert) => jsonEncode(alert)).toList();
    await prefs.setStringList('job_alerts', alertsJson);
  }

  Future<void> deleteJobAlert(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> alerts = await getJobAlerts();
    alerts.removeWhere((alert) => alert['id'] == alertId);
    final alertsJson = alerts.map((alert) => jsonEncode(alert)).toList();
    await prefs.setStringList('job_alerts', alertsJson);
  }

  Future<void> sendContact(String name, String email, String message) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (name
        .trim()
        .isEmpty || email
        .trim()
        .isEmpty || message
        .trim()
        .isEmpty) {
      throw Exception('All fields are required');
    }
  }

  Future<Map<String, dynamic>> getJobs({
    int page = 1,
    int pageSize = 10,
    String? keyword,
    String? location,
    int? minSalary,
    bool? isRemote,
    String? sortBy, // 'publishedAt' or 'salary'
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    List<Job> mockJobs = await _createMockJobs(); // extract existing mock creation into a method

    if (keyword != null && keyword.isNotEmpty) {
      mockJobs = mockJobs.where((job) =>
      job.title.toLowerCase().contains(keyword.toLowerCase()) ||
          job.companyName.toLowerCase().contains(keyword.toLowerCase())).toList();
    }

    if (location != null && location.isNotEmpty) {
      mockJobs = mockJobs.where((job) =>
          job.location.toLowerCase().contains(location.toLowerCase())).toList();
    }

    if (minSalary != null) {
      mockJobs = mockJobs.where((job) =>
      job.minSalary != null && job.minSalary! >= minSalary).toList();
    }

    if (isRemote == true) {
      mockJobs = mockJobs.where((job) => job.isRemote).toList();
    }

    if (sortBy == 'salary') {
      mockJobs.sort((a, b) {
        final aSal = a.minSalary ?? 0;
        final bSal = b.minSalary ?? 0;
        return bSal.compareTo(aSal);
      });
    } else {
      mockJobs.sort((a, b) => b.publishedAtDate.compareTo(a.publishedAtDate));
    }

    final totalCount = mockJobs.length;
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final paginatedJobs = mockJobs.sublist(start, end > totalCount ? totalCount : end);

    return {
      'jobs': paginatedJobs,
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }

  Future<List<Job>> _createMockJobs() async {
    await Future.delayed(const Duration(seconds: 1));
    List<Job> mockJobs = [
      Job(id: 'job_1',
          title: 'Flutter Developer',
          companyName: 'Novin Tech',
          companySlug: 'novin-tech',
          location: 'Tehran',
          contractType: 'Full-time',
          salaryDisplay: 'Negotiable',
          publishedAt: '2025-03-01',
          isRemote: true,
          minSalary: null,
          maxSalary: null,
          publishedAtDate:DateTime(2025, 3, 1)),
      Job(id: 'job_2',
          title: 'Python Developer',
          companyName: 'Smart Data',
          companySlug: 'smart-data',
          location: 'Isfahan',
          contractType: 'Remote',
          salaryDisplay: '15-20 Million',
          publishedAt: '2025-02-28',
          isRemote: true,
          minSalary: 15,
          maxSalary: 20,
          publishedAtDate:DateTime(2025, 2, 28)),
      Job(id: 'job_3',
          title: 'UI/UX Designer',
          companyName: 'Farda Design',
          companySlug: 'farda-design',
          location: 'Shiraz',
          contractType: 'Part-time',
          salaryDisplay: '8-12 Million',
          publishedAt: '2025-03-03',
          isRemote: false,
          minSalary: 8,
          maxSalary: 12,
          publishedAtDate:DateTime(2025, 3, 3)),
      Job(id: 'job_4',
          title: 'AI Developer',
          companyName: 'MiliGold',
          companySlug: 'miliGold',
          location: 'Tehran',
          contractType: 'Full-time',
          salaryDisplay: 'Negotiable',
          publishedAt: '2025-03-14',
          isRemote: false,
          minSalary: null,
          maxSalary: null,
          publishedAtDate:DateTime(2025, 3, 14)),

      Job(id: 'job_5',
          title: 'Backend Engineer (Node.js)',
          companyName: 'TechHub',
          companySlug: 'techhub',
          location: 'Tehran',
          contractType: 'Full-time',
          salaryDisplay: '25-35 Million',
          publishedAt: '2025-03-10',
          isRemote: false,
          minSalary: 25,
          maxSalary: 35,
          publishedAtDate:DateTime(2025, 3, 1)),
      Job(id: 'job_6',
          title: 'DevOps Engineer',
          companyName: 'Cloudify',
          companySlug: 'cloudify',
          location: 'Mashhad',
          contractType: 'Full-time',
          salaryDisplay: '30-40 Million',
          publishedAt: '2025-03-12',
          isRemote: true,
          minSalary: 30,
          maxSalary: 40,
          publishedAtDate:DateTime(2025, 3, 12)),
      Job(id: 'job_7',
          title: 'Frontend Developer (React)',
          companyName: 'WebArt',
          companySlug: 'webart',
          location: 'Isfahan',
          contractType: 'Full-time',
          salaryDisplay: '20-30 Million',
          publishedAt: '2025-03-05',
          isRemote: false,
          minSalary: 20,
          maxSalary: 30,
          publishedAtDate:DateTime(2025, 3, 5)),
      Job(id: 'job_8',
          title: 'Data Scientist',
          companyName: 'DataMind',
          companySlug: 'datamind',
          location: 'Tehran',
          contractType: 'Full-time',
          salaryDisplay: '40-60 Million',
          publishedAt: '2025-02-25',
          isRemote: true,
          minSalary: 40,
          maxSalary: 60,
          publishedAtDate:DateTime(2025, 2, 25)),
      Job(id: 'job_9',
          title: 'Product Manager',
          companyName: 'Innovatech',
          companySlug: 'innovatech',
          location: 'Shiraz',
          contractType: 'Full-time',
          salaryDisplay: '50-70 Million',
          publishedAt: '2025-03-07',
          isRemote: false,
          minSalary: 50,
          maxSalary: 70,
          publishedAtDate:DateTime(2025, 3, 7)),
      Job(id: 'job_10',
          title: 'QA Engineer',
          companyName: 'QualitySoft',
          companySlug: 'qualitysoft',
          location: 'Karaj',
          contractType: 'Full-time',
          salaryDisplay: '15-22 Million',
          publishedAt: '2025-03-09',
          isRemote: true,
          minSalary: 15,
          maxSalary: 22,
          publishedAtDate:DateTime(2025, 3, 9)),
      Job(id: 'job_11',
          title: 'Mobile Developer (iOS)',
          companyName: 'AppleTech',
          companySlug: 'appletech',
          location: 'Tehran',
          contractType: 'Full-time',
          salaryDisplay: '35-45 Million',
          publishedAt: '2025-02-20',
          isRemote: false,
          minSalary: 35,
          maxSalary: 45,
          publishedAtDate:DateTime(2025, 2, 20)),
      Job(id: 'job_12',
          title: 'Security Analyst',
          companyName: 'SecureNet',
          companySlug: 'securenet',
          location: 'Mashhad',
          contractType: 'Full-time',
          salaryDisplay: '28-38 Million',
          publishedAt: '2025-03-15',
          isRemote: true,
          minSalary: 28,
          maxSalary: 38,
          publishedAtDate:DateTime(2025, 3, 15)),
      Job(id: 'job_13',
          title: 'Project Manager',
          companyName: 'LeadPro',
          companySlug: 'leadpro',
          location: 'Tabriz',
          contractType: 'Full-time',
          salaryDisplay: '45-55 Million',
          publishedAt: '2025-03-11',
          isRemote: false,
          minSalary: 45,
          maxSalary: 55,
          publishedAtDate:DateTime(2025, 3, 11)),
      Job(id: 'job_14',
          title: 'Database Administrator',
          companyName: 'DataCare',
          companySlug: 'datacare',
          location: 'Isfahan',
          contractType: 'Full-time',
          salaryDisplay: '22-32 Million',
          publishedAt: '2025-03-08',
          isRemote: false,
          minSalary: 22,
          maxSalary: 32,
          publishedAtDate:DateTime(2025, 3, 8)),
      Job(id: 'job_15',
          title: 'Scrum Master',
          companyName: 'AgileWorks',
          companySlug: 'agileworks',
          location: 'Tehran',
          contractType: 'Full-time',
          salaryDisplay: '35-45 Million',
          publishedAt: '2025-03-13',
          isRemote: true,
          minSalary: 35,
          maxSalary: 45,
          publishedAtDate:DateTime(2025, 3, 13)),
      Job(id: 'job_16',
          title: 'Machine Learning Engineer',
          companyName: 'DeepThink',
          companySlug: 'deepthink',
          location: 'Shiraz',
          contractType: 'Full-time',
          salaryDisplay: '50-70 Million',
          publishedAt: '2025-02-18',
          isRemote: true,
          minSalary: 50,
          maxSalary: 70,
          publishedAtDate:DateTime(2025, 2, 18)),
      Job(id: 'job_17',
          title: 'Technical Writer',
          companyName: 'DocuMint',
          companySlug: 'documint',
          location: 'Karaj',
          contractType: 'Part-time',
          salaryDisplay: '10-15 Million',
          publishedAt: '2025-03-16',
          isRemote: true,
          minSalary: 10,
          maxSalary: 15,
          publishedAtDate:DateTime(2025, 3, 16)),
      Job(id: 'job_18',
          title: 'Sales Manager',
          companyName: 'MarketLeader',
          companySlug: 'marketleader',
          location: 'Tehran',
          contractType: 'Full-time',
          salaryDisplay: '30-40 Million',
          publishedAt: '2025-03-04',
          isRemote: false,
          minSalary: 30,
          maxSalary: 40,
          publishedAtDate:DateTime(2025, 3, 4)),
      Job(id: 'job_19',
          title: 'Customer Support',
          companyName: 'HelpDesk',
          companySlug: 'helpdesk',
          location: 'Mashhad',
          contractType: 'Part-time',
          salaryDisplay: '8-12 Million',
          publishedAt: '2025-03-17',
          isRemote: true,
          minSalary: 8,
          maxSalary: 12,
          publishedAtDate:DateTime(2025, 3, 17)),
      Job(id: 'job_20',
          title: 'HR Specialist',
          companyName: 'PeopleFirst',
          companySlug: 'peoplefirst',
          location: 'Tabriz',
          contractType: 'Full-time',
          salaryDisplay: '18-25 Million',
          publishedAt: '2025-03-06',
          isRemote: false,
          minSalary: 18,
          maxSalary: 25,
          publishedAtDate:DateTime(2025, 3, 6)),
    ];
    return mockJobs;
  }

  Future<Job> getJobDetail(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final allJobs = await _createMockJobs();
    final job = allJobs.firstWhere((j) => j.id == jobId);
    return Job(
      id: job.id,
      title: job.title,
      companyName: job.companyName,
      companySlug: job.companySlug,
      location: job.location,
      contractType: job.contractType,
      salaryDisplay: job.salaryDisplay,
      publishedAt: job.publishedAt,
      isRemote: job.isRemote,
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      minSalary: job.minSalary,
      maxSalary: job.maxSalary,
      publishedAtDate: job.publishedAtDate
    );
  }

  Future<Company> getCompany(String slug) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final allCompanies = await getCompanies();
    final company = allCompanies.firstWhere((c) => c.slug == slug);
    return Company(
      id: company.id,
      name: company.name,
      slug: company.slug,
      logo: null,
      industry: 'Information Technology',
      website: 'https://example.com',
      description: 'Leading mobile and web development company with 10+ years of experience.',
    );
  }

  Future<List<Job>> getCompanyJobs(String companySlug) async {
    final allJobs = await _createMockJobs();
    return allJobs.where((job) => job.companySlug == companySlug).toList();
  }

  Future<List<Company>> getCompanies() async {
    return [
      Company(id: '1', name: 'Novin Tech', slug: 'novin-tech'),
      Company(id: '2', name: 'Smart Data', slug: 'smart-data'),
      Company(id: '3', name: 'Farda Design', slug: 'farda-design'),
      Company(id: '4', name: 'MiliGold', slug: 'miliGold'),
      Company(id: '5', name: 'TechHub', slug: 'techhub'),
      Company(id: '6', name: 'Cloudify', slug: 'cloudify'),
      Company(id: '7', name: 'WebArt', slug: 'webart'),
      Company(id: '8', name: 'DataMind', slug: 'datamind'),
      Company(id: '9', name: 'Innovatech', slug: 'innovatech'),
      Company(id: '10', name: 'QualitySoft', slug: 'qualitysoft'),
      Company(id: '11', name: 'AppleTech', slug: 'appletech'),
      Company(id: '12', name: 'SecureNet', slug: 'securenet'),
      Company(id: '13', name: 'LeadPro', slug: 'leadpro'),
      Company(id: '14', name: 'DataCare', slug: 'datacare'),
      Company(id: '15', name: 'AgileWorks', slug: 'agileworks'),
      Company(id: '16', name: 'DeepThink', slug: 'deepthink'),
      Company(id: '17', name: 'DocuMint', slug: 'documint'),
      Company(id: '18', name: 'MarketLeader', slug: 'marketleader'),
      Company(id: '19', name: 'HelpDesk', slug: 'helpdesk'),
      Company(id: '20', name: 'PeopleFirst', slug: 'peoplefirst')
    ];
  }

  Future<Resume> getResume(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('resume_${user.id}');
    if (jsonString == null) {
      return Resume(id: user.id.toString());
    }
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return Resume.fromJson(map);
    } catch (e) {
      return Resume(id: user.id.toString());
    }
  }

  Future<void> updateResume(int userId, Resume resume) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(resume.toJson());
    await prefs.setString('resume_$userId', jsonString);
  }
}