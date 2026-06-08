import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../presenters/profile_presenter.dart';
import '../models/user.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> implements EditProfileView {
  final ProfilePresenter _presenter = ProfilePresenter();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _avatarPath;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter.attachEditView(this);
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _avatarPath = widget.user.avatar;
  }

  @override
  void dispose() {
    _presenter.detachEditView();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _avatarPath = pickedFile.path);
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _presenter.updateProfile(_nameController.text.trim(), _emailController.text.trim(), _avatarPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(radius: 60, backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null, child: _avatarPath == null ? Icon(Icons.camera_alt, size: 40) : null),
              ),
              SizedBox(height: 24),
              CustomTextField(controller: _nameController, label: 'Full Name', validator: Validators.name, prefixIcon: Icons.person_outline),
              SizedBox(height: 16),
              CustomTextField(controller: _emailController, label: 'Email', validator: Validators.email, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
              SizedBox(height: 24),
              if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
              ElevatedButton(onPressed: _save, child: Text('Save Changes'), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
            ],
          ),
        ),
      ),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onProfileUpdated(User user) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green));
    Navigator.pop(context, true);
  }
  @override void onError(String message) => setState(() => _error = message);
}