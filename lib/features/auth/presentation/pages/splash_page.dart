import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../widgets/fire_splash_intro.dart';

// مفتاح SharedPreferences — ما يتغير
const _kOnboardingSeen = 'onboarding_seen';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  /// يتحقق من:
  /// 1. هل شاف الـ onboarding قبل؟
  /// 2. هل في مستخدم مسجل دخول؟
  /// لو الاثنين صح → home مباشرة (بدون slides)
  Future<void> _checkAndNavigate() async {
    final user = await FirebaseAuth.instance
        .authStateChanges()
        .first
        .timeout(const Duration(seconds: 3), onTimeout: () => null);

    if (!mounted) return;

    final onboardingSeen = SharedPrefsService.onboardingSeen;

    // خزّن النتيجة — الـ animation هي اللي بتقرر وين تروح
    _navigateAfterAnimation = user != null && onboardingSeen;
  }

  bool _navigateAfterAnimation = false;  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: AnimatedSwitcher(
        duration: AppDurations.slow,
        child: _showIntro
            ? FireSplashIntro(
          key: const ValueKey('fire-intro'),
          onCompleted: () {
            if (!mounted) return;
            if (_navigateAfterAnimation) {
              context.go(RouteNames.home);
            } else {
              setState(() => _showIntro = false);
            }
          },
        )
            : const SafeArea(child: _OnboardingSlides()),
      ),
    );
  }
}

class _OnboardingSection {
  final String title;
  final String body;
  const _OnboardingSection(this.title, this.body);
}

class _OnboardingSlide {
  final IconData icon;
  final List<_OnboardingSection> sections;
  const _OnboardingSlide({required this.icon, required this.sections});
}

class _OnboardingSlides extends StatefulWidget {
  const _OnboardingSlides();

  @override
  State<_OnboardingSlides> createState() => _OnboardingSlidesState();
}

class _OnboardingSlidesState extends State<_OnboardingSlides> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.storefront_outlined,
      sections: [_OnboardingSection(AppStrings.aboutUs, AppStrings.aboutTagline)],
    ),
    _OnboardingSlide(
      icon: Icons.visibility_outlined,
      sections: [_OnboardingSection(AppStrings.ourVision, AppStrings.ourVisionBody)],
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome_outlined,
      sections: [_OnboardingSection(AppStrings.ourMission, AppStrings.ourMissionBody)],
    ),
    _OnboardingSlide(
      icon: Icons.flag_outlined,
      sections: [
        _OnboardingSection(AppStrings.ourGoal, AppStrings.ourGoalBody),
        _OnboardingSection(AppStrings.ourSlogan, AppStrings.ourSloganBody),
      ],
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  /// يحفظ الـ flag ويروح لـ login
  Future<void> _goToAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await SharedPrefsService.setOnboardingSeen();
    if (mounted) context.go(RouteNames.login);
  }

  void _next() {
    if (_isLastPage) {
      _goToAuth();
    } else {
      _pageController.nextPage(duration: AppDurations.normal, curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('onboarding-slides'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            child: TextButton(
              onPressed: _isLastPage ? null : _goToAuth,
              child: Text(
                AppStrings.skip,
                style: AppTextStyles.body.copyWith(
                  color: _isLastPage ? Colors.transparent : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _SlideContent(slide: _slides[index]),
          ),
        ),
        _PageIndicator(count: _slides.length, currentIndex: _currentPage),
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: CustomButton(
            label: _isLastPage ? AppStrings.getStarted : AppStrings.next,
            onPressed: _next,
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}

class _SlideContent extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: AppConstants.iconXxl, color: AppColors.primary),
          const SizedBox(height: AppConstants.spacingXxl),
          for (final section in slide.sections) ...[
            Text(section.title, style: AppTextStyles.heading2, textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              section.body,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (section != slide.sections.last) const SizedBox(height: AppConstants.spacingLg),
          ],
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        );
      }),
    );
  }
}