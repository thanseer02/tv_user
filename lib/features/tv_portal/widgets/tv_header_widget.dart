import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TvHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const TvHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.spMin),
              decoration: BoxDecoration(
                color: brand.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                Icons.tv_rounded,
                size: 26.spMin,
                color: brand.primary,
              ),
            ),
            SizedBox(width: 14.spMin),
            Text(
              context.l10n.appTitle,
              style: tsS16W600.copyWith(color: brand.primary),
            ),
          ],
        ),
        SizedBox(height: 12.spMin),
        Text(
          title,
          style: tsS22W600.copyWith(color: brand.textPrimary),
        ),
        SizedBox(height: 6.spMin),
        Text(
          subtitle,
          style: tsS14W400.copyWith(color: brand.textSecondary),
        ),
      ],
    );
  }
}
