import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/user_service.dart';

const _biru = Color(0xFF2563EB);
const _latar = Color(0xFFF3F7FC);
const _teks = Color(0xFF172B4D);

const daftarKelas = ['X', 'XI', 'XII'];

const daftarJurusan = [
  'Rekayasa Perangkat Lunak',
  'Teknik Komputer dan Jaringan',
  'Desain Komunikasi Visual',
  'Bisnis Digital',
  'Tax Accounting',
];

Future<Map<String, dynamic>> _kirimApi(
  String method,
  String path, [
  Map<String, dynamic>? data,
]) async {
  final uri = Uri.parse('${UserService.baseUrl}$path');
  final headers = UserService.headers();

  late http.Response response;

  switch (method) {
    case 'GET':
      response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      break;

    case 'POST':
      response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      break;

    case 'PUT':
      response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      break;

    case 'DELETE':
      response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      break;

    default:
      throw Exception('Method tidak didukung.');
  }

  return UserService.bacaRespons(response);
}

String _pesanError(Object error) {
  if (error is http.ClientException) {
    return 'Backend tidak dapat dihubungi. '
        'Pastikan server berjalan di port 3001.';
  }

  return error.toString().replaceFirst('Exception: ', '');
}

class PageManajemenData extends StatefulWidget {
  final bool siswa;

  const PageManajemenData({
    super.key,
    required this.siswa,
  });

  @override
  State<PageManajemenData> createState() =>
      _PageManajemenDataState();
}

class _PageManajemenDataState extends State<PageManajemenData> {
  final pencarianController = TextEditingController();

  List<Map<String, dynamic>> daftar = [];

  bool memuat = true;
  bool sedangMenghapus = false;

  String kataKunci = '';
  String filter = 'Semua';
  String? pesanError;

  String get judul =>
      widget.siswa ? 'Data Siswa' : 'Data Pengguna';

