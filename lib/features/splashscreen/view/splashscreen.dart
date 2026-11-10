import 'dart:async';
import 'package:base_project/features/tv_portal/view/tv_url_listing_screen.dart';
import 'package:base_project/providers/theme_provider.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().applySavedTheme(context);
    });

    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(TvUrlListingScreen.routeName);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Scaffold(
      backgroundColor: brand.bgDeepNavy,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 110.spMin,
                  height: 110.spMin,
                  decoration: BoxDecoration(
                    color: brand.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: brand.primaryBlue.withValues(alpha: 0.45),
                        blurRadius: 30.spMin,
                        spreadRadius: 4.spMin,
                        offset: Offset(0, 8.spMin),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tv_rounded,
                    size: 60.spMin,
                    color: brand.textWhite,
                  ),
                ),
              ),
              SizedBox(height: 28.spMin),
              Text(
                context.l10n.appTitle,
                style: tsS22W600.copyWith(
                  color: brand.textWhite,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10.spMin),
              Text(
                context.l10n.splashLoading,
                style: tsS14W400.copyWith(
                  color: brand.textLightGray,
                ),
              ),
              SizedBox(height: 36.spMin),
              SizedBox(
                width: 32.spMin,
                height: 32.spMin,
                child: CircularProgressIndicator(
                  strokeWidth: 3.spMin,
                  valueColor: AlwaysStoppedAnimation<Color>(brand.primaryBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
