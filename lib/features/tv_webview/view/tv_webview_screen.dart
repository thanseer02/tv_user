import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:base_project/features/tv_webview/widgets/tv_webview_container_widget.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TvWebViewScreenParams {
  final String title;
  final String url;

  const TvWebViewScreenParams({
    required this.title,
    required this.url,
  });
}

class TvWebViewScreen extends StatefulWidget {
  static const String routeName = '/tv_webview_screen';

  final TvWebViewScreenParams? params;

  const TvWebViewScreen({super.key, this.params});

  @override
  State<TvWebViewScreen> createState() => _TvWebViewScreenState();
}

class _TvWebViewScreenState extends State<TvWebViewScreen> {
  late final TvWebViewViewModel _viewModel;
  late final TvWebViewScreenParams _params;

  @override
  void initState() {
    super.initState();
    _viewModel = TvWebViewViewModel();

    // Enable true full-screen mode on native platforms (Android TV)
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final retrievedParams =
        widget.params ?? context.getScreenParamsOf<TvWebViewScreenParams>();
    _params = retrievedParams ??
        const TvWebViewScreenParams(
          title: '',
          url: '',
        );

    _viewModel.initializeController(_params.url);
  }

  @override
  void dispose() {
    // Restore edge-to-edge / system overlays when leaving the full-screen webview
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
          LogicalKeySet(LogicalKeyboardKey.backspace): const DismissIntent(),
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) => Navigator.of(context).maybePop(),
            ),
          },
          child: Scaffold(
            backgroundColor: brand.bgDeepNavy,
            body: Stack(
              children: [
                // Edge-to-edge full screen webview
                const Positioned.fill(
                  child: TvWebViewContainerWidget(),
                ),

                // Floating minimal translucent TV overlay button to return to URL list
                Positioned(
                  top: 16.spMin,
                  left: 16.spMin,
                  child: FocusableActionDetector(
                    autofocus: false,
                    actions: <Type, Action<Intent>>{
                      ActivateIntent: CallbackAction<ActivateIntent>(
                        onInvoke: (intent) {
                          Navigator.of(context).maybePop();
                          return null;
                        },
                      ),
                    },
                    child: Builder(
                      builder: (detectorContext) {
                        return GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.spMin,
                              vertical: 8.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: brand.bgDarkNavy.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(24.spMin),
                              border: Border.all(
                                color: brand.primaryBlue.withValues(alpha: 0.6),
                                width: 1.5.spMin,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 10.spMin,
                                  offset: Offset(0, 4.spMin),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18.spMin,
                                  color: brand.textWhite,
                                ),
                                SizedBox(width: 8.spMin),
                                Text(
                                  _params.title.isNotEmpty
                                      ? _params.title
                                      : 'Back',
                                  style: TextStyle(
                                    fontSize: 13.spMin,
                                    color: brand.textWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
