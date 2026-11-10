import 'package:base_project/utils/localization.dart';
import 'package:base_project/utils/brand_colors.dart';
import 'package:base_project/utils/extensions.dart';
import 'package:base_project/utils/styles.dart';
import 'package:base_project/widgets/app_button_widget.dart';
import 'package:base_project/widgets/app_custom_text_field.dart';
import 'package:base_project/widgets/custom_app_bar.dart';
import 'package:base_project/widgets/custom_checkbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../view_model/sample_profile_view_model.dart';

/// Parameter arguments for SampleProfileScreen.
class SampleProfileScreenParams {
  final String userId;
  SampleProfileScreenParams({required this.userId});
}

/// A complete sample feature View demonstrating correctness in:
/// - Named routing and parameters extraction via extensions
/// - Provider wiring above the Scaffold widget tree
/// - Predefined text styles and brand colors matching the design system
/// - Responsive scaling (w, h, spMin)
/// - Consumption of global components (AppButton, CustomTextField, CustomCheckBoxWidget)
/// - Asynchronous visual progressive spinner wrapping (.showCircleProgressOnCenter)
class SampleProfileScreen extends StatefulWidget {
  static const String routeName = '/SampleProfileScreen';
  final SampleProfileScreenParams params;

  const SampleProfileScreen({super.key, required this.params});

  @override
  State<SampleProfileScreen> createState() => _SampleProfileScreenState();
}

class _SampleProfileScreenState extends State<SampleProfileScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  late SampleProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SampleProfileViewModel();
    // Initialize data retrieval safely after the widget has built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadUserProfile(widget.params.userId);
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve colors via AppBrandColors ThemeExtension
    final brand = context.brand;
    final cs = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<SampleProfileViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: brand.bgDeepNavy,
        appBar: buildAppBar(
          title: Localization.locale.hello, // Consuming standard localizations
          showActions: true,
        ),
        // 2. Wrap layout structure inside progressive spinner overlay
        body: Consumer<SampleProfileViewModel>(
          builder: (context, vm, _) {
            // Handle network failure states safely
            if (vm.errorMessage != null) {
              return Center(
                child: Text(
                  vm.errorMessage!,
                  style: tsS16W600.copyWith(color: brand.danger, fontSize: 16.spMin),
                ),
              );
            }

            final user = vm.profile;
            if (user == null) {
              return const SizedBox(); // Spinner is overlayed during network fetches
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.spMin, vertical: 16.spMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Typography and Responsive Text
                  Text(
                    user.fullName,
                    style: tsS22W600.copyWith(
                      color: brand.textWhite,
                      fontSize: 22.spMin, // Using spMin for typography scaling
                    ),
                  ),
                  SizedBox(height: 8.spMin),
                  Text(
                    "${user.userRole} | ${user.emailAddress}",
                    style: tsS14W400.copyWith(
                      color: brand.textMediumGray,
                      fontSize: 14.spMin,
                    ),
                  ),
                  Divider(height: 32.spMin, color: cs.outlineVariant),

                  // Reusing Custom Input fields
                  Text(
                    "Submit Feedback",
                    style: tsS16W600.copyWith(color: brand.textOffWhite, fontSize: 16.spMin),
                  ),
                  SizedBox(height: 12.spMin),
                  CustomTextField(
                    hint: "Type your message here...",
                    controller: _feedbackController,
                    hintStyle: tsS14W400.copyWith(color: brand.textSubtleGray),
                    textStyle: tsS14W400.copyWith(color: brand.textWhite),
                  ),
                  SizedBox(height: 24.spMin),

                  // Reusing Custom Selection Widgets
                  Row(
                    children: [
                      CustomCheckBoxWidget(
                        value: vm.newsletterOptIn,
                        onTap: () {
                          vm.newsletterOptIn = !vm.newsletterOptIn;
                        },
                      ),
                      SizedBox(width: 12.spMin),
                      Expanded(
                        child: Text(
                          "Subscribe to product updates",
                          style: tsS14W400.copyWith(color: brand.textLightGray, fontSize: 14.spMin),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 32.spMin),

                  // Reusing Standardized Global Buttons
                  Center(
                    child: AppButton.curvedButton(
                      text: "Submit",
                      backgroundColor: brand.primaryBlue,
                      onTap: () {
                        // Action execution code
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Feedback: ${_feedbackController.text}")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ).showCircleProgressOnCenter<SampleProfileViewModel>(), // Reactive center loader extension
      ),
    );
  }
}
