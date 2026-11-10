import 'package:base_project/features/tv_portal/view_model/tv_portal_view_model.dart';
import 'package:base_project/features/tv_portal/widgets/tv_header_widget.dart';
import 'package:base_project/features/tv_portal/widgets/tv_url_list_widget.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TvUrlListingScreen extends StatefulWidget {
  static const String routeName = '/tv_url_listing_screen';

  const TvUrlListingScreen({super.key});

  @override
  State<TvUrlListingScreen> createState() => _TvUrlListingScreenState();
}

class _TvUrlListingScreenState extends State<TvUrlListingScreen> {
  late final TvPortalViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TvPortalViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadUrls();
    });
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
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
        },
        child: Scaffold(
          backgroundColor: brand.bgDeepNavy,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 48.spMin,
                vertical: 32.spMin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TvHeaderWidget(
                    title: context.l10n.urlListingTitle,
                    subtitle: context.l10n.urlListingSubtitle,
                  ),
                  SizedBox(height: 20.spMin),
                  const Expanded(
                    child: TvUrlListWidget(),
                  ),
                  SizedBox(height: 16.spMin),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.spMin,
                      vertical: 12.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: brand.bgDarkNavy,
                      borderRadius: BorderRadius.circular(14.spMin),
                      border: Border.all(color: brand.tuna, width: 1.spMin),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gamepad_rounded,
                          size: 22.spMin,
                          color: brand.primaryBlue,
                        ),
                        SizedBox(width: 12.spMin),
                        Flexible(
                          child: Text(
                            context.l10n.remoteHelp,
                            style: tsS14W400.copyWith(color: brand.textMediumGray),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
