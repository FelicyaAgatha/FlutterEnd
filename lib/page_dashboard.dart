import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'page_crud.dart';
import 'page_login.dart';
import 'page_manajemen_data.dart';
import 'services/user_service.dart';

const warnaUtama = Color(0xFF2563EB);
const warnaLatar = Color(0xFFF3F7FC);
const warnaTeks = Color(0xFF172B4D);

class PageDashboard extends StatefulWidget {
  const PageDashboard({super.key});

  @override
  State<PageDashboard> createState() => _PageDashboardState();
}

class _PageDashboardState extends State<PageDashboard> {
  String nama = UserService.nama ?? 'Pengelola';
  bool sedangKeluar = false;

  @override
  void initState() {
    super.initState();
    muatNama();
  }

  Future<void> muatNama() async {
    try {
      final hasil = await UserService.ambilNama();

      if (!mounted) return;

      setState(() => nama = hasil);
    } catch (_) {
      // Sapaan tetap memakai nama yang tersedia dari login.
    }
  }

  Future<void> keluar() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari aplikasi?'),
        content: const Text(
          'Kamu dapat masuk kembali menggunakan email dan password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() => sedangKeluar = true);

    try {
      await UserService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => sedangKeluar = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal keluar. Silakan coba kembali.'),
        ),
      );
    }
  }

  Widget kartuMenu({
    required String judul,
    required String deskripsi,
    required IconData ikon,
    required Color warna,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE3EAF5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(ikon, color: warna, size: 30),
              ),
              const SizedBox(height: 24),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: warnaTeks,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                deskripsi,
                style: const TextStyle(
                  height: 1.6,
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Text(
                    'Buka $judul',
                    style: TextStyle(
                      color: warna,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: warna,
                    size: 19,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: warnaTeks,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Manajemen Sekolah',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: sedangKeluar ? null : keluar,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF3B82F6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 38,
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Selamat datang kembali,',
                        style: TextStyle(
                          color: Color(0xFFDBEAFE),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Kelola data pengguna dan siswa dalam satu tempat.',
                        style: TextStyle(
                          color: Color(0xFFEFF6FF),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Menu Utama',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: warnaTeks,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih data yang ingin kamu kelola.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final lebar = constraints.maxWidth >= 700
                        ? (constraints.maxWidth - 20) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        SizedBox(
                          width: lebar,
                          child: kartuMenu(
                            judul: 'Data Pengguna',
                            deskripsi:
                                'Lihat daftar akun, email, dan status '
                                'pengguna aplikasi.',
                            ikon: Icons.manage_accounts_outlined,
                            warna: warnaUtama,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PageManajemenData(siswa: false),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: lebar,
                          child: kartuMenu(
                            judul: 'Data Siswa',
                            deskripsi:
                                'Lihat, tambah, edit, dan hapus '
                                'data siswa sekolah.',
                            ikon: Icons.school_outlined,
                            warna: const Color(0xFF0D9488),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PageManajemenData(siswa: true),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PageDataPengguna extends StatefulWidget {
  const PageDataPengguna({super.key});

  @override
  State<PageDataPengguna> createState() => _PageDataPenggunaState();
}

class _PageDataPenggunaState extends State<PageDataPengguna> {
  final pencarianController = TextEditingController();

  List<Map<String, dynamic>> daftar = [];
  bool memuat = true;
  String? pesanError;
  String kataKunci = '';
  String filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    muatData();
  }

  @override
  void dispose() {
    pencarianController.dispose();
    super.dispose();
  }

  Future<void> muatData() async {
    setState(() {
      memuat = true;
      pesanError = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('${UserService.baseUrl}/api/users'),
            headers: UserService.headers(),
          )
          .timeout(const Duration(seconds: 15));

      final hasil = UserService.bacaRespons(response);
      final data = hasil['data'];

      if (data is! List) {
        throw Exception('Format data pengguna tidak valid.');
      }

      final pengguna = data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Format data pengguna tidak valid.');
        }

        return item;
      }).toList();

      if (!mounted) return;

      setState(() => daftar = pengguna);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        pesanError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => memuat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasilFilter = daftar.where((item) {
      final nama = (item['nama'] ?? '').toString().toLowerCase();
      final email = (item['email'] ?? '').toString().toLowerCase();
      final status = (item['status'] ?? '').toString();

      final cocokPencarian =
          nama.contains(kataKunci) || email.contains(kataKunci);

      final cocokStatus =
          filterStatus == 'Semua' || status == filterStatus;

      return cocokPencarian && cocokStatus;
    }).toList();

    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: AppBar(
        title: const Text('Data Pengguna'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: warnaTeks,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: memuat ? null : muatData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Pengguna',
                  style: TextStyle(
                    fontSize: 24,
                    color: warnaTeks,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informasi akun dan status pengguna aplikasi.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: pencarianController,
                  onChanged: (value) {
                    setState(() {
                      kataKunci = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Semua', 'Aktif', 'Tidak Aktif'].map((status) {
                    return ChoiceChip(
                      label: Text(status),
                      selected: filterStatus == status,
                      onSelected: (_) {
                        setState(() => filterStatus = status);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: memuat
                      ? const Center(child: CircularProgressIndicator())
                      : pesanError != null
                          ? Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.cloud_off_outlined,
                                      size: 44,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      pesanError!,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton(
                                      onPressed: muatData,
                                      child: const Text('Coba lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : hasilFilter.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Tidak ada pengguna yang ditemukan.',
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: hasilFilter.length,
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = hasilFilter[index];
                                    final aktif = item['status'] == 'Aktif';

                                    return Card(
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor:
                                                  Color(0xFFEFF6FF),
                                              child: Icon(
                                                Icons.person_outline,
                                                color: warnaUtama,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${item['nama'] ?? '-'}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: warnaTeks,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    '${item['email'] ?? '-'}',
                                                    style: const TextStyle(
                                                      color:
                                                          Color(0xFF64748B),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: aktif
                                                          ? const Color(
                                                              0xFFDCFCE7)
                                                          : const Color(
                                                              0xFFF1F5F9),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(20),
                                                    ),
                                                    child: Text(
                                                      '${item['status'] ?? '-'}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: aktif
                                                            ? const Color(
                                                                0xFF15803D)
                                                            : const Color(
                                                                0xFF64748B),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}