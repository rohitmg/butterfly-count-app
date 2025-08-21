import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // NEW: For Google icon
import '../../data/auth/auth_service.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart'; // NEW: Import your SnackBarHelper

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthService _authService;
  bool _isLoading = false; // NEW: To manage loading state during sign-in

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is active for dynamic colors
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors for the gradient background
    final List<Color> gradientColors = isDark
        ? [
            Colors.grey[850]!,
            Colors.grey[900]!,
          ] // Darker gradient for dark mode
        : [
            Colors.lightBlue[50]!,
            Colors.blue[100]!,
          ]; // Lighter, subtle blue gradient

    return Scaffold(
      body: Container(
        // Apply a subtle gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Allow scrolling if content overflows
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo

                // Welcome Text
                Text(
                  'Welcome to Butterfly Counts!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blue[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Image.asset(
                  'assets/logo.png', // Your app's logo
                  height: 150, // Adjust size as needed
                  width: 150,
                ),
                const SizedBox(height: 64),
                Text(
                  'Log Your Lepidoptera!!!',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Google Sign-In Button
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null // Disable button when loading
                      : () async {
                          setState(() {
                            _isLoading = true; // Set loading state
                          });
                          User? user = await _authService.signInWithGoogle();
                          if (user != null) {
                            if (mounted) {
                              // Use the new helper function
                              SnackBarHelper.showFloatingSnackBar(
                                context,
                                message:
                                    'Signed in as: ${user.displayName ?? user.email}',
                                type: SnackBarType.success, // Use success type
                              );
                            }
                          } else {
                            if (mounted) {
                              // Use the new helper function
                              SnackBarHelper.showFloatingSnackBar(
                                context,
                                message: 'Google Sign-In failed or cancelled.',
                                type: SnackBarType.danger, // Use danger type
                              );
                            }
                          }
                          setState(() {
                            _isLoading = false; // Reset loading state
                          });
                        },
                  icon: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black54,
                            ),
                          ),
                        )
                      : const Icon(
                          FontAwesomeIcons.google,
                          color: Colors.black87,
                        ), // Google icon from Font Awesome
                  label: Text(
                    _isLoading ? 'Signing In...' : 'Sign In with Google',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(280, 55), // Slightly larger button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8, // More prominent shadow
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 20), // Spacing below button
                Text(
                  'By signing in, you agree to our Terms and Privacy Policy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
