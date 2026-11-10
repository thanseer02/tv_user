import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TvWebViewTopBarWidget extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onBack;
  final VoidCallback onReload;

  const TvWebViewTopBarWidget({
    super.key,
    required this.title,
    required this.url,
    required this.onBack,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.spMin,
        vertical: 12.spMin,
      ),
      decoration: BoxDecoration(
        color: brand.bgDarkNavy,
        border: Border(
          bottom: BorderSide(color: brand.tuna, width: 1.spMin),
        ),
      ),
      child: Row(
        children: [
          Focus(
            autofocus: true,
            child: Builder(
              builder: (innerContext) {
                final bool isFocused = Focus.of(innerContext).hasFocus;
                return InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(10.spMin),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.spMin,
                      vertical: 8.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: isFocused
                          ? brand.primaryBlue
                          : brand.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.spMin),
                      border: Border.all(
                        color: isFocused ? brand.primaryBlue : brand.tuna,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 18.spMin,
                          color: isFocused ? brand.textWhite : brand.primaryBlue,
                        ),
                        SizedBox(width: 8.spMin),
                        Text(
                          context.l10n.backToUrls,
                          style: tsS14W600.copyWith(
                            color: isFocused ? brand.textWhite : brand.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 16.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tsS16W600.copyWith(color: brand.textWhite),
                ),
                Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tsS12W400.copyWith(color: brand.textMediumGray),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.spMin),
          Focus(
            child: Builder(
              builder: (innerContext) {
                final bool isFocused = Focus.of(innerContext).hasFocus;
                return InkWell(
                  onTap: onReload,
                  borderRadius: BorderRadius.circular(10.spMin),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.spMin,
                      vertical: 8.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: isFocused
                          ? brand.primaryBlue
                          : brand.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.spMin),
                      border: Border.all(
                        color: isFocused ? brand.primaryBlue : brand.tuna,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 18.spMin,
                          color: isFocused ? brand.textWhite : brand.primaryBlue,
                        ),
                        SizedBox(width: 6.spMin),
                        Text(
                          context.l10n.reload,
                          style: tsS14W600.copyWith(
                            color: isFocused ? brand.textWhite : brand.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 10.spMin),
          Consumer<TvWebViewViewModel>(
            builder: (context, vm, child) {
              if (vm.isPageLoading) {
                return SizedBox(
                  width: 20.spMin,
                  height: 20.spMin,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5.spMin,
                    valueColor: AlwaysStoppedAnimation<Color>(brand.primaryBlue),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
