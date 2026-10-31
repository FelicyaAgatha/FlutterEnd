class User {
  int id;
  String name;
  String email;
  String status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['nama'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
    );
  }
}