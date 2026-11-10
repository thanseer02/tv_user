import 'package:json_annotation/json_annotation.dart';

part 'tv_portal_item_model.g.dart';

@JsonSerializable()
class TvPortalItemModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'url')
  final String url;

  @JsonKey(name: 'icon_name')
  final String? iconName;

  const TvPortalItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    this.iconName,
  });

  factory TvPortalItemModel.fromJson(Map<String, dynamic> json) =>
      _$TvPortalItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TvPortalItemModelToJson(this);
}
