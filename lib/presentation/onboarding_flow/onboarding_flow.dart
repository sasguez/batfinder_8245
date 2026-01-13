import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import './widgets/onboarding_page_one_widget.dart';
import './widgets/onboarding_page_three_widget.dart';
import './widgets/onboarding_page_two_widget.dart';

/// Onboarding Flow Screen
/// Introduces new users to BatFinder safety features through interactive screens
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
          _isLastPage = page == 2;
        });
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/alert-dashboard');
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_isLastPage) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/alert-dashboard');
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                  ),
                  child: Text(
                    'Saltar',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  OnboardingPageOneWidget(),
                  OnboardingPageTwoWidget(),
                  OnboardingPageThreeWidget(),
                ],
              ),
            ),

            // Page indicator and navigation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      dotHeight: 1.h,
                      dotWidth: 2.w,
                      expansionFactor: 3,
                      spacing: 2.w,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isLastPage ? 'Comenzar' : 'Siguiente',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
