import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_button_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    _authService.authStateChanges.listen((data) {
      if (data.event == 'signedIn' && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isValidEmail(value)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  bool _isFormValid() {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _signIn() async {
    if (!_isFormValid()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text);

      // Navigation handled by auth state listener
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''),
                style:
                    TextStyle(color: AppTheme.lightTheme.colorScheme.onError)),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(4.w)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Password reset link sent to your email'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w)));
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final success = await _authService.signInWithGoogle();

      if (success && kIsWeb) {
        // For web, the OAuth redirect handles navigation
        // Show a success message while waiting for redirect
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Redirecting to Google Sign-In...'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(4.w)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: AppTheme.lightTheme.colorScheme.onError,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _signInWithApple() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Apple Sign-In coming soon'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w)));
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),

                      // Quadzen Logo
                      Container(
                          width: 40.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(16)),
                          child: Center(
                              child: Text('Quadzen',
                                  style: AppTheme
                                      .lightTheme.textTheme.headlineMedium
                                      ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold)))),

                      SizedBox(height: 6.h),

                      // Welcome Text
                      Text('Welcome Back',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface)),

                      SizedBox(height: 1.h),

                      Text('Sign in to continue your productivity journey',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight),
                          textAlign: TextAlign.center),

                      SizedBox(height: 4.h),

                      // Login Form
                      LoginFormWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          emailError: _emailError,
                          passwordError: _passwordError,
                          onEmailChanged: _validateEmail,
                          onPasswordChanged: _validatePassword,
                          onTogglePasswordVisibility: _togglePasswordVisibility,
                          onForgotPassword: _forgotPassword),

                      SizedBox(height: 4.h),

                      // Sign In Button
                      SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                              onPressed: _isFormValid() && !_isLoading
                                  ? _signIn
                                  : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid() && !_isLoading
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.textDisabledLight,
                                  foregroundColor:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 5.w,
                                      height: 5.w,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              AppTheme.lightTheme.colorScheme
                                                  .onPrimary)))
                                  : Text('Sign In', style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onPrimary, fontWeight: FontWeight.w600)))),

                      SizedBox(height: 4.h),

                      // Divider with "Or continue with"
                      Row(children: [
                        Expanded(
                            child: Divider(
                                color: AppTheme.lightTheme.dividerColor,
                                thickness: 1)),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text('Or continue with',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                        color:
                                            AppTheme.textMediumEmphasisLight))),
                        Expanded(
                            child: Divider(
                                color: AppTheme.lightTheme.dividerColor,
                                thickness: 1)),
                      ]),

                      SizedBox(height: 3.h),

                      // Social Login Buttons
                      Row(children: [
                        Expanded(
                            child: SocialLoginButtonWidget(
                          iconPath:
                              'https://developers.google.com/identity/images/g-logo.png',
                          provider: 'Google',
                          onSuccess: () {
                            // Handle successful Google login
                            debugPrint('Google login successful');
                          },
                          onError: (error) {
                            // Error handling is done within the widget
                            debugPrint('Google login error: $error');
                          },
                        )),
                        SizedBox(width: 4.w),
                        Expanded(
                            child: SocialLoginButtonWidget(
                          iconPath: '',
                          provider: 'Apple',
                        )),
                      ]),

                      SizedBox(height: 6.h),

                      // Sign Up Link
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('New to Quadzen? ',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                        color:
                                            AppTheme.textMediumEmphasisLight)),
                            GestureDetector(
                                onTap: _navigateToSignUp,
                                child: Text('Sign Up',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            fontWeight: FontWeight.w600))),
                          ]),

                      SizedBox(height: 2.h),

                      // Demo credentials info
                      Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Demo Credentials:',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme
                                                .textMediumEmphasisLight)),
                                SizedBox(height: 0.5.h),
                                Text('Email: student@quadzen.com',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                            color: AppTheme
                                                .textMediumEmphasisLight)),
                                Text('Password: QuadZen2024!',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                            color: AppTheme
                                                .textMediumEmphasisLight)),
                              ])),

                      SizedBox(height: 4.h),
                    ]))));
  }
}