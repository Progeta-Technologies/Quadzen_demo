import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/daily_log/daily_log_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/habit_tracker/habit_tracker.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/monthly_log/monthly_log.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/signup_screen/signup_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String onboardingFlow = '/onboarding-flow';
  static const String loginScreen = '/login-screen';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String habitTracker = '/habit-tracker';
  static const String monthlyLog = '/monthly-log';
  static const String dailyLog = '/daily-log';
  static const String authCallback = '/auth-callback';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingFlow(),
    onboardingFlow: (context) => const OnboardingFlow(),
    loginScreen: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    dashboard: (context) => const Dashboard(),
    habitTracker: (context) => const HabitTracker(),
    monthlyLog: (context) => const MonthlyLog(),
    dailyLog: (context) => const DailyLogScreen(),
  };

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const OnboardingFlow(),
      onboardingFlow: (context) => const OnboardingFlow(),
      loginScreen: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      dashboard: (context) => const Dashboard(),
      habitTracker: (context) => const HabitTracker(),
      monthlyLog: (context) => const MonthlyLog(),
      dailyLog: (context) => const DailyLogScreen(),
      authCallback: (context) => const AuthCallbackScreen(),
    };
  }
}

// Auth callback screen for handling OAuth redirects
class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({Key? key}) : super(key: key);

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  void _handleAuthCallback() {
    // Listen for auth state changes after OAuth redirect
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else if (data.event == AuthChangeEvent.signedOut && mounted) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    });

    // Check current auth state
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        }
      });
    } else {
      Future.delayed(Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login-screen');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Completing sign-in...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}