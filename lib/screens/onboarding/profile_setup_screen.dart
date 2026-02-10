import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/widgets/primary_button.dart';
import '../../services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final ProfileService _profileService = ProfileService();

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _profileService.markProfileComplete(
      uid: user.uid,
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/emergency-contact');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.length < 10 ? 'Invalid number' : null,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Continue',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
