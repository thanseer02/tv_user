// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_portal_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TvPortalItemModel _$TvPortalItemModelFromJson(Map<String, dynamic> json) =>
    TvPortalItemModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      address: json['address'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      environment: json['environment'] as String?,
      status: json['status'] as String?,
      refreshInterval: (json['refreshInterval'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      iconName: json['icon_name'] as String?,
    );

Map<String, dynamic> _$TvPortalItemModelToJson(TvPortalItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'name': instance.name,
      'url': instance.url,
      'address': instance.address,
      'category': instance.category,
      'description': instance.description,
      'notes': instance.notes,
      'environment': instance.environment,
      'status': instance.status,
      'refreshInterval': instance.refreshInterval,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'icon_name': instance.iconName,
    };
