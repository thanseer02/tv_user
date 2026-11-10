import 'package:base_project/features/tv_portal/model/tv_portal_item_model.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TvUrlCardWidget extends StatefulWidget {
  final TvPortalItemModel item;
  final bool isSelected;
  final bool autoFocus;
  final VoidCallback onTap;
  final ValueChanged<bool>? onFocusChanged;

  const TvUrlCardWidget({
    super.key,
    required this.item,
    required this.isSelected,
    this.autoFocus = false,
    required this.onTap,
    this.onFocusChanged,
  });

  @override
  State<TvUrlCardWidget> createState() => _TvUrlCardWidgetState();
}

class _TvUrlCardWidgetState extends State<TvUrlCardWidget> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'TvUrlCard_${widget.item.id}');
    _focusNode.addListener(_onFocusNodeChanged);
  }

  void _onFocusNodeChanged() {
    if (mounted && _isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      widget.onFocusChanged?.call(_focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusNodeChanged);
    _focusNode.dispose();
    super.dispose();
  }

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

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autoFocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final logicalKey = event.logicalKey;
          // Android TV D-Pad Center, Enter, Space, NumpadEnter, MediaSelect
          if (logicalKey == LogicalKeyboardKey.select ||
              logicalKey == LogicalKeyboardKey.enter ||
              logicalKey == LogicalKeyboardKey.numpadEnter ||
              logicalKey == LogicalKeyboardKey.gameButtonA ||
              logicalKey == LogicalKeyboardKey.space) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedScale(
        scale: highlighted ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            widget.onTap();
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(24.spMin),
            decoration: BoxDecoration(
              color: highlighted
                  ? brand.primaryBlue.withValues(alpha: 0.28)
                  : brand.bgDarkNavy,
              borderRadius: BorderRadius.circular(20.spMin),
              border: Border.all(
                color: highlighted ? brand.primaryBlue : brand.tuna,
                width: highlighted ? 3.spMin : 1.5.spMin,
              ),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: brand.primaryBlue.withValues(alpha: 0.45),
                        blurRadius: 28.spMin,
                        spreadRadius: 4.spMin,
                        offset: Offset(0, 8.spMin),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 76.spMin,
                  height: 76.spMin,
                  decoration: BoxDecoration(
                    color: highlighted
                        ? brand.primaryBlue
                        : brand.primaryBlue.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18.spMin),
                  ),
                  child: Icon(
                    _getIconData(widget.item.category, widget.item.iconName),
                    size: 40.spMin,
                    color: highlighted ? brand.textWhite : brand.primaryBlue,
                  ),
                ),
                SizedBox(width: 24.spMin),
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
                              style: tsS22W600.copyWith(
                                color: highlighted ? brand.textWhite : brand.textOffWhite,
                              ),
                            ),
                          ),
                          if (widget.item.category != null &&
                              widget.item.category!.isNotEmpty) ...[
                            SizedBox(width: 12.spMin),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.spMin,
                                vertical: 4.spMin,
                              ),
                              decoration: BoxDecoration(
                                color: brand.primaryBlue.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8.spMin),
                              ),
                              child: Text(
                                widget.item.category!,
                                style: tsS14W600.copyWith(color: brand.lightBlue),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.item.displayDescription.isNotEmpty) ...[
                        SizedBox(height: 8.spMin),
                        Text(
                          widget.item.displayDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tsS15W500.copyWith(
                            color: brand.textMediumGray,
                          ),
                        ),
                      ],
                      SizedBox(height: 8.spMin),
                      Text(
                        widget.item.displayUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tsS14W400.copyWith(
                          color: brand.lightBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.spMin),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 24.spMin,
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
