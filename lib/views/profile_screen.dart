import 'package:flutter/material.dart';
import '../presenters/profile_presenter.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'applied_jobs_screen.dart';
import 'job_alerts_screen.dart';
import 'contact_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView {
  final ProfilePresenter _presenter = ProfilePresenter();
  User? _user;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    _presenter.loadUserProfile();
  }

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }

  void _logout() => _presenter.logout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.red)))
            : _user == null
            ? Center(child: Text('No user data'))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(radius: 60, backgroundColor: Colors.blue.shade100, child: Icon(Icons.person, size: 60, color: Colors.blue.shade700)),
              SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(leading: Icon(Icons.person_outline, color: Colors.blue.shade700), title: Text('Name'), subtitle: Text(_user!.name)),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(leading: Icon(Icons.email_outlined, color: Colors.blue.shade700), title: Text('Email'), subtitle: Text(_user!.email)),
              ),
              SizedBox(height: 24),
              // Edit Profile
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)));
                  if (result == true) _presenter.loadUserProfile();
                },
                icon: Icon(Icons.edit),
                label: Text('Edit Profile'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
              SizedBox(height: 12),
              // Applied Jobs
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppliedJobsScreen())),
                icon: Icon(Icons.list_alt),
                label: Text('Applied Jobs'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
              SizedBox(height: 12),
              // Job Alerts
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobAlertsScreen())),
                icon: Icon(Icons.notifications_active),
                label: Text('Job Alerts'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
              SizedBox(height: 12),
              // Contact Us
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactScreen())),
                icon: Icon(Icons.contact_mail),
                label: Text('Contact Us'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onProfileLoaded(User user) => setState(() { _user = user; _error = null; });
  @override void onLogoutSuccess() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
  @override void onError(String message) => setState(() => _error = message);
}