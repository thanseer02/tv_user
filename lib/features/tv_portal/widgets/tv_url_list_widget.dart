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
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(brand.primary),
            ),
          );
        }

        if (vm.urlList.isEmpty) {
          return Center(
            child: Text(
              context.l10n.emptyUrlList,
              style: tsS16W500.copyWith(color: brand.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8.spMin),
          itemCount: vm.urlList.length,
          separatorBuilder: (_, __) => SizedBox(height: 14.spMin),
          itemBuilder: (context, index) {
            final item = vm.urlList[index];
            final bool isSelected = vm.focusedIndex == index;

            return TvUrlCardWidget(
              item: item,
              isSelected: isSelected,
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
                    title: item.title,
                    url: item.url,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
