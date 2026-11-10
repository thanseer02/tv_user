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
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      widget.onFocusChanged?.call(_focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'newspaper':
        return Icons.newspaper_rounded;
      case 'flutter':
        return Icons.flutter_dash_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'satellite':
        return Icons.satellite_alt_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'cloud':
        return Icons.cloud_queue_rounded;
      default:
        return Icons.tv_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final bool highlighted = _isFocused || widget.isSelected;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        return KeyEventResult.ignored;
      },
      child: AnimatedScale(
        scale: highlighted ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: InkWell(
          focusNode: _focusNode,
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16.spMin),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(20.spMin),
            decoration: BoxDecoration(
              color: highlighted
                  ? brand.primary.withValues(alpha: 0.22)
                  : brand.surface,
              borderRadius: BorderRadius.circular(16.spMin),
              border: Border.all(
                color: highlighted ? brand.primary : brand.borderSubtle,
                width: highlighted ? 2.5.spMin : 1.spMin,
              ),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: brand.primary.withValues(alpha: 0.35),
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
                        ? brand.primary
                        : brand.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                  child: Icon(
                    _getIconData(widget.item.iconName),
                    size: 28.spMin,
                    color: highlighted ? brand.onPrimary : brand.primary,
                  ),
                ),
                SizedBox(width: 20.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tsS18W600.copyWith(
                          color: highlighted ? brand.primary : brand.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.spMin),
                      Text(
                        widget.item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tsS14W400.copyWith(
                          color: brand.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6.spMin),
                      Text(
                        widget.item.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tsS12W400.copyWith(
                          color: brand.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.spMin),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20.spMin,
                  color: highlighted ? brand.primary : brand.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
