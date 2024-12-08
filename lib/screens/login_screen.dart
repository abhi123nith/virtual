import 'package:flutter/material.dart';
import 'package:virtual/screens/home_screen.dart';
import 'package:virtual/services/db.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper =
      DatabaseHelper(); // Instantiate database helper

  bool _isLogin = true; // Toggle between login and signup

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;

      if (_isLogin) {
        // Login Logic
        final user = await _databaseHelper.getUser(email);
        if (user != null) {
          // Retrieve user_id and email
          int userId = user['id']; // Getting user_id from the result
          print('Login successful for user: ID=$userId, Email=$email');

          // Navigate to HomePage
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomeScreen(
                        userEmail: email,
                      )));
        } else {
          // Show error that email does not exist
          _showErrorDialog('Email not found. Please signup.');
        }
      } else {
        // Signup Logic
        bool exists = await _databaseHelper.userExists(email);
        if (exists) {
          // Show error that email already exists
          _showErrorDialog('Email already exists. Please login.');
        } else {
          await _databaseHelper.insertUser(email);
          // Navigate to HomePage
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => HomeScreen(userEmail: email)));
          print('Sign up with email: $email');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Simple email validation
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; // Toggle between login and signup
                  });
                },
                child: Text(_isLogin
                    ? 'Don\'t have an account? Sign Up'
                    : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
