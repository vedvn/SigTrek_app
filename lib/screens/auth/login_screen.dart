import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../core/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  /* ================= EMAIL LOGIN ================= */

  Future<void> _login() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // ✅ Do NOT navigate
      // SplashScreen listens to authStateChanges
    } catch (_) {
      _showError('Login failed. Please check your credentials.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /* ================= GOOGLE LOGIN ================= */

  Future<void> _googleLogin() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await _authService.signInWithGoogle();
    } catch (_) {
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /* ================= PASSWORD RESET ================= */

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email first.');
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      _showMessage('Password reset email sent.');
    } catch (_) {
      _showError('Failed to send password reset email.');
    }
  }

  /* ================= UI HELPERS ================= */

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            // 🔐 Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : _resetPassword,
                child: const Text('Forgot password?'),
              ),
            ),

            const SizedBox(height: 12),
            PrimaryButton(
              text: _loading ? 'Please wait...' : 'Login',
              onPressed: _loading ? null : _login,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: _loading ? 'Please wait...' : 'Continue with Google',
              onPressed: _loading ? null : _googleLogin,
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/register');
                    },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
