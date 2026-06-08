import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/user.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> implements AuthView {
  final AuthPresenter _presenter = AuthPresenter();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
  }

  @override
  void dispose() {
    _presenter.detachView();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _presenter.signup(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 80, color: Colors.blue.shade700),
                    SizedBox(height: 16),
                    Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    SizedBox(height: 32),
                    CustomTextField(controller: _nameController, label: 'Full Name', validator: Validators.name, prefixIcon: Icons.person_outline),
                    SizedBox(height: 16),
                    CustomTextField(controller: _emailController, label: 'Email', validator: Validators.email, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: _obscureText,
                      validator: Validators.password,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
                      onSuffixPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                    SizedBox(height: 24),
                    if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                    CustomButton(onPressed: _submit, text: 'Sign Up', isLoading: _isLoading),
                    SizedBox(height: 16),
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Already have an account? Login')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override void showLoading() => setState(() => _isLoading = true);
  @override void hideLoading() => setState(() => _isLoading = false);
  @override void onLoginSuccess(User user, String token) {}
  @override void onSignupSuccess(User user, String token) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created! Please login')));
    Navigator.pop(context);
  }
  @override void onError(String message) => setState(() => _errorMessage = message);
}