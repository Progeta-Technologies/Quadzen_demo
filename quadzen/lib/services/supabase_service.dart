import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  static Future<void>? _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'your_supabase_url');
  static const String supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'your_supabase_anon_key');

  static Future<void> initialize() async {
    _initFuture ??= _initializeSupabase();
    return _initFuture!;
  }

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    if (supabaseUrl.isEmpty ||
        supabaseAnonKey.isEmpty ||
        supabaseUrl == 'your_supabase_url' ||
        supabaseAnonKey == 'your_supabase_anon_key') {
      debugPrint(
          'Warning: SUPABASE_URL and SUPABASE_ANON_KEY should be defined using --dart-define for production.');
      // For development, we'll still initialize but with placeholder values
    }

    await Supabase.initialize(
      url: supabaseUrl == 'your_supabase_url'
          ? 'https://placeholder.supabase.co'
          : supabaseUrl,
      anonKey: supabaseAnonKey == 'your_supabase_anon_key'
          ? 'placeholder-anon-key'
          : supabaseAnonKey,
    );

    _instance._client = Supabase.instance.client;
    _instance._isInitialized = true;
  }

  // Client getter (async)
  static Future<SupabaseClient> get client async {
    if (!_instance._isInitialized) {
      await initialize();
    }
    return _instance._client;
  }

  // Synchronous client getter (use only after initialization)
  static SupabaseClient get clientSync {
    if (!_instance._isInitialized) {
      throw Exception(
          'SupabaseService not initialized. Call initialize() first.');
    }
    return _instance._client;
  }

  // Auth methods
  static Future<AuthResponse> signUp(String email, String password,
      {String? fullName}) async {
    final client = await SupabaseService.client;
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    final client = await SupabaseService.client;
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  static Future<void> signOut() async {
    final client = await SupabaseService.client;
    try {
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  static Future<bool> signInWithGoogle() async {
    final client = await SupabaseService.client;
    try {
      return await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/#/auth-callback'
            : 'io.supabase.quadzen://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  static User? getCurrentUser() {
    if (!_instance._isInitialized) return null;
    return _instance._client.auth.currentUser;
  }

  static Stream<AuthState> get authStateChanges {
    return _instance._client.auth.onAuthStateChange;
  }
}
