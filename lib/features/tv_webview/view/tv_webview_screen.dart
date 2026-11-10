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
  final FocusNode _remoteFocusNode = FocusNode(debugLabel: 'TvWebViewRemoteControl');

  @override
  void initState() {
    super.initState();
    _viewModel = TvWebViewViewModel();

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
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _remoteFocusNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Focus(
        focusNode: _remoteFocusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final key = event.logicalKey;

            // Remote Back / Esc / Backspace
            if (key == LogicalKeyboardKey.escape ||
                key == LogicalKeyboardKey.backspace ||
                key == LogicalKeyboardKey.goBack) {
              Navigator.of(context).maybePop();
              return KeyEventResult.handled;
            }

            // D-Pad Up: Scroll page up
            if (key == LogicalKeyboardKey.arrowUp) {
              _viewModel.scrollUp();
              return KeyEventResult.handled;
            }

            // D-Pad Down: Scroll page down
            if (key == LogicalKeyboardKey.arrowDown) {
              _viewModel.scrollDown();
              return KeyEventResult.handled;
            }

            // D-Pad Left: Scroll page left
            if (key == LogicalKeyboardKey.arrowLeft) {
              _viewModel.scrollLeft();
              return KeyEventResult.handled;
            }

            // D-Pad Right: Scroll page right
            if (key == LogicalKeyboardKey.arrowRight) {
              _viewModel.scrollRight();
              return KeyEventResult.handled;
            }

            // D-Pad Center / Enter / Select: Trigger action on focused element
            if (key == LogicalKeyboardKey.select ||
                key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.numpadEnter ||
                key == LogicalKeyboardKey.gameButtonA) {
              _viewModel.simulateClick();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
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
                top: 20.spMin,
                left: 20.spMin,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.spMin,
                      vertical: 10.spMin,
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
                          size: 20.spMin,
                          color: brand.textWhite,
                        ),
                        SizedBox(width: 8.spMin),
                        Text(
                          _params.title.isNotEmpty ? _params.title : 'Back',
                          style: TextStyle(
                            fontSize: 14.spMin,
                            color: brand.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating bottom helper pill showing D-Pad remote controls
              Positioned(
                bottom: 16.spMin,
                right: 20.spMin,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.spMin,
                    vertical: 8.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: brand.bgDarkNavy.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20.spMin),
                    border: Border.all(color: brand.tuna, width: 1.spMin),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_vert_rounded,
                        size: 18.spMin,
                        color: brand.primaryBlue,
                      ),
                      SizedBox(width: 6.spMin),
                      Text(
                        'D-Pad: Scroll Up / Down • Center: Select • Back: Exit',
                        style: TextStyle(
                          fontSize: 12.spMin,
                          color: brand.textMediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
