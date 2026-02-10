import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../core/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // ✅ Do NOT navigate here
      // SplashScreen will route based on auth state
    } catch (e) {
      _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignup() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await _authService.signInWithGoogle();
      // ✅ Same flow as login
    } catch (e) {
      _showError('Google sign-up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
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
            const SizedBox(height: 24),
            PrimaryButton(
              text: _loading ? 'Please wait...' : 'Create Account',
              onPressed: _loading ? null : _register,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: _loading ? 'Please wait...' : 'Sign up with Google',
              onPressed: _loading ? null : _googleSignup,
            ),
          ],
        ),
      ),
    );
  }
}
