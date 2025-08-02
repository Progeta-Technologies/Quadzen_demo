import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class SocialLoginButtonWidget extends StatefulWidget {
  final String provider;
  final String iconPath;
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const SocialLoginButtonWidget({
    Key? key,
    required this.provider,
    required this.iconPath,
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  State<SocialLoginButtonWidget> createState() =>
      _SocialLoginButtonWidgetState();
}

class _SocialLoginButtonWidgetState extends State<SocialLoginButtonWidget> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleSocialLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      bool success = false;

      switch (widget.provider.toLowerCase()) {
        case 'google':
          success = await _authService.signInWithGoogle();

          if (success) {
            // For web OAuth, the success is handled by redirect
            // For mobile, we listen to auth state changes
            if (!kIsWeb) {
              _setupAuthStateListener();
            }
            widget.onSuccess?.call();
          }
          break;
        default:
          throw Exception(
              '${widget.provider} authentication is not yet supported.');
      }
    } catch (error) {
      String errorMessage = _parseErrorMessage(error.toString());

      widget.onError?.call(errorMessage);

      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange[700],
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupAuthStateListener() {
    _authService.authStateChanges.listen((data) {
      if (data.event == 'signedIn' && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      }
    });
  }

  String _parseErrorMessage(String error) {
    if (error.contains('Google sign-in was cancelled')) {
      return 'Sign-in cancelled. Please try again if you want to continue.';
    } else if (error.contains('Network error')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('not properly configured')) {
      return 'Google Sign-In is currently unavailable. Please use email login instead.';
    } else {
      return 'Unable to sign in with Google. Please try email login or contact support.';
    }
  }

  Widget _buildGoogleIcon() {
    // Use a more reliable Google icon source or fallback to text
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.network(
        'https://developers.google.com/identity/images/g-logo.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.account_circle,
              size: 20,
              color: Colors.grey[600],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.0,
      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleSocialLogin,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.provider.toLowerCase() == 'google') ...[
                    _buildGoogleIcon(),
                    SizedBox(width: 12),
                  ] else ...[
                    Icon(
                      Icons.account_circle,
                      size: 24,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 12),
                  ],
                  Text(
                    'Continue with ${widget.provider}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}