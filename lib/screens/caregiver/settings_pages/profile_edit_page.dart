import 'package:flutter/material.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: const Center(
        child: Text(
          "Profil Düzenleme Sayfası\n(Burada bakıcı kendi bilgilerini güncelleyecek)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
