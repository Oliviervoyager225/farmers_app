class Category {
  final int id;
  final String name;
  final String? icon;
  final String? description;
  final int? parentId;
  final List<Category> children;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.parentId,
    this.children = const [],
  });

  /// Display label with emoji prefix when available.
  String get label => icon != null ? '$icon $name' : name;

  bool get isRoot => parentId == null;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String?,
        description: json['description'] as String?,
        parentId: json['parent_id'] as int?,
        children: (json['children'] as List<dynamic>? ?? [])
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
