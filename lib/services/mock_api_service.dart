import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/job.dart';
import '../models/company.dart';

class MockApiService {
  List<User> _users = [];
  String? _currentToken;
  User? _currentUser;

  MockApiService() {
    _loadUsersFromStorage();
  }

  Future<void> _loadUsersFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('saved_users') ?? [];
    if (usersJson.isEmpty) {
      _users = [User(id: 1, name: 'Ahmad Rezaei', email: 'ahmad@example.com')];
      await _saveUsersToStorage();
    } else {
      _users = usersJson.map((json) => User.fromJson(jsonDecode(json) as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveUsersToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = _users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList('saved_users', usersJson);
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.any((u) => u.email == email)) {
      throw Exception('Email already exists');
    }
    final newId = _users.isEmpty ? 1 : _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
    final newUser = User(id: newId, name: name, email: email);
    _users.add(newUser);
    await _saveUsersToStorage();

    _currentUser = newUser;
    _currentToken = 'mock_token_$newId';
    await _saveToken(_currentToken!);
    return {'user': newUser, 'token': _currentToken};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Invalid email or password'),
    );
    _currentUser = user;
    _currentToken = 'mock_token_${user.id}';
    await _saveToken(_currentToken!);
    return {'user': user, 'token': _currentToken};
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _currentToken = null;
    await _removeToken();
  }

  Future<List<Job>> getJobs({int page = 1, String? keyword, String? location}) async {
    await Future.delayed(const Duration(seconds: 1));
    List<Job> mockJobs = [
      Job(
        id: 'job_1',
        title: 'Flutter Developer',
        companyName: 'Novin Tech',
        companySlug: 'novin-tech',
        location: 'Tehran',
        contractType: 'Full-time',
        salaryDisplay: 'Negotiable',
        publishedAt: '2025-03-01',
        isRemote: true,
      ),
      Job(
        id: 'job_2',
        title: 'Python Developer',
        companyName: 'Smart Data',
        companySlug: 'smart-data',
        location: 'Isfahan',
        contractType: 'Remote',
        salaryDisplay: '15-20 Million',
        publishedAt: '2025-02-28',
        isRemote: true,
      ),
      Job(
        id: 'job_3',
        title: 'UI/UX Designer',
        companyName: 'Farda Design',
        companySlug: 'farda-design',
        location: 'Shiraz',
        contractType: 'Part-time',
        salaryDisplay: '8-12 Million',
        publishedAt: '2025-03-03',
      ),
    ];

    if (keyword != null && keyword.isNotEmpty) {
      mockJobs = mockJobs.where((job) =>
          job.title.contains(keyword) ||
          job.companyName.contains(keyword)).toList();
    }
    if (location != null && location.isNotEmpty) {
      mockJobs = mockJobs.where((job) => job.location.contains(location)).toList();
    }
    return mockJobs;
  }

  Future<Job> getJobDetail(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final allJobs = await getJobs();
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
    );
  }

  Future<Company> getCompany(String slug) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Company(
      id: 'comp_1',
      name: slug == 'novin-tech' ? 'Novin Tech' : 'Sample Company',
      slug: slug,
      logo: null,
      industry: 'Information Technology',
      website: 'https://example.com',
      description: 'Leading mobile and web development company with 10+ years of experience.',
    );
  }

  Future<List<Job>> getCompanyJobs(String companySlug) async {
    final allJobs = await getJobs();
    return allJobs.where((job) => job.companySlug == companySlug).toList();
  }

  Future<User> getCurrentUser() async {
    if (_currentUser == null) {
      final token = await _getToken();
      if (token != null && token.startsWith('mock_token_')) {
        final userId = int.parse(token.split('_').last);
        _currentUser = _users.firstWhere((u) => u.id == userId);
      } else {
        throw Exception('Not authenticated');
      }
    }
    return _currentUser!;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}