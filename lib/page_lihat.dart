import 'package:flutter/material.dart';
import 'models/User.dart';
import 'services/user_service.dart';

class PageLihat extends StatefulWidget {
  const PageLihat({super.key});

  @override
  State<PageLihat> createState() => _PageLihatState();
}

class _PageLihatState extends State<PageLihat> {
  List<User> daftarUser = [];

  bool sedangMemuat = true;
  bool sedangMenghapus = false;
  String? pesanError;

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  Future<void> ambilData() async {
    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });

    try {
      final hasil = await UserService.getUsers();

      if (!mounted) return;

      setState(() {
        daftarUser = hasil;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        pesanError = error.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          sedangMemuat = false;
        });
      }
    }
  }

  Future<void> hapusData(User user) async {
    if (sedangMenghapus) return;

    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: Text(
            'Yakin ingin menghapus pengguna ${user.name}?\n'
                'Data yang dihapus tidak dapat dikembalikan.',
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
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || yakin != true) return;

    setState(() {
      sedangMenghapus = true;
    });

    try {
      final pesan = await UserService.hapusUser(user.id);

      if (!mounted) return;

      setState(() {
        daftarUser.removeWhere((item) => item.id == user.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sedangMenghapus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Lihat Data'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 900),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Pengguna',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar pengguna aplikasi siswa',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (sedangMemuat)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (pesanError != null)
                  Text(
                    pesanError!,
                    style: const TextStyle(color: Colors.red),
                  )
                else if (daftarUser.isEmpty)
                    const Text('Belum ada data pengguna.')
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: List.generate(
                          daftarUser.length,
                              (index) {
                            final user = daftarUser[index];

                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(user.name)),
                                DataCell(Text(user.email)),
                                DataCell(
                                  Text(
                                    user.status,
                                    style: TextStyle(
                                      color: user.status == 'Aktif'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  TextButton.icon(
                                    onPressed: sedangMenghapus
                                        ? null
                                        : () {
                                      hapusData(user);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                    label: const Text('Hapus'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                if (sedangMenghapus) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Menghapus data...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 16),
                if (!sedangMemuat && pesanError == null)
                  Text(
                    'Total: ${daftarUser.length} pengguna',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: sedangMemuat || sedangMenghapus
                            ? null
                            : ambilData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Muat Ulang'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: sedangMenghapus
                            ? null
                            : () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Kembali'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}