import 'package:flutter/material.dart';
import 'page_login.dart';
import 'page_input.dart';
import 'page_edit.dart';
import 'page_lihat.dart';
import 'services/user_service.dart';

class PageDashboard extends StatefulWidget {
  const PageDashboard({super.key});

  @override
  State<PageDashboard> createState() => _PageDashboardState();
}

class _PageDashboardState extends State<PageDashboard> {
  String nama = '';

  @override
  void initState() {
    super.initState();
    ambilNama();
  }

  Future<void> ambilNama() async {
    final hasil = await UserService.ambilNama();

    if (!mounted) return;

    setState(() {
      nama = hasil;
    });
  }

  void bukaHalaman(Widget halaman) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => halaman,
      ),
    );
  }

  Future<void> keluar() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Kamu yakin ingin keluar dari aplikasi?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (yakin != true) return;

    await UserService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const PageLogin(),
      ),
          (route) => false,
    );
  }

  Widget kartuMenu({
    required String judul,
    required String keterangan,
    required IconData ikon,
    required Color warna,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  ikon,
                  color: warna,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                keterangan,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard Pengguna'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 540),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MANAJEMEN PENGGUNA',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nama berasal dari akun yang berhasil login.
                  Text(
                    nama.isEmpty ? 'Halo!' : 'Halo, $nama!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kelola data pengguna melalui menu di bawah ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final lebarKartu = constraints.maxWidth < 280
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: lebarKartu,
                            child: kartuMenu(
                              judul: 'Lihat Data',
                              keterangan: 'Tampilkan daftar pengguna.',
                              ikon: Icons.list_alt,
                              warna: Colors.blue,
                              onTap: () {
                                bukaHalaman(const PageLihat());
                              },
                            ),
                          ),
                          SizedBox(
                            width: lebarKartu,
                            child: kartuMenu(
                              judul: 'Tambah Data',
                              keterangan: 'Masukkan pengguna baru.',
                              ikon: Icons.person_add_outlined,
                              warna: Colors.teal,
                              onTap: () {
                                bukaHalaman(const PageInput());
                              },
                            ),
                          ),
                          SizedBox(
                            width: lebarKartu,
                            child: kartuMenu(
                              judul: 'Edit Data',
                              keterangan: 'Perbarui data pengguna.',
                              ikon: Icons.edit_outlined,
                              warna: Colors.orange,
                              onTap: () {
                                bukaHalaman(const PageEdit());
                              },
                            ),
                          ),
                          SizedBox(
                            width: lebarKartu,
                            child: kartuMenu(
                              judul: 'Hapus Data',
                              keterangan: 'Pilih data untuk dihapus.',
                              ikon: Icons.delete_outline,
                              warna: Colors.red,
                              onTap: () {
                                bukaHalaman(const PageLihat());
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.blue.shade100),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: TextButton.icon(
              onPressed: keluar,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Keluar dari akun'),
            ),
          ),
        ),
      ),
    );
  }
}