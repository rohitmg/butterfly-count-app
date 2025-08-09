// lib/presentation/screens/LoginPage.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth/auth_service.dart';

// 1. Convert to a StatefulWidget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 2. Declare the AuthService instance.
  // It is now a late final field within the State class.
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    // 3. Initialize the AuthService instance here, which is a non-const context.
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The rest of your widget's UI code remains the same.
      // You can now access `_authService` within this build method.
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome! Please sign in to continue.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  User? user = await _authService.signInWithGoogle();
                  if (user != null) {
                    print('Signed in as: ${user.displayName}');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign-In failed or cancelled.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Image.asset('assets/google_logo.png', height: 24.0),
                label: const Text('Sign In with Google', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(250, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}