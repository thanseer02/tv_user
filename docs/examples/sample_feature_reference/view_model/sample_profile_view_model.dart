import 'package:base_project/models/app_error_model.dart';
import 'package:base_project/providers/view_model.dart';
import 'package:base_project/services/web_api_services.dart';
import 'package:base_project/utils/extensions.dart';
import '../model/sample_profile_model.dart';
import '../repo/sample_profile_repo.dart';

/// A sample ViewModel demonstrating correct state processing and API binding.
class SampleProfileViewModel extends ViewModel {
  SampleProfileModel? _profile;
  SampleProfileModel? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _newsletterOptIn = false;
  bool get newsletterOptIn => _newsletterOptIn;

  set newsletterOptIn(bool val) {
    _newsletterOptIn = val;
    notifyListeners(); // Causes reactive rebuild in consumers
  }

  /// Triggers user profile retrieval.
  /// Demonstrates progressive indicator wrapping using .setProgress extension
  /// and standard error handling workflows.
  Future<void> loadUserProfile(String userId) async {
    _errorMessage = null;
    notifyListeners();

    await WebAPIService()
        .fetchProfileDetails(userId: userId)
        .then((data) {
          _profile = data;
          notifyListeners();
        })
        .handleAPIException(
          handleAPIException: handleAPIException,
          onShowError: (AppError error) {
            _errorMessage = error.message;
            notifyListeners();
          },
        )
        .setProgress(this); // Automatically drives progress spinner state (isLoading = true/false)
  }
}
