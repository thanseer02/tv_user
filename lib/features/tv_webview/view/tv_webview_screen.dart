import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:base_project/features/tv_webview/widgets/tv_webview_container_widget.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/extensions.dart';
import 'package:base_project/utils/styles.dart';
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

/// Screen hosting the WebView for TV devices.
///
/// Handles Android TV Remote buttons according to specifications:
/// - D-Pad (Up, Down, Left, Right) and OK/Enter/Select pass through directly to the
///   native Android WebView platform view via [KeyEventResult.ignored] so the browser DOM receives
///   native focus traversal and click events.
/// - Android Back button checks WebView navigation history ([TvWebViewViewModel.canGoBackInHistory])
///   first before exiting the screen.
/// - Volume controls are strictly unhandled to allow system audio regulation.
/// - Play/Pause and Media keys pass through to media elements.
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
    _viewModel.dispose();
    super.dispose();
  }

  /// Handles Back button navigation (both TV remote Back key and OS gestures)
  Future<void> _handleBackPress() async {
    final canGoBack = await _viewModel.canGoBackInHistory();
    debugPrint('[TvWebViewScreen] Back button invoked. canGoBack: $canGoBack');
    if (canGoBack) {
      await _viewModel.goBackInHistory();
    } else {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleBackPress();
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              final key = event.logicalKey;
              debugPrint(
                '[TvWebView Diagnostic] KeyDown: keyLabel="${key.keyLabel}", keyId=0x${key.keyId.toRadixString(16)}',
              );

              // 1. Android Back / Escape / GoBack
              if (key == LogicalKeyboardKey.escape ||
                  key == LogicalKeyboardKey.goBack ||
                  key == LogicalKeyboardKey.backspace) {
                _handleBackPress();
                return KeyEventResult.handled;
              }

              // 2. Volume buttons: MUST NOT be intercepted by Flutter (pass to OS)
              if (key == LogicalKeyboardKey.audioVolumeUp ||
                  key == LogicalKeyboardKey.audioVolumeDown ||
                  key == LogicalKeyboardKey.audioVolumeMute) {
                debugPrint('[TvWebView Diagnostic] Volume key passed to system: ${key.keyLabel}');
                return KeyEventResult.ignored;
              }

              // 3. Media playback buttons (Play/Pause/Stop/FastForward/Rewind)
              // Ignored so they reach the native platform view & web video elements
              if (key == LogicalKeyboardKey.mediaPlay ||
                  key == LogicalKeyboardKey.mediaPause ||
                  key == LogicalKeyboardKey.mediaPlayPause ||
                  key == LogicalKeyboardKey.mediaStop ||
                  key == LogicalKeyboardKey.mediaTrackNext ||
                  key == LogicalKeyboardKey.mediaTrackPrevious ||
                  key == LogicalKeyboardKey.mediaFastForward ||
                  key == LogicalKeyboardKey.mediaRewind) {
                debugPrint('[TvWebView Diagnostic] Media key passed to WebView: ${key.keyLabel}');
                return KeyEventResult.ignored;
              }

              // 4. TV Remote D-Pad (Up, Down, Left, Right) and Select/Enter
              // MUST NOT be intercepted by Flutter with synthetic JS scrolls.
              // Letting them return `KeyEventResult.ignored` delivers real native Android
              // key events to the underlying Hybrid Composition WebView platform view!
              if (key == LogicalKeyboardKey.arrowUp ||
                  key == LogicalKeyboardKey.arrowDown ||
                  key == LogicalKeyboardKey.arrowLeft ||
                  key == LogicalKeyboardKey.arrowRight ||
                  key == LogicalKeyboardKey.select ||
                  key == LogicalKeyboardKey.enter ||
                  key == LogicalKeyboardKey.numpadEnter ||
                  key == LogicalKeyboardKey.gameButtonA) {
                debugPrint('[TvWebView Diagnostic] D-Pad / Action key routed to native WebView: ${key.keyLabel}');
                return KeyEventResult.ignored;
              }
            }

            // All other keys pass through freely
            return KeyEventResult.ignored;
          },
          child: Scaffold(
            backgroundColor: brand.bgDeepNavy,
            body: Stack(
              children: [
                // Fullscreen WebView container
                const Positioned.fill(
                  child: TvWebViewContainerWidget(),
                ),

                // Floating minimal translucent TV overlay button to return to URL list
                Positioned(
                  top: 20.spMin,
                  left: 20.spMin,
                  child: Focus(
                    canRequestFocus: false, // Prevents taking focus away from webview
                    descendantsAreFocusable: false,
                    child: GestureDetector(
                      onTap: _handleBackPress,
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
                              style: tsS14W600.copyWith(color: brand.textWhite),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating bottom helper pill explaining TV Remote controls
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
                          Icons.settings_remote_rounded,
                          size: 18.spMin,
                          color: brand.primaryBlue,
                        ),
                        SizedBox(width: 6.spMin),
                        Text(
                          'D-Pad: Navigate Web Elements • OK: Select • Back: History / Exit',
                          style: tsS12W400.copyWith(color: brand.textMediumGray),
                        ),
                      ],
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
