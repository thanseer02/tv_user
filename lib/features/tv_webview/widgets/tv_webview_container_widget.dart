import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TvWebViewContainerWidget extends StatelessWidget {
  const TvWebViewContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Consumer<TvWebViewViewModel>(
      builder: (context, vm, child) {
        final controller = vm.webViewController;
        if (controller == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(brand.primaryBlue),
                ),
                SizedBox(height: 14.spMin),
                Text(
                  context.l10n.webViewLoading,
                  style: tsS14W400.copyWith(color: brand.textMediumGray),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            WebViewWidget(controller: controller),
            if (vm.isPageLoading)
              LinearProgressIndicator(
                value: vm.loadingProgress > 0 ? vm.loadingProgress / 100.0 : null,
                backgroundColor: brand.bgDarkNavy,
                valueColor: AlwaysStoppedAnimation<Color>(brand.primaryBlue),
                minHeight: 3.spMin,
              ),
          ],
        );
      },
    );
  }
}
