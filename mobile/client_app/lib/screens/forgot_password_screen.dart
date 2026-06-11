import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _error;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }
    if (Validators.email(email) != null) {
      setState(() => _error = Validators.email(email));
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _authService.forgotPassword(email);

    setState(() {
      _isLoading = false;
      if (result.success) {
        _isSuccess = true;
      } else {
        _error = result.message;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isSuccess ? _buildSuccessMessage() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.lock_reset, size: 64, color: AppTheme.primary),
        const SizedBox(height: 24),
        const Text(
          'Forgot your password?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: AppTheme.error, fontSize: 14),
          ),
        ],
        const SizedBox(height: 24),
        CustomButton(
          label: 'Send Reset Link',
          isLoading: _isLoading,
          onPressed: _sendResetLink,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.check_circle_outline, size: 80, color: AppTheme.success),
        const SizedBox(height: 24),
        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Check your inbox for the password reset link. It may take a few minutes to arrive.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Login'),
          ),
        ),
      ],
    );
  }
}
