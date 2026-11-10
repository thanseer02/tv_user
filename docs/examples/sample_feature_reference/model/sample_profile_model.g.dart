// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleProfileModel _$SampleProfileModelFromJson(Map<String, dynamic> json) =>
    SampleProfileModel(
      userId: json['id'] as String,
      fullName: json['name'] as String,
      emailAddress: json['email'] as String,
      userRole: json['role'] as String,
    );

Map<String, dynamic> _$SampleProfileModelToJson(SampleProfileModel instance) =>
    <String, dynamic>{
      'id': instance.userId,
      'name': instance.fullName,
      'email': instance.emailAddress,
      'role': instance.userRole,
    };
