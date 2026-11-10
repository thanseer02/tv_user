import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TvWebViewTopBarWidget extends StatefulWidget {
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
  State<TvWebViewTopBarWidget> createState() => _TvWebViewTopBarWidgetState();
}

class _TvWebViewTopBarWidgetState extends State<TvWebViewTopBarWidget> {
  bool _isBackFocused = false;
  bool _isReloadFocused = false;

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
          FocusableActionDetector(
            autofocus: true,
            onFocusChange: (hasKeyboardFocus) {
              if (mounted && _isBackFocused != hasKeyboardFocus) {
                setState(() {
                  _isBackFocused = hasKeyboardFocus;
                });
              }
            },
            onShowFocusHighlight: (hasHighlight) {
              if (mounted && _isBackFocused != hasHighlight) {
                setState(() {
                  _isBackFocused = hasHighlight;
                });
              }
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  widget.onBack();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTap: widget.onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 8.spMin,
                ),
                decoration: BoxDecoration(
                  color: _isBackFocused
                      ? brand.primaryBlue
                      : brand.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.spMin),
                  border: Border.all(
                    color: _isBackFocused ? brand.primaryBlue : brand.tuna,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 18.spMin,
                      color: _isBackFocused ? brand.textWhite : brand.primaryBlue,
                    ),
                    SizedBox(width: 8.spMin),
                    Text(
                      context.l10n.backToUrls,
                      style: tsS14W600.copyWith(
                        color: _isBackFocused ? brand.textWhite : brand.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tsS16W600.copyWith(color: brand.textWhite),
                ),
                Text(
                  widget.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tsS12W400.copyWith(color: brand.textMediumGray),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.spMin),
          FocusableActionDetector(
            onFocusChange: (hasKeyboardFocus) {
              if (mounted && _isReloadFocused != hasKeyboardFocus) {
                setState(() {
                  _isReloadFocused = hasKeyboardFocus;
                });
              }
            },
            onShowFocusHighlight: (hasHighlight) {
              if (mounted && _isReloadFocused != hasHighlight) {
                setState(() {
                  _isReloadFocused = hasHighlight;
                });
              }
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  widget.onReload();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTap: widget.onReload,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.spMin,
                  vertical: 8.spMin,
                ),
                decoration: BoxDecoration(
                  color: _isReloadFocused
                      ? brand.primaryBlue
                      : brand.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.spMin),
                  border: Border.all(
                    color: _isReloadFocused ? brand.primaryBlue : brand.tuna,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 18.spMin,
                      color: _isReloadFocused ? brand.textWhite : brand.primaryBlue,
                    ),
                    SizedBox(width: 6.spMin),
                    Text(
                      context.l10n.reload,
                      style: tsS14W600.copyWith(
                        color: _isReloadFocused ? brand.textWhite : brand.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
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
