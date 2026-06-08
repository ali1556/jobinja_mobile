import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements AuthView {
  final AuthPresenter _presenter = AuthPresenter();
  final _formKey = GlobalKey<FormState>();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _presenter.login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.work_outline, size: 80, color: Colors.blue.shade700),
                    SizedBox(height: 16),
                    Text('Jobinja', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade800), textAlign: TextAlign.center),
                    SizedBox(height: 8),
                    Text('Find your dream job', style: TextStyle(fontSize: 16, color: Colors.grey.shade600), textAlign: TextAlign.center),
                    SizedBox(height: 48),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
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
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset not implemented in mock'))),
                        child: Text('Forgot password?', style: TextStyle(color: Colors.blue.shade700)),
                      ),
                    ),
                    SizedBox(height: 24),
                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                        child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700), textAlign: TextAlign.center),
                      ),
                    SizedBox(height: 16),
                    CustomButton(onPressed: _submit, text: 'Login', isLoading: _isLoading),
                    SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen())),
                        child: Text('Sign up', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                      ),
                    ]),
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
  @override void onLoginSuccess(User user, String token) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Welcome ${user.name}!'), backgroundColor: Colors.green));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }
  @override void onSignupSuccess(User user, String token) {}
  @override void onError(String message) => setState(() => _errorMessage = message);
}