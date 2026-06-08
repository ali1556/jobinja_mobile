import 'package:flutter/material.dart';
import '../presenters/contact_presenter.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> implements ContactView {
  final ContactPresenter _presenter = ContactPresenter();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _presenter.detachView();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _presenter.sendContact(_nameController.text.trim(), _emailController.text.trim(), _messageController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _nameController, label: 'Your Name', validator: Validators.name, prefixIcon: Icons.person_outline),
              SizedBox(height: 16),
              CustomTextField(controller: _emailController, label: 'Your Email', validator: Validators.email, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
              SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                maxLines: 5,
                validator: (val) => val == null || val.isEmpty ? 'Message is required' : null,
              ),
              SizedBox(height: 24),
              if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
              if (_success != null) Text(_success!, style: TextStyle(color: Colors.green)),
              CustomButton(onPressed: _submit, text: 'Send', isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onContactSent() => setState(() { _success = 'Message sent successfully!'; _error = null; _nameController.clear(); _emailController.clear(); _messageController.clear(); });
  @override void onError(String message) => setState(() => _error = message);
}