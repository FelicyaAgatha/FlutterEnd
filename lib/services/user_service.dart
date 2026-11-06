import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart';

class UserService {
  // Untuk Flutter Chrome pada laptop yang sama dengan backend.
  static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3001',
);

  static String? token;
  static String? nama;

  static Map<String, String> headers() {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> bacaRespons(http.Response response) {
    dynamic hasil;

    try {
      hasil = jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'Respons server tidak sesuai. Periksa URL API dan terminal backend.',
      );
    }

    if (hasil is! Map<String, dynamic>) {
      throw Exception('Format respons server tidak valid.');
    }

    final berhasil = response.statusCode >= 200 &&
        response.statusCode < 300 &&
        hasil['status'] == true;

    if (!berhasil) {
      final pesan = hasil['message'];

      throw Exception(
        pesan is String ? pesan : 'Permintaan gagal diproses.',
      );
    }

    return hasil;
  }

  static String bacaPesan(http.Response response) {
    final hasil = bacaRespons(response);
    final pesan = hasil['message'];

    return pesan is String ? pesan : 'Permintaan berhasil.';
  }

  // Login menggunakan email dan password.
  static Future<void> login(String email, String password) async {
    token = null;
    nama = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nama');

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.trim(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final hasil = bacaRespons(response);
    final data = hasil['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Data login dari server tidak lengkap.');
    }

    final tokenLogin = data['token'];
    final namaLogin = data['nama'];

    if (tokenLogin is! String ||
        tokenLogin.isEmpty ||
        namaLogin is! String ||
        namaLogin.isEmpty) {
      throw Exception('Token atau nama pengguna tidak tersedia.');
    }

    await prefs.setString('nama', namaLogin);

    token = tokenLogin;
    nama = namaLogin;
  }

  static Future<String> ambilNama() async {
    final prefs = await SharedPreferences.getInstance();

    nama = prefs.getString('nama') ?? 'Administrator';

    return nama!;
  }

  // Nama fungsi dipertahankan agar halaman CRUD lama tetap cocok.
  // Data yang diambil adalah data siswa.
  static Future<List<User>> getUsers() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/siswa'),
          headers: headers(),
        )
        .timeout(const Duration(seconds: 15));

    final hasil = bacaRespons(response);
    final data = hasil['data'];

    if (data is! List) {
      throw Exception('Format daftar siswa tidak valid.');
    }

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw Exception('Format data siswa tidak valid.');
      }

      return User.fromJson(item);
    }).toList();
  }

  // Menambahkan siswa.
  static Future<String> tambahSiswa({
    required String nipd,
    required String namaLengkap,
    required String jenisKelamin,
    required String alamat,
    required String kelas,
    required String jurusan,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/siswa'),
          headers: headers(),
          body: jsonEncode({
            'nipd': nipd.trim(),
            'nama_lengkap': namaLengkap.trim(),
            'jenis_kelamin': jenisKelamin.trim(),
            'alamat': alamat.trim(),
            'kelas': kelas.trim(),
            'jurusan': jurusan.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    return bacaPesan(response);
  }

  // Memperbarui siswa berdasarkan ID.
  static Future<String> updateSiswa({
    required int id,
    required String nipd,
    required String namaLengkap,
    required String jenisKelamin,
    required String alamat,
    required String kelas,
    required String jurusan,
  }) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/api/siswa/$id'),
          headers: headers(),
          body: jsonEncode({
            'nipd': nipd.trim(),
            'nama_lengkap': namaLengkap.trim(),
            'jenis_kelamin': jenisKelamin.trim(),
            'alamat': alamat.trim(),
            'kelas': kelas.trim(),
            'jurusan': jurusan.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    return bacaPesan(response);
  }

  // Menghapus siswa berdasarkan ID.
  static Future<String> hapusSiswa(int id) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl/api/siswa/$id'),
          headers: headers(),
        )
        .timeout(const Duration(seconds: 15));

    return bacaPesan(response);
  }

  static Future<void> logout() async {
    token = null;
    nama = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nama');
  }
}