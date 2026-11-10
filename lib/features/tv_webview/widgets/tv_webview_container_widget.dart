import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Container widget rendering the WebView.
///
/// On Android, uses Hybrid Composition ([AndroidWebViewWidgetCreationParams.displayWithHybridComposition] = true)
/// to ensure native Android TV remote D-Pad navigation, accessibility focus traversal,
/// and hardware-accelerated media rendering operate seamlessly.
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

        // Build the WebViewWidget with Hybrid Composition enabled on Android.
        final PlatformWebViewWidgetCreationParams params =
            defaultTargetPlatform == TargetPlatform.android
                ? AndroidWebViewWidgetCreationParams(
                    controller: controller.platform,
                    displayWithHybridComposition: true,
                  )
                : PlatformWebViewWidgetCreationParams(
                    controller: controller.platform,
                  );

        final Widget webView = WebViewWidget.fromPlatformCreationParams(
          params: params,
        );

        return Stack(
          children: [
            Positioned.fill(child: webView),
            if (vm.isPageLoading)
              LinearProgressIndicator(
                value: vm.loadingProgress > 0 ? vm.loadingProgress / 100.0 : null,
                backgroundColor: brand.bgDarkNavy,
                valueColor: AlwaysStoppedAnimation<Color>(brand.primaryBlue),
                minHeight: 3.spMin,
              ),
            if (vm.errorMessage != null && !vm.isPageLoading)
              Positioned(
                bottom: 60.spMin,
                left: 30.spMin,
                right: 30.spMin,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.spMin,
                    vertical: 12.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: brand.bgDarkNavy.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12.spMin),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      width: 1.spMin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        size: 24.spMin,
                      ),
                      SizedBox(width: 12.spMin),
                      Expanded(
                        child: Text(
                          'Web Error: ${vm.errorMessage}',
                          style: tsS14W400.copyWith(color: brand.textWhite),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: vm.reload,
                        child: Text(
                          'Retry',
                          style: tsS14W600.copyWith(color: brand.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
