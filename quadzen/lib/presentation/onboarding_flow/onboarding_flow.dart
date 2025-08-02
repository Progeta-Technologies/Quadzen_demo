import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isAutoAdvancing = true;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Digital Bullet Journal",
      "description":
          "Transform your analog bullet journal into a powerful digital productivity system",
      "image":
          "https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "features": [
        {"icon": "circle", "text": "Tasks", "symbol": "•"},
        {"icon": "radio_button_unchecked", "text": "Events", "symbol": "O"},
        {"icon": "remove", "text": "Notes", "symbol": "–"},
      ]
    },
    {
      "title": "Habit Tracking Made Simple",
      "description":
          "Build lasting habits with visual tracking and streak rewards",
      "image":
          "https://images.pexels.com/photos/6147094/pexels-photo-6147094.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "habits": [
        {"name": "Morning Exercise", "streak": 7, "completed": true},
        {"name": "Read 30 mins", "streak": 12, "completed": true},
        {"name": "Drink 8 glasses", "streak": 3, "completed": false},
        {"name": "Meditate", "streak": 5, "completed": true},
      ]
    },
    {
      "title": "Mood & Wellness Tracking",
      "description":
          "Monitor your mental wellness with intuitive mood tracking and insights",
      "image":
          "https://images.pixabay.com/photo/2017/05/25/21/33/tree-2343163_1280.jpg",
      "moods": [
        {"emoji": "😊", "label": "Happy", "color": 0xFF4CAF50},
        {"emoji": "😐", "label": "Neutral", "color": 0xFFFFC107},
        {"emoji": "😔", "label": "Sad", "color": 0xFF2196F3},
        {"emoji": "😤", "label": "Stressed", "color": 0xFFFF5722},
        {"emoji": "😴", "label": "Tired", "color": 0xFF9C27B0},
      ]
    },
    {
      "title": "Academic Planning Hub",
      "description":
          "Organize your academic life with course management and grade tracking",
      "image":
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "courses": [
        {"name": "Computer Science", "grade": "A", "assignments": 3},
        {"name": "Mathematics", "grade": "B+", "assignments": 2},
        {"name": "Physics", "grade": "A-", "assignments": 1},
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    if (!_isAutoAdvancing) return;

    _animationController.reset();
    _animationController.forward().then((_) {
      if (_isAutoAdvancing && mounted) {
        _nextPage();
      }
    });
  }

  void _stopAutoAdvance() {
    setState(() {
      _isAutoAdvancing = false;
    });
    _animationController.stop();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    if (_isAutoAdvancing) {
      _startAutoAdvance();
    }

    // Haptic feedback for iOS
    HapticFeedback.selectionClick();
  }

  void _onUserInteraction() {
    _stopAutoAdvance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: _onUserInteraction,
          onPanStart: (_) => _onUserInteraction(),
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      data: _onboardingData[index],
                      pageIndex: index,
                      onInteraction: _onUserInteraction,
                    );
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _currentPage > 0 ? _previousPage : null,
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: _currentPage > 0
                  ? CustomIconWidget(
                      iconName: 'arrow_back_ios',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    )
                  : SizedBox(width: 6.w),
            ),
          ),
          if (_isAutoAdvancing)
            SizedBox(
              width: 20.w,
              height: 0.5.h,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  );
                },
              ),
            )
          else
            SizedBox(width: 20.w),
          GestureDetector(
            onTap: _skipOnboarding,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              child: Text(
                'Skip',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PageIndicatorWidget(
            currentPage: _currentPage,
            totalPages: _onboardingData.length,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: _currentPage == _onboardingData.length - 1
                    ? ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor:
                              AppTheme.lightTheme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: _nextPage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          side: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName: 'arrow_forward',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
