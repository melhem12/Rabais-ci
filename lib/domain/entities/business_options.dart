/// Business category option returned by `/business/options`
class BusinessCategoryOption {
  final String id;
  final String name;
  final List<BusinessTypeOption> types;

  const BusinessCategoryOption({
    required this.id,
    required this.name,
    required this.types,
  });

  factory BusinessCategoryOption.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawTypes = json['types'] is List
        ? json['types'] as List
        : const [];
    final types = rawTypes
        .whereType<Map<String, dynamic>>()
        .map(BusinessTypeOption.fromJson)
        .toList();

    return BusinessCategoryOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      types: types,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types.map((type) => type.toJson()).toList(),
    };
  }
}

/// Business type option used to filter vouchers
class BusinessTypeOption {
  final String id;
  final String name;
  final String categoryId;

  const BusinessTypeOption({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory BusinessTypeOption.fromJson(Map<String, dynamic> json) {
    return BusinessTypeOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['category_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'category_id': categoryId};
  }
}




