import 'package:json_annotation/json_annotation.dart';

part 'tv_portal_item_model.g.dart';

@JsonSerializable()
class TvPortalItemModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'url')
  final String? url;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'category')
  final String? category;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'environment')
  final String? environment;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'refreshInterval')
  final int? refreshInterval;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  @JsonKey(name: 'icon_name')
  final String? iconName;

  const TvPortalItemModel({
    required this.id,
    this.title,
    this.name,
    this.url,
    this.address,
    this.category,
    this.description,
    this.notes,
    this.environment,
    this.status,
    this.refreshInterval,
    this.createdAt,
    this.updatedAt,
    this.iconName,
  });

  /// Returns user-facing title, falling back to name or id.
  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    return id;
  }

  /// Returns user-facing URL, falling back to address.
  String get displayUrl {
    if (url != null && url!.trim().isNotEmpty) {
      return url!.trim();
    }
    if (address != null && address!.trim().isNotEmpty) {
      return address!.trim();
    }
    return '';
  }

  /// Returns user-facing description, falling back to category or notes.
  String get displayDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    if (category != null && category!.trim().isNotEmpty) {
      return 'Category: $category';
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      return notes!.trim();
    }
    return '';
  }

  factory TvPortalItemModel.fromJson(Map<String, dynamic> json) =>
      _$TvPortalItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TvPortalItemModelToJson(this);
}
