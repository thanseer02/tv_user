import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TvUrlCardWidget extends StatefulWidget {
  final TvPortalItemModel item;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool>? onFocusChanged;

  const TvUrlCardWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.onFocusChanged,
  });

  @override
  State<TvUrlCardWidget> createState() => _TvUrlCardWidgetState();
}

class _TvUrlCardWidgetState extends State<TvUrlCardWidget> {
  bool _isFocused = false;

  IconData _getIconData(String? category, String? iconName) {
    if (iconName != null) {
      switch (iconName) {
        case 'newspaper':
          return Icons.newspaper_rounded;
        case 'public':
          return Icons.public_rounded;
        case 'satellite':
          return Icons.satellite_alt_rounded;
        case 'menu_book':
          return Icons.menu_book_rounded;
        case 'cloud':
          return Icons.cloud_queue_rounded;
      }
    }

    if (category != null) {
      switch (category.toLowerCase()) {
        case 'general':
          return Icons.language_rounded;
        case 'news':
          return Icons.newspaper_rounded;
        case 'media':
        case 'video':
          return Icons.live_tv_rounded;
        case 'dashboard':
          return Icons.dashboard_rounded;
        case 'weather':
          return Icons.cloud_rounded;
      }
    }

    return Icons.tv_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final bool highlighted = _isFocused || widget.isSelected;

    return FocusableActionDetector(
      onShowFocusHighlight: (hasHighlight) {
        if (mounted && _isFocused != hasHighlight) {
          setState(() {
            _isFocused = hasHighlight;
          });
          widget.onFocusChanged?.call(hasHighlight);
        }
      },
      onFocusChange: (hasKeyboardFocus) {
        if (mounted && _isFocused != hasKeyboardFocus) {
          setState(() {
            _isFocused = hasKeyboardFocus;
          });
          widget.onFocusChanged?.call(hasKeyboardFocus);
        }
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: AnimatedScale(
        scale: highlighted ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(20.spMin),
            decoration: BoxDecoration(
              color: highlighted
                  ? brand.primaryBlue.withValues(alpha: 0.22)
                  : brand.bgDarkNavy,
              borderRadius: BorderRadius.circular(16.spMin),
              border: Border.all(
                color: highlighted ? brand.primaryBlue : brand.tuna,
                width: highlighted ? 2.5.spMin : 1.spMin,
              ),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: brand.primaryBlue.withValues(alpha: 0.35),
                        blurRadius: 18.spMin,
                        spreadRadius: 2.spMin,
                        offset: Offset(0, 4.spMin),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 56.spMin,
                  height: 56.spMin,
                  decoration: BoxDecoration(
                    color: highlighted
                        ? brand.primaryBlue
                        : brand.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                  child: Icon(
                    _getIconData(widget.item.category, widget.item.iconName),
                    size: 28.spMin,
                    color: highlighted ? brand.textWhite : brand.primaryBlue,
                  ),
                ),
                SizedBox(width: 20.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tsS18W600.copyWith(
                                color: highlighted ? brand.textWhite : brand.textOffWhite,
                              ),
                            ),
                          ),
                          if (widget.item.category != null &&
                              widget.item.category!.isNotEmpty) ...[
                            SizedBox(width: 8.spMin),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.spMin,
                                vertical: 2.spMin,
                              ),
                              decoration: BoxDecoration(
                                color: brand.primaryBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6.spMin),
                              ),
                              child: Text(
                                widget.item.category!,
                                style: tsS12W400.copyWith(color: brand.lightBlue),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.item.displayDescription.isNotEmpty) ...[
                        SizedBox(height: 6.spMin),
                        Text(
                          widget.item.displayDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tsS14W400.copyWith(
                            color: brand.textMediumGray,
                          ),
                        ),
                      ],
                      SizedBox(height: 6.spMin),
                      Text(
                        widget.item.displayUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tsS12W400.copyWith(
                          color: brand.lightBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.spMin),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20.spMin,
                  color: highlighted ? brand.primaryBlue : brand.textSubtleGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
