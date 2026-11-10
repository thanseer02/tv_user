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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(16.spMin),
          decoration: BoxDecoration(
            color: brand.primaryBlue.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16.spMin),
            border: Border.all(
              color: brand.primaryBlue.withValues(alpha: 0.3),
              width: 1.5.spMin,
            ),
          ),
          child: Icon(
            Icons.tv_rounded,
            size: 38.spMin,
            color: brand.primaryBlue,
          ),
        ),
        SizedBox(width: 20.spMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.appTitle,
                    style: tsS16W600.copyWith(color: brand.primaryBlue),
                  ),
                  SizedBox(width: 10.spMin),
                  Container(
                    width: 6.spMin,
                    height: 6.spMin,
                    decoration: BoxDecoration(
                      color: brand.primaryBlue.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.spMin),
                  Text(
                    subtitle,
                    style: tsS15W500.copyWith(color: brand.textMediumGray),
                  ),
                ],
              ),
              SizedBox(height: 6.spMin),
              Text(
                title,
                style: tsS28W600.copyWith(
                  color: brand.textWhite,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
