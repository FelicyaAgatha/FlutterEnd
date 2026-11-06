class User {
  final int id;
  final String nipd;
  final String namaLengkap;
  final String jenisKelamin;
  final String alamat;
  final String kelas;
  final String jurusan;

  User({
    required this.id,
    required this.nipd,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.alamat,
    required this.kelas,
    required this.jurusan,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nipd: json['nipd']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? 'Laki-laki',
      alamat: json['alamat']?.toString() ?? '',
      kelas: json['kelas']?.toString() ?? '',
      jurusan: json['jurusan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nipd': nipd,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'kelas': kelas,
      'jurusan': jurusan,
    };
  }
}