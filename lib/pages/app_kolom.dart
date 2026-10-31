import 'package:flutter/material.dart';

class AppKolomPage extends StatelessWidget {
  const AppKolomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belajar Column'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 80,
              color: Colors.red,
              alignment: Alignment.center,
              child: const Text(
                'Kotak 1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 80,
              color: Colors.green,
              alignment: Alignment.center,
              child: const Text(
                'Kotak 2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 80,
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text(
                'Kotak 3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}