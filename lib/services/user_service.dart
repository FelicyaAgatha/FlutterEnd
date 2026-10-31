import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

class UserService {
  // Untuk Chrome di laptop yang menjalankan server.
  static const String baseUrl = 'http://localhost:3000';

  static String? token;
  static String? nama;

  static Map<String, String> headers() {
    if (token == null || token!.isEmpty) {
      throw Exception('Silakan login terlebih dahulu');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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

  static Future<void> login(
      String email,
      String password,
      ) async {
    token = null;
    nama = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nama');

    final response = await http
        .post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
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

    nama = prefs.getString('nama') ?? '';

    return nama!;
  }

  static Future<List<User>> getUsers() async {
    final response = await http
        .get(
      Uri.parse('$baseUrl/api/users'),
      headers: headers(),
    )
        .timeout(const Duration(seconds: 15));

    bacaPesan(response);

    final hasil = jsonDecode(response.body);
    final List data = hasil['data'];

    return data.map((item) {
      return User.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();
  }

  static Future<String> tambahUser(
      String nama,
      String email,
      String password,
      String status,
      ) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/api/users'),
      headers: headers(),
      body: jsonEncode({
        'nama': nama.trim(),
        'email': email.trim(),
        'password': password,
        'status': status,
      }),
    )
        .timeout(const Duration(seconds: 15));

    return bacaPesan(response);
  }

  static Future<String> updateUser(
      int id,
      String nama,
      String email,
      String password,
      String status,
      ) async {
    final data = <String, dynamic>{
      'nama': nama.trim(),
      'email': email.trim(),
      'status': status,
    };

    // Password kosong berarti tetap memakai password lama.
    if (password.isNotEmpty) {
      data['password'] = password;
    }

    final response = await http
        .put(
      Uri.parse('$baseUrl/api/users/$id'),
      headers: headers(),
      body: jsonEncode(data),
    )
        .timeout(const Duration(seconds: 15));

    return bacaPesan(response);
  }

  static Future<String> hapusUser(int id) async {
    final response = await http
        .delete(
      Uri.parse('$baseUrl/api/users/$id'),
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