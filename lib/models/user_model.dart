class User {
  final int id;
  final String nama;
  final String jabatan;
  final String username;
  final String password;

  User({required this.id, required this.nama, required this.jabatan, required this.username, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      jabatan: json['jabatan'],
      username: json['username'],
      password: json['password'],
    );
  }
}
