import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

class UserService {
  // Ubah URL jika menggunakan emulator Android (10.0.2.2) atau HP fisik (IP lokal komputer)
  static const String baseUrl = 'http://localhost:3000';

  static String? token;
  static String? nama;

  static Map<String, String> headers() {
    return {
      'Content-Type': 'application/json',
    };
  }

  static String bacaPesan(http.Response response) {
    final hasil = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        hasil['status'] == true) {
      return hasil['message'] as String;
    }

    throw Exception(
      hasil['message'] ?? 'Permintaan gagal diproses',
    );
  }

  // Login sederhana berbasis NIPD berdasarkan data siswa di database
  static Future<void> login(String nipd) async {
    token = null;
    nama = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nama');

    final response = await http
        .post(
      Uri.parse('$baseUrl/api/login'), // Pastikan route login Next.js aktif
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nipd': nipd.trim()}),
    )
        .timeout(const Duration(seconds: 15));

    bacaPesan(response);

    final hasil = jsonDecode(response.body);
    final data = hasil['data'] as Map<String, dynamic>;

    final tokenLogin = data['token'] as String;
    final namaLogin = data['nama'] as String;

    await prefs.setString('nama', namaLogin);

    token = tokenLogin;
    nama = namaLogin;
  }

  static Future<String> ambilNama() async {
    final prefs = await SharedPreferences.getInstance();
    nama = prefs.getString('nama') ?? 'Administrator';
    return nama!;
  }

  // Mengambil seluruh data siswa
  static Future<List<User>> getUsers() async {
    final response = await http
        .get(
      Uri.parse('$baseUrl/api/siswa'),
      headers: headers(),
    )
        .timeout(const Duration(seconds: 15));

    bacaPesan(response);

    final hasil = jsonDecode(response.body);
    final List data = hasil['data'];

    return data.map((item) {
      return User.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  // Menambahkan siswa baru sesuai field database
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

  // Memperbarui data siswa berdasarkan ID
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

  // Menghapus siswa berdasarkan ID
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