import 'package:flutter/material.dart';
import 'views/login_screen.dart';

void main() {
  runApp(JobinjaApp());
}

class JobinjaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobinja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}