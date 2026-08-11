import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);

    try {
      await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await authService.updateDisplayName(_fullNameController.text.trim());

      // Firebase automatically signs the user in upon account creation.
      // Sign back out so they land on Login instead of skipping straight
      // into the app — matches the intended flow (create account, then
      // log in with those credentials).
      await authService.signOut();

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      context.go(AppRoutes.login);
      messenger.showSnackBar(
        const SnackBar(content: Text('Account created! Please log in to continue.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authService.friendlyErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to start shopping',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: subTextColor,
                      ),
                ),
                const SizedBox(height: 32),

                AppTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: Validators.fullName,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
                  ],
                ),
                const SizedBox(height: 20),

                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline),
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),

                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Create a strong password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),

                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: subTextColor),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}