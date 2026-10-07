class User {
  final String id;
  final String name;
  final String? email;

  const User({required this.id, required this.name, required this.email});

  User copyWith({
    String? id,
    String? name,
    String? email,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
  );
}
