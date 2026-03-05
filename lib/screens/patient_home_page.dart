import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHomePage extends StatefulWidget {
  final String patientName;
  const PatientHomePage({super.key, required this.patientName});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  // Bakıcıya bildirim gönderme fonksiyonu (Şimdilik sadece ekrana mesaj basar)
  void _talepGonder(String talepAdi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$talepAdi talebiniz bakıcınıza iletildi."),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    // İleride buraya Firestore'a "bildirimler" koleksiyonuna veri yazma kodunu ekleyeceğiz.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Hafif yeşil ferah arka plan
      appBar: AppBar(
        title: Text("Hoş geldin, ${widget.patientName}"),
        backgroundColor: const Color(0xFF388E3C),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Geri tuşunu kaldırdık (hasta yanlışlıkla çıkmasın)
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context), // Çıkış butonu
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2, // Yan yana 2 buton
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildPictogramButton(
              "SU İSTE",
              Icons.local_drink,
              Colors.blue,
              "Su",
            ),
            _buildPictogramButton(
              "YEMEK İSTE",
              Icons.restaurant,
              Colors.orange,
              "Yemek",
            ),
            _buildPictogramButton(
              "İLAÇ VAKTİ",
              Icons.medication,
              Colors.red,
              "İlaç",
            ),
            _buildPictogramButton(
              "YARDIM ÇAĞIR",
              Icons.front_hand,
              Colors.purple,
              "Yardım",
            ),
            _buildPictogramButton("TUVALET", Icons.wc, Colors.brown, "Tuvalet"),
            _buildPictogramButton(
              "İYİYİM",
              Icons.sentiment_very_satisfied,
              Colors.teal,
              "İyiyim",
            ),
          ],
        ),
      ),
    );
  }

  // Piktogram Buton Tasarımı
  Widget _buildPictogramButton(
    String title,
    IconData icon,
    Color color,
    String talep,
  ) {
    return InkWell(
      onTap: () => _talepGonder(talep),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
