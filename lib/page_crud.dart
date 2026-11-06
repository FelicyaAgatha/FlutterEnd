import 'package:flutter/material.dart';
import 'models/User.dart';
import 'services/user_service.dart';

class PageCrud extends StatefulWidget {
  const PageCrud({super.key});

  @override
  State<PageCrud> createState() => _PageCrudState();
}

class _PageCrudState extends State<PageCrud> {
  final formKey = GlobalKey<FormState>();
  final nipdController = TextEditingController();
  final namaLengkapController = TextEditingController();
  final alamatController = TextEditingController();
  final kelasController = TextEditingController();
  final jurusanController = TextEditingController();

  List<User> daftarSiswa = [];
  int? idEdit; // null = mode tambah, ada nilai = mode edit

  bool sedangMemuat = true;
  bool sedangMenyimpan = false;
  String jenisKelamin = 'Laki-laki';
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
        daftarSiswa = hasil;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        pesanError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => sedangMemuat = false);
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    nipdController.clear();
    namaLengkapController.clear();
    alamatController.clear();
    kelasController.clear();
    jurusanController.clear();
    setState(() {
      idEdit = null;
      jenisKelamin = 'Laki-laki';
    });
  }

  void siapkanEdit(User siswa) {
    setState(() {
      idEdit = siswa.id;
      nipdController.text = siswa.nipd;
      namaLengkapController.text = siswa.namaLengkap;
      jenisKelamin = siswa.jenisKelamin;
      alamatController.text = siswa.alamat;
      kelasController.text = siswa.kelas;
      jurusanController.text = siswa.jurusan;
    });
  }

  Future<void> simpanAtauUpdate() async {
    if (sedangMenyimpan) return;
    if (!formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => sedangMenyimpan = true);

    try {
      String pesan;
      if (idEdit == null) {
        pesan = await UserService.tambahSiswa(
          nipd: nipdController.text,
          namaLengkap: namaLengkapController.text,
          jenisKelamin: jenisKelamin,
          alamat: alamatController.text,
          kelas: kelasController.text,
          jurusan: jurusanController.text,
        );
      } else {
        pesan = await UserService.updateSiswa(
          id: idEdit!,
          nipd: nipdController.text,
          namaLengkap: namaLengkapController.text,
          jenisKelamin: jenisKelamin,
          alamat: alamatController.text,
          kelas: kelasController.text,
          jurusan: jurusanController.text,
        );
      }

      if (!mounted) return;
      resetForm();
      ambilData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: Colors.green),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => sedangMenyimpan = false);
    }
  }

  Future<void> hapusData(User siswa) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus siswa ${siswa.namaLengkap}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (yakin != true || !mounted) return;

    try {
      final pesan = await UserService.hapusSiswa(siswa.id);
      if (!mounted) return;
      ambilData();
      if (idEdit == siswa.id) resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: Colors.green),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nipdController.dispose();
    namaLengkapController.dispose();
    alamatController.dispose();
    kelasController.dispose();
    jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Manajemen Data Siswa'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          idEdit == null
                              ? '➕ Tambah Siswa Baru'
                              : '✏️ Edit Data Siswa (ID: $idEdit)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: idEdit == null
                                ? Colors.teal
                                : Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nipdController,
                          decoration: InputDecoration(
                            labelText: 'NIPD',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'NIPD wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: namaLengkapController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Nama lengkap wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: jenisKelamin,
                          decoration: InputDecoration(
                            labelText: 'Jenis Kelamin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Laki-laki',
                              child: Text('Laki-laki'),
                            ),
                            DropdownMenuItem(
                              value: 'Perempuan',
                              child: Text('Perempuan'),
                            ),
                          ],
                          onChanged: (val) => setState(
                                () => jenisKelamin = val!,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: alamatController,
                          decoration: InputDecoration(
                            labelText: 'Alamat',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Alamat wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: kelasController,
                          decoration: InputDecoration(
                            labelText: 'Kelas',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Kelas wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: jurusanController,
                          decoration: InputDecoration(
                            labelText: 'Jurusan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Jurusan wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: idEdit == null
                                      ? Colors.teal
                                      : Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed:
                                sedangMenyimpan ? null : simpanAtauUpdate,
                                child: Text(
                                  sedangMenyimpan
                                      ? 'Menyimpan...'
                                      : (idEdit == null
                                      ? 'Simpan Data'
                                      : 'Update Data'),
                                ),
                              ),
                            ),
                            if (idEdit != null) ...[
                              const SizedBox(width: 10),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: resetForm,
                                child: const Text('Batal Edit'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Daftar Tabel Siswa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      sedangMemuat
                          ? const Center(child: CircularProgressIndicator())
                          : pesanError != null
                          ? Text(
                        pesanError!,
                        style: const TextStyle(color: Colors.red),
                      )
                          : daftarSiswa.isEmpty
                          ? const Text('Belum ada data siswa.')
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('NIPD')),
                            DataColumn(label: Text('Nama Lengkap')),
                            DataColumn(label: Text('JK')),
                            DataColumn(label: Text('Alamat')),
                            DataColumn(label: Text('Kelas')),
                            DataColumn(label: Text('Jurusan')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows: List.generate(
                            daftarSiswa.length,
                                (index) {
                              final s = daftarSiswa[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(Text(s.nipd)),
                                  DataCell(Text(s.namaLengkap)),
                                  DataCell(Text(s.jenisKelamin)),
                                  DataCell(Text(s.alamat)),
                                  DataCell(Text(s.kelas)),
                                  DataCell(Text(s.jurusan)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              siapkanEdit(s),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              hapusData(s),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}