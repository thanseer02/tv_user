import 'package:base_project/features/tv_portal/view_model/tv_portal_view_model.dart';
import 'package:base_project/features/tv_portal/widgets/tv_url_card_widget.dart';
import 'package:base_project/features/tv_webview/view/tv_webview_screen.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TvUrlListWidget extends StatelessWidget {
  const TvUrlListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Consumer<TvPortalViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.urlList.isEmpty) {
          return Center(
            child: SizedBox(
              width: 48.spMin,
              height: 48.spMin,
              child: CircularProgressIndicator(
                strokeWidth: 4.spMin,
                valueColor: AlwaysStoppedAnimation<Color>(brand.primaryBlue),
              ),
            ),
          );
        }

        if (vm.urlList.isEmpty) {
          return Center(
            child: Text(
              context.l10n.emptyUrlList,
              style: tsS18W600.copyWith(color: brand.textMediumGray),
            ),
          );
        }

        // TV 16:9 widescreen layout: Responsive multi-column grid
        return LayoutBuilder(
          builder: (context, constraints) {
            // Compute columns based on TV width: 3 columns for 1080p/4k TVs, 2 for mid screens
            final int crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;

            return FocusTraversalGroup(
              policy: ReadingOrderTraversalPolicy(),
              child: GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.spMin,
                  vertical: 16.spMin,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24.spMin,
                  mainAxisSpacing: 24.spMin,
                  childAspectRatio: 2.2,
                ),
                itemCount: vm.urlList.length,
                itemBuilder: (context, index) {
                  final item = vm.urlList[index];
                  final bool isSelected = vm.focusedIndex == index;

                  return TvUrlCardWidget(
                    item: item,
                    isSelected: isSelected,
                    autoFocus: index == 0,
                    onFocusChanged: (hasFocus) {
                      if (hasFocus) {
                        context.read<TvPortalViewModel>().setFocusedIndex(index);
                      }
                    },
                    onTap: () {
                      context.read<TvPortalViewModel>().setFocusedIndex(index);
                      Navigator.of(context).pushNamed(
                        TvWebViewScreen.routeName,
                        arguments: TvWebViewScreenParams(
                          title: item.displayTitle,
                          url: item.displayUrl,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
