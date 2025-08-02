import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import './widgets/signup_form_widget.dart';
import './widgets/social_login_button_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    AuthService().authStateChanges.listen((data) {
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

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Full name is required';
      } else if (value.length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else {
        _nameError = null;
      }
    });
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
      } else if (value.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]')
          .hasMatch(value)) {
        _passwordError =
            'Password must contain uppercase, lowercase, number, and special character';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Confirm password is required';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isFormValid() {
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _signUp() async {
    if (!_isFormValid()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim());

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

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final success = await AuthService().signInWithGoogle();

      if (success && kIsWeb) {
        // For web, the OAuth redirect handles navigation
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

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, '/login-screen');
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
                      SizedBox(height: 6.h),

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

                      SizedBox(height: 4.h),

                      // Welcome Text
                      Text('Create Account',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface)),

                      SizedBox(height: 1.h),

                      Text('Join Quadzen and start your productivity journey',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight),
                          textAlign: TextAlign.center),

                      SizedBox(height: 4.h),

                      // SignUp Form
                      SignUpFormWidget(
                          formKey: _formKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          isPasswordVisible: _isPasswordVisible,
                          isConfirmPasswordVisible: _isConfirmPasswordVisible,
                          nameError: _nameError,
                          emailError: _emailError,
                          passwordError: _passwordError,
                          confirmPasswordError: _confirmPasswordError,
                          onNameChanged: _validateName,
                          onEmailChanged: _validateEmail,
                          onPasswordChanged: _validatePassword,
                          onConfirmPasswordChanged: _validateConfirmPassword,
                          onTogglePasswordVisibility: _togglePasswordVisibility,
                          onToggleConfirmPasswordVisibility:
                              _toggleConfirmPasswordVisibility),

                      SizedBox(height: 4.h),

                      // Sign Up Button
                      SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                              onPressed: _isFormValid() && !_isLoading
                                  ? _signUp
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
                                  : Text('Create Account', style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onPrimary, fontWeight: FontWeight.w600)))),

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
                                  debugPrint('Google signup successful');
                                },
                                onError: (error) {
                                  debugPrint('Google signup error: $error');
                                })),
                        SizedBox(width: 4.w),
                        Expanded(
                            child: SocialLoginButtonWidget(
                                iconPath: '', provider: 'Apple')),
                      ]),

                      SizedBox(height: 6.h),

                      // Sign In Link
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                        color:
                                            AppTheme.textMediumEmphasisLight)),
                            GestureDetector(
                                onTap: _navigateToSignIn,
                                child: Text('Sign In',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            fontWeight: FontWeight.w600))),
                          ]),

                      SizedBox(height: 4.h),
                    ]))));
  }
}