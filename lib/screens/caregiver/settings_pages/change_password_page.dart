import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifre Değiştir"),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: const Center(
        child: Text(
          "Şifre Değiştirme Sayfası\n(Güvenlik ayarları buraya gelecek)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
