import 'dart:ui';

import 'package:base_project/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppProgressWidget extends StatelessWidget {
  const AppProgressWidget({
    super.key,
    this.size,
    this.color,
    this.trackColor,
    this.blurBackground = true,
  });

  final double? size;
  final Color? color;
  final Color? trackColor;
  final bool blurBackground;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    final indicator = SizedBox.square(
      dimension: size ?? 32.spMin,
      child: CircularProgressIndicator(
        color: color ?? colors.colorBlack,
        backgroundColor:
            trackColor ?? colors.colorBlack.withValues(alpha: 0.12),
        strokeWidth: 3.spMin,
        strokeCap: StrokeCap.round,
      ),
    );

    if (!blurBackground) return indicator;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.spMin, sigmaY: 5.spMin),
      child: indicator,
    );
  }
}
