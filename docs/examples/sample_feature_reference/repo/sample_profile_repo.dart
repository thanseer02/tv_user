import 'package:base_project/services/web_api_services.dart';
import 'package:base_project/utils/urls.dart';
import '../model/sample_profile_model.dart';

/// A sample repository extension demonstrating the exact codebase integration pattern.
/// Repositories inside this project must be implemented as extensions on the WebAPIService class.
extension SampleProfileRepo on WebAPIService {
  /// Fetches a profile by ID.
  /// Demonstrates token, language, and tenant header initialization dynamically chained
  /// inside the methodToCall parameter using .then() to ensure sequential execution.
  Future<SampleProfileModel> fetchProfileDetails({
    required String userId,
    Function(dynamic msg)? onError,
    Function(SampleProfileModel profile)? onSuccess,
  }) {
    return executeAPI<SampleProfileModel>(
      methodToCall: initTokenToHeader().then(
        (value) => initLangPrefToHeader().then(
          (value) => initTenantPrefToHeader().then(
            (value) => dio.get('$urlRegistration/$userId'),
          ),
        ),
      ),
      converter: (responseMap) {
        // Map the JSON structure returned from validateResStatusData
        return SampleProfileModel.fromJson(responseMap as Map<String, dynamic>);
      },
      onError: onError,
      onSuccess: onSuccess,
    );
  }
}
