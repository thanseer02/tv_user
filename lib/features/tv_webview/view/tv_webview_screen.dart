import 'package:base_project/features/tv_webview/view_model/tv_webview_view_model.dart';
import 'package:base_project/features/tv_webview/widgets/tv_webview_container_widget.dart';
import 'package:base_project/features/tv_webview/widgets/tv_webview_top_bar_widget.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final retrievedParams =
        widget.params ?? context.getScreenParamsOf<TvWebViewScreenParams>();
    _params = retrievedParams ??
        const TvWebViewScreenParams(
          title: 'Web View',
          url: 'https://flutter.dev',
        );

    _viewModel.initializeController(_params.url);
  }

  @override
  void dispose() {
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
            body: SafeArea(
              child: Column(
                children: [
                  TvWebViewTopBarWidget(
                    title: _params.title,
                    url: _params.url,
                    onBack: () => Navigator.of(context).maybePop(),
                    onReload: () => _viewModel.reload(),
                  ),
                  const Expanded(
                    child: TvWebViewContainerWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
