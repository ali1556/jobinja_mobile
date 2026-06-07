import 'package:flutter/material.dart';
import '../presenters/profile_presenter.dart';  // this now contains ProfileView
import '../models/user.dart';
import 'login_screen.dart';

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

  void _logout() {
    _presenter.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _user == null
                  ? Center(child: Text('No user data'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                          SizedBox(height: 24),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.person_outline),
                              title: Text('Name'),
                              subtitle: Text(_user!.name),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.email_outlined),
                              title: Text('Email'),
                              subtitle: Text(_user!.email),
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(double.infinity, 48),
                            ),
                            child: Text('Logout', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
    );
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);
  @override
  void onProfileLoaded(User user) => setState(() { _user = user; _error = null; });
  @override
  void onLogoutSuccess() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }
  @override
  void onError(String message) => setState(() => _error = message);
}
