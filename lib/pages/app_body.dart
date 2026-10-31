import 'package:flutter/material.dart';

class AppBodyPage extends StatelessWidget {
  const AppBodyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('Eksplorasi Body'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Belajar Widget Flutter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ini contoh isi bagian body',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Icon(
                Icons.school,
                size: 80,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.purple,
                  width: 2,
                ),
              ),
              child: const Text(
                'Halo, Felicya!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 40,
                ),
                Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 40,
                ),
                Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 40,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Siswa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    Text('Nama: Felicya Agatha Susanto Lie'),
                    SizedBox(height: 8),
                    Text('Kelas: XII RPL'),
                    SizedBox(height: 8),
                    Text('Jurusan: Rekayasa Perangkat Lunak'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nama kamu',
                hintText: 'Ketik nama di sini',
                prefixIcon: Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halo! Kamu menekan tombol'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Klik Saya'),
            ),
          ],
        ),
      ),
    );
  }
}