import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaregiverHomePage extends StatelessWidget {
  const CaregiverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakıcı Paneli"),
        backgroundColor: const Color(0xFF8BC34A), // Uygulama genel yeşili
        actions: [
          // ÇIKIŞ BUTONU: Firebase oturumunu sonlandırır.
          // authStateChanges sayesinde uygulama bunu anlar ve otomatik Login ekranına döner.
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Oturumunuz Açık! Hoş Geldiniz.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
