import 'package:flutter/material.dart';

// YENİ EKLENEN KISIM 2: HASTA DETAY PENCERESİ FONKSİYONU
void showPatientDetails(BuildContext context, dynamic patient) {
  // Veritabanında şu an yaş/hastalık kaydı yok. Program çökmesin diye "null" kontrolü yapıyoruz.
  Map<String, dynamic> data = patient.data() as Map<String, dynamic>;
  String age = data.containsKey('age')
      ? data['age'].toString()
      : "Belirtilmemiş";
  String disease = data.containsKey('disease')
      ? data['disease']
      : "Belirtilmemiş";

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF388E3C),
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                patient['patient_name'] ?? 'Bilinmeyen Hasta',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize
              .min, // Sadece içindeki yazılar kadar yer kaplar, ekranı doldurmaz
          children: [
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            _detailRow(Icons.cake, "Yaş", age),
            const SizedBox(height: 15),
            _detailRow(Icons.local_hospital, "Hastalık", disease),
            const SizedBox(height: 15),
            _detailRow(
              Icons.monitor_heart,
              "Durum",
              patient['status'] ?? "Bilinmiyor",
            ),
            const SizedBox(height: 15),
            _detailRow(
              Icons.vpn_key,
              "Giriş Kodu",
              "#${patient['access_code']}",
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Kapat",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Düzenleme sayfası yakında eklenecek!"),
                ),
              );
            },
            child: const Text("Düzenle", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

// YENİ EKLENEN KISIM 3: Detay penceresindeki satırların (İkon + Yazı) şık tasarımı
Widget _detailRow(IconData icon, String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: const Color(0xFF388E3C), size: 24),
      const SizedBox(width: 12),
      Text(
        "$title: ",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    ],
  );
}
