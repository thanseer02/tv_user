import 'package:json_annotation/json_annotation.dart';

part 'sample_profile_model.g.dart';

/// A sample model representing user profile data.
/// Demonstrates standard JSON serialization patterns of the project.
@JsonSerializable()
class SampleProfileModel {
  @JsonKey(name: 'id')
  final String userId;

  @JsonKey(name: 'name')
  final String fullName;

  @JsonKey(name: 'email')
  final String emailAddress;

  @JsonKey(name: 'role')
  final String userRole;

  SampleProfileModel({
    required this.userId,
    required this.fullName,
    required this.emailAddress,
    required this.userRole,
  });

  /// Factory constructor to parse model from map
  factory SampleProfileModel.fromJson(Map<String, dynamic> json) =>
      _$SampleProfileModelFromJson(json);

  /// Map model back to a json map
  Map<String, dynamic> toJson() => _$SampleProfileModelToJson(this);
}
