import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp için eklendi

// YENİ EKLENEN KISIM 1: Düzenleme sayfamızı import ediyoruz
import '../settings_pages/manage_patients_page.dart';

// YENİ EKLENEN KISIM 2: HASTA DETAY PENCERESİ FONKSİYONU
void showPatientDetails(BuildContext context, dynamic patient) {
  Map<String, dynamic> data = patient.data() as Map<String, dynamic>;

  // YENİ MİMARİYE GÖRE DİNAMİK YAŞ HESAPLAMA
  String ageText = "Belirtilmemiş";
  if (data.containsKey('birth_date') && data['birth_date'] != null) {
    DateTime dob = (data['birth_date'] as Timestamp).toDate();
    DateTime today = DateTime.now();
    int years = today.year - dob.year;
    int months = today.month - dob.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    ageText = years == 0 ? "$months Aylık" : "$years Yıl $months Ay";
  } else if (data.containsKey('age')) {
    ageText = data['age']
        .toString(); // Eski düzende eklenmiş hastalar için yedek
  }

  // YENİ MİMARİYE GÖRE HASTALIK ETİKETLERİNİ BİRLEŞTİRME
  String diseaseText = "Belirtilmemiş";
  if (data.containsKey('diseases') && data['diseases'] != null) {
    List<dynamic> dList = data['diseases'];
    if (dList.isNotEmpty) {
      diseaseText = dList.join(', '); // Örn: "Serebral Palsi, Epilepsi"
    }
  } else if (data.containsKey('disease')) {
    diseaseText = data['disease']
        .toString(); // Eski düzende eklenmiş hastalar için yedek
  }

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
          mainAxisSize:
              MainAxisSize.min, // Sadece içindeki yazılar kadar yer kaplar
          children: [
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            _detailRow(Icons.cake, "Yaş", ageText), // Yeni dinamik yaş
            const SizedBox(height: 15),
            _detailRow(
              Icons.local_hospital,
              "Hastalık",
              diseaseText,
            ), // Yeni etiketli hastalıklar
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
              // YENİ DÜZENLEME: Önce popup'ı kapatıyoruz, sonra yönetim sayfasına yönlendiriyoruz
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManagePatientsPage(patientData: patient),
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