  String get endpoint =>
      widget.siswa ? '/api/siswa' : '/api/users';

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

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> muatData() async {
    setState(() {
      memuat = true;
      pesanError = null;
    });

    try {
      final hasil = await _kirimApi('GET', endpoint);
      final data = hasil['data'];

      if (data is! List) {
        throw Exception('Format daftar data tidak valid.');
      }

      final rows = data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Format data tidak valid.');
        }

        return item;
      }).toList();

      if (!mounted) return;

      setState(() {
        daftar = rows;

        if (!pilihanFilter.contains(filter)) {
          filter = 'Semua';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        pesanError = _pesanError(error);
      });
    } finally {
      if (mounted) {
        setState(() => memuat = false);
      }
    }
  }

  Future<void> bukaForm([Map<String, dynamic>? item]) async {
    final pesan = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FormData(
        siswa: widget.siswa,
        data: item,
      ),
    );

    if (!mounted || pesan == null) return;

    tampilkanPesan(pesan);
    await muatData();
  }

  Future<void> hapus(Map<String, dynamic> item) async {
    if (sedangMenghapus) return;

    final nama = item[
      widget.siswa ? 'nama_lengkap' : 'nama'
    ];

    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text(
          'Data "$nama" akan dihapus permanen. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || yakin != true) return;

    setState(() => sedangMenghapus = true);

    try {
      final hasil = await _kirimApi(
        'DELETE',
        '$endpoint/${item['id']}',
      );

      if (!mounted) return;

      tampilkanPesan('${hasil['message']}');
      await muatData();
    } catch (error) {
      if (!mounted) return;

      tampilkanPesan(_pesanError(error));
    } finally {
      if (mounted) {
        setState(() => sedangMenghapus = false);
      }
    }
  }

  List<String> get pilihanFilter {
    if (!widget.siswa) {
      return ['Semua', 'Aktif', 'Tidak Aktif'];
    }

    final kelasLama = daftar
        .map((item) => '${item['kelas'] ?? ''}')
        .where((value) => value.isNotEmpty);

    return {
      'Semua',
      ...daftarKelas,
      ...kelasLama,
    }.toList();
  }

  List<Map<String, dynamic>> get hasilFilter {
    return daftar.where((item) {
      final nama =
          '${item[widget.siswa ? 'nama_lengkap' : 'nama'] ?? ''}'
              .toLowerCase();

      final identitas =
          '${item[widget.siswa ? 'nipd' : 'email'] ?? ''}'
              .toLowerCase();

      final nilaiFilter =
          '${item[widget.siswa ? 'kelas' : 'status'] ?? ''}';

      final cocokPencarian =
          nama.contains(kataKunci) ||
          identitas.contains(kataKunci);

      final cocokFilter =
          filter == 'Semua' || nilaiFilter == filter;

      return cocokPencarian && cocokFilter;
    }).toList();
  }

  Widget kartuData(Map<String, dynamic> item) {
    final nama =
        '${item[widget.siswa ? 'nama_lengkap' : 'nama'] ?? '-'}';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE3EAF5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFEFF6FF),
              child: Icon(
                widget.siswa
                    ? Icons.school_outlined
                    : Icons.person_outline,
                color: _biru,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _teks,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.siswa) ...[
                    Text('NIPD: ${item['nipd']}'),
                    const SizedBox(height: 4),
                    Text(
                      'Kelas ${item['kelas']}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['jurusan']}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['jenis_kelamin']} · ${item['alamat']}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${item['email']}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: item['status'] == 'Aktif'
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item['status']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: item['status'] == 'Aktif'
                              ? const Color(0xFF15803D)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  color: _biru,
                  onPressed: sedangMenghapus
                      ? null
                      : () => bukaForm(item),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  color: Colors.red.shade600,
                  onPressed: sedangMenghapus
                      ? null
                      : () => hapus(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tampilanDaftar(List<Map<String, dynamic>> rows) {
    if (memuat) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (pesanError != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 42,
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
      );
    }

    if (rows.isEmpty) {
      return const Center(
        child: Text('Tidak ada data yang ditemukan.'),
      );
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (_, index) => kartuData(rows[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = hasilFilter;

    return Scaffold(
      backgroundColor: _latar,
      appBar: AppBar(
        title: Text(judul),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _teks,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: memuat || sedangMenghapus
                ? null
                : muatData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 14,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: _teks,
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _biru,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onPressed: sedangMenghapus
                          ? null
                          : () => bukaForm(),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        widget.siswa
                            ? 'Tambah Siswa'
                            : 'Tambah Pengguna',
                      ),
                    ),
                  ],
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
                    hintText: widget.siswa
                        ? 'Cari nama atau NIPD...'
                        : 'Cari nama atau email...',
                    prefixIcon:
                        const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.siswa ? 'Kelas: ' : 'Status: ',
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: filter,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: pilihanFilter.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() => filter = value);
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 4,
                    right: 14,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nama dan informasi',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Aksi',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: tampilanDaftar(rows),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormData extends StatefulWidget {
  final bool siswa;
  final Map<String, dynamic>? data;

  const _FormData({
    required this.siswa,
    this.data,
  });

  @override
  State<_FormData> createState() => _FormDataState();
}

class _FormDataState extends State<_FormData> {
  final formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {};

  bool menyimpan = false;
  bool sembunyikanPassword = true;

  String? pesanError;

  late String jenisKelamin;
  late String status;

  bool get edit => widget.data != null;

  @override
  void initState() {
    super.initState();

    final fields = widget.siswa
        ? [
            'nipd',
            'nama_lengkap',
            'alamat',
            'kelas',
            'jurusan',
          ]
        : ['nama', 'email', 'password'];

    for (final field in fields) {
      controllers[field] = TextEditingController(
        text: field == 'password'
            ? ''
            : '${widget.data?[field] ?? ''}',
      );
    }

    jenisKelamin =
        '${widget.data?['jenis_kelamin'] ?? 'Laki-laki'}';

    status = '${widget.data?['status'] ?? 'Aktif'}';

    if (widget.siswa) {
      if (controllers['kelas']!.text.isEmpty) {
        controllers['kelas']!.text = daftarKelas.first;
      }

      if (controllers['jurusan']!.text.isEmpty) {
        controllers['jurusan']!.text = daftarJurusan.first;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Widget input(
    String field,
    String label, {
    int? maxLength,
    int maxLines = 1,
    bool password = false,
    bool email = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controllers[field],
        enabled: !menyimpan,
        maxLength: maxLength,
        maxLines: maxLines,
        obscureText: password && sembunyikanPassword,
        autocorrect: !password && !email,
        enableSuggestions: !password,
        keyboardType: email
            ? TextInputType.emailAddress
            : maxLines > 1
                ? TextInputType.multiline
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          helperText: password && edit
              ? 'Kosongkan jika password tidak diubah.'
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: password
              ? IconButton(
                  onPressed: menyimpan
                      ? null
                      : () {
                          setState(() {
                            sembunyikanPassword =
                                !sembunyikanPassword;
                          });
                        },
                  icon: Icon(
                    sembunyikanPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                )
              : null,
        ),
        validator: (value) {
          final teks = value ?? '';

          if (password) {
            if (edit && teks.isEmpty) return null;

            if (teks.length < 8) {
              return 'Password minimal 8 karakter';
            }

            if (utf8.encode(teks).length > 72) {
              return 'Password terlalu panjang';
            }

            return null;
          }

          if (teks.trim().isEmpty) {
            return '$label wajib diisi';
          }

          if (email &&
              !RegExp(
                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
              ).hasMatch(teks.trim())) {
            return 'Format email tidak valid';
          }

          return null;
        },
      ),
    );
  }

  Widget pilihan({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: menyimpan
                ? null
                : (value) {
                    if (value != null) {
                      onChanged(value);
                    }
                  },
          ),
        ),
      ),
    );
  }

  Future<void> simpan() async {
    if (menyimpan) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    setState(() {
      menyimpan = true;
      pesanError = null;
    });

    try {
      final body = <String, dynamic>{};

      for (final entry in controllers.entries) {
        body[entry.key] = entry.key == 'password'
            ? entry.value.text
            : entry.value.text.trim();
      }

      if (widget.siswa) {
        body['jenis_kelamin'] = jenisKelamin;
      } else {
        body['status'] = status;
      }

      final endpoint =
          widget.siswa ? '/api/siswa' : '/api/users';

      final hasil = await _kirimApi(
        edit ? 'PUT' : 'POST',
        edit
            ? '$endpoint/${widget.data!['id']}'
            : endpoint,
        body,
      );

      if (!mounted) return;

      Navigator.pop(context, '${hasil['message']}');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        pesanError = _pesanError(error);
      });
    } finally {
      if (mounted) {
        setState(() => menyimpan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final objek = widget.siswa ? 'Siswa' : 'Pengguna';

    return PopScope(
      canPop: !menyimpan,
      child: AlertDialog(
        title: Text(
          '${edit ? 'Edit' : 'Tambah'} $objek',
          style: const TextStyle(
            color: _teks,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.siswa) ...[
                    input(
                      'nipd',
                      'NIPD',
                      maxLength: 30,
                    ),
                    input(
                      'nama_lengkap',
                      'Nama Lengkap',
                      maxLength: 100,
                    ),
                    pilihan(
                      label: 'Jenis Kelamin',
                      value: jenisKelamin,
                      items: const [
                        'Laki-laki',
                        'Perempuan',
                      ],
                      onChanged: (value) {
                        setState(() {
                          jenisKelamin = value;
                        });
                      },
                    ),
                    input(
                      'alamat',
                      'Alamat',
                      maxLength: 1000,
                      maxLines: 3,
                    ),
                    pilihan(
                      label: 'Kelas',
                      value: controllers['kelas']!.text,
                      items: {
                        ...daftarKelas,
                        controllers['kelas']!.text,
                      }.toList(),
                      onChanged: (value) {
                        setState(() {
                          controllers['kelas']!.text = value;
                        });
                      },
                    ),
                    pilihan(
                      label: 'Jurusan',
                      value: controllers['jurusan']!.text,
                      items: {
                        ...daftarJurusan,
                        controllers['jurusan']!.text,
                      }.toList(),
                      onChanged: (value) {
                        setState(() {
                          controllers['jurusan']!.text = value;
                        });
                      },
                    ),
                  ] else ...[
                    input(
                      'nama',
                      'Nama Lengkap',
                      maxLength: 100,
                    ),
                    input(
                      'email',
                      'Email',
                      maxLength: 100,
                      email: true,
                    ),
                    input(
                      'password',
                      edit ? 'Password Baru' : 'Password',
                      password: true,
                    ),
                    pilihan(
                      label: 'Status',
                      value: status,
                      items: const [
                        'Aktif',
                        'Tidak Aktif',
                      ],
                      onChanged: (value) {
                        setState(() {
                          status = value;
                        });
                      },
                    ),
                  ],
                  if (pesanError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        pesanError!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: menyimpan
                ? null
                : () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _biru,
            ),
            onPressed: menyimpan ? null : simpan,
            child: Text(
              menyimpan ? 'Menyimpan...' : 'Simpan',
            ),
          ),
        ],
      ),
    );
  }
}