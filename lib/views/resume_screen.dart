// views/resume_screen.dart
import 'package:flutter/material.dart';
import '../presenters/resume_presenter.dart';
import '../models/user.dart';
import '../models/resume.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class ResumeScreen extends StatefulWidget {
  final User user;
  const ResumeScreen({required this.user});

  @override
  _ResumeScreenState createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> implements ResumeView {
  final ResumePresenter _presenter = ResumePresenter();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _aboutController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
    _aboutController = TextEditingController();
    _phoneController = TextEditingController();
    _presenter.loadResume(widget.user);
  }

  @override
  void dispose() {
    _presenter.detachView();
    _aboutController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _presenter.updateResume(
        widget.user.id,
        _aboutController.text.trim().isEmpty ? null : _aboutController.text.trim(),
        _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Resume'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Phone number field
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      SizedBox(height: 16),
                      // About / Bio field
                      TextFormField(
                        controller: _aboutController,
                        decoration: InputDecoration(
                          labelText: 'About me',
                          hintText: 'Tell us about yourself, skills, experience...',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 8,
                        validator: (value) => null, // optional
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              CustomButton(
                onPressed: _save,
                text: 'Save Resume',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ResumeView implementation
  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);
  @override
  void onResumeLoaded(Resume resume) {
    setState(() {
      _aboutController.text = resume.about ?? '';
      _phoneController.text = resume.phoneNumber ?? '';
      _error = null;
    });
  }
  @override
  void onResumeUpdated() {
    setState(() {
      _successMessage = 'Resume saved successfully!';
      _error = null;
    });
    // Optional: hide success message after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }
  @override
  void onError(String message) => setState(() => _error = message);
}