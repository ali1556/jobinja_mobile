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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Poppins', // optional: add Google Fonts package
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[800],
          titleTextStyle: TextStyle(
            color: Colors.blue[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}