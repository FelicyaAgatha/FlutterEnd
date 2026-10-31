import 'package:flutter/material.dart';
import 'models/User.dart';
import 'services/user_service.dart';

class PageEdit extends StatefulWidget {
  const PageEdit({super.key});

  @override
  State<PageEdit> createState() => _PageEditState();
}

class _PageEditState extends State<PageEdit> {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  List<User> daftarUser = [];
  int? idTerpilih;

  String status = 'Aktif';
  String? pesanError;

  bool sedangMemuat = true;
  bool sedangMenyimpan = false;
  bool sembunyikanPassword = true;

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

  void pilihUser(int id) {
    final user = daftarUser.firstWhere(
          (item) => item.id == id,
    );

    formKey.currentState!.reset();

    setState(() {
      idTerpilih = id;
      namaController.text = user.name;
      emailController.text = user.email;
      passwordController.clear();
      status = user.status;
      sembunyikanPassword = true;
    });
  }

  Future<void> updateData() async {
    if (sedangMenyimpan) return;
    if (!formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      sedangMenyimpan = true;
    });

    try {
      final pesan = await UserService.updateUser(
        idTerpilih!,
        namaController.text,
        emailController.text,
        passwordController.text,
        status,
      );

      if (!mounted) return;

      final index = daftarUser.indexWhere(
            (item) => item.id == idTerpilih,
      );

      setState(() {
        daftarUser[index] = User(
          id: idTerpilih!,
          name: namaController.text.trim(),
          email: emailController.text.trim(),
          status: status,
        );

        passwordController.clear();
        sembunyikanPassword = true;
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
          sedangMenyimpan = false;
        });
      }
    }
  }

  void bersihkanForm() {
    formKey.currentState!.reset();
    namaController.clear();
    emailController.clear();
    passwordController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      idTerpilih = null;
      status = 'Aktif';
      sembunyikanPassword = true;
    });
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit Data'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Pengguna',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih pengguna, lalu ubah datanya.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  if (sedangMemuat)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (pesanError != null) ...[
                    Text(
                      pesanError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                      onPressed: ambilData,
                      child: const Text('Coba Lagi'),
                    ),
                  ] else if (daftarUser.isEmpty)
                    const Text('Belum ada pengguna untuk diedit.')
                  else ...[
                      DropdownButtonFormField<int>(
                        key: ValueKey(idTerpilih),
                        initialValue: idTerpilih,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Pilih Pengguna',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: daftarUser.map((user) {
                          return DropdownMenuItem<int>(
                            value: user.id,
                            child: Text(
                              '${user.id} - ${user.name}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: sedangMenyimpan
                            ? null
                            : (value) {
                          if (value != null) {
                            pilihUser(value);
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih pengguna terlebih dahulu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: namaController,
                        enabled:
                        idTerpilih != null && !sedangMenyimpan,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: emailController,
                        enabled:
                        idTerpilih != null && !sedangMenyimpan,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }

                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())) {
                            return 'Format email belum benar';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        enabled:
                        idTerpilih != null && !sedangMenyimpan,
                        obscureText: sembunyikanPassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          helperText: 'Kosongkan jika tidak diganti',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            onPressed:
                            idTerpilih == null || sedangMenyimpan
                                ? null
                                : () {
                              setState(() {
                                sembunyikanPassword =
                                !sembunyikanPassword;
                              });
                            },
                            icon: Icon(
                              sembunyikanPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.trim().isEmpty) {
                              return 'Password tidak boleh hanya spasi';
                            }

                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        key: ValueKey('$idTerpilih-$status'),
                        initialValue: status,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: {
                          'Aktif',
                          'Tidak Aktif',
                          status,
                        }.map((nilai) {
                          return DropdownMenuItem<String>(
                            value: nilai,
                            child: Text(nilai),
                          );
                        }).toList(),
                        onChanged:
                        idTerpilih == null || sedangMenyimpan
                            ? null
                            : (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: sedangMenyimpan
                                  ? null
                                  : updateData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                sedangMenyimpan
                                    ? 'Menyimpan...'
                                    : 'Update',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: sedangMenyimpan
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
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: sedangMenyimpan
                            ? null
                            : bersihkanForm,
                        child: const Text('Bersihkan Form'),
                      ),
                    ],
                  if (sedangMemuat ||
                      pesanError != null ||
                      daftarUser.isEmpty) ...[
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Kembali'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}