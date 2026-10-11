class UnitItem {
  final String id;
  final String name;
  final String? description;

  const UnitItem({
    required this.id,
    required this.name,
    required this.description,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}
