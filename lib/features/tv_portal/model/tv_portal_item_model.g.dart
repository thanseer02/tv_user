// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_portal_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TvPortalItemModel _$TvPortalItemModelFromJson(Map<String, dynamic> json) =>
    TvPortalItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      iconName: json['icon_name'] as String?,
    );

Map<String, dynamic> _$TvPortalItemModelToJson(TvPortalItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'icon_name': instance.iconName,
    };
