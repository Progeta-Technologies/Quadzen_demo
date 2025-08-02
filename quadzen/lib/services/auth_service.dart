import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<SupabaseClient> get _client async => await SupabaseService.client;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final client = await _client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'student'},
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final client = await _client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    try {
      final client = await _client;

      // For web-based OAuth, we need to handle the redirect flow properly
      final result = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/#/auth-callback'
            : 'io.supabase.quadzen://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      return result;
    } catch (error) {
      // Improved error handling for common OAuth issues
      String errorMessage = error.toString();

      if (errorMessage.contains('popup_closed') ||
          errorMessage.contains('access_denied')) {
        throw Exception('Google sign-in was cancelled by user');
      } else if (errorMessage.contains('network_error') ||
          errorMessage.contains('timeout')) {
        throw Exception(
            'Network error during Google sign-in. Please check your connection');
      } else if (errorMessage.contains('invalid_request') ||
          errorMessage.contains('unauthorized_client')) {
        throw Exception('Google authentication is not properly configured');
      } else {
        throw Exception('Google sign-in failed. Please try again');
      }
    }
  }

  /// Check if Google OAuth provider is enabled
  Future<bool> _isGoogleProviderEnabled() async {
    try {
      final client = await _client;
      // This is a basic check - in a real implementation, you might want to
      // make a test call or check configuration
      return true; // Assume enabled unless we get an error
    } catch (error) {
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      final client = await _client;
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (error) {
      return null;
    }
  }

  /// Check if user is signed in
  bool get isSignedIn => getCurrentUser() != null;

  /// Get current user ID
  String? get currentUserId {
    final user = getCurrentUser();
    return user?.id;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  /// Get current session
  Session? getCurrentSession() {
    try {
      return Supabase.instance.client.auth.currentSession;
    } catch (error) {
      return null;
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      final client = await _client;
      await client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final client = await _client;
      Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      return await client.auth.updateUser(
        UserAttributes(data: data),
      );
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }
}