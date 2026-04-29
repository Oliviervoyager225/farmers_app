class Category {
  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final List<Category> children;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        parentId: json['parent_id'] as int?,
        children: (json['children'] as List<dynamic>? ?? [])
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  bool get isRoot => parentId == null;
}
