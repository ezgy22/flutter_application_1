import 'package:flutter/material.dart';

class ManagePatientsPage extends StatelessWidget {
  const ManagePatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hastalarımı Yönet"),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: const Center(
        child: Text(
          "Hasta Yönetim Sayfası\n(Burada hastaları silebilir veya bilgilerini güncelleyebilirsin)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
