import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Düzenleme sayfamızı import ediyoruz
import '../settings_pages/manage_patients_page.dart';

// HASTA DETAY PENCERESİ FONKSİYONU
void showPatientDetails(BuildContext context, dynamic patient) {
  // Veriyi güvenli bir harita (Map) olarak alıyoruz
  Map<String, dynamic> data = patient.data() as Map<String, dynamic>;

  // 1. YAŞ HESAPLAMA (GÜVENLİ)
  String ageText = "Belirtilmemiş";
  if (data.containsKey('birth_date') && data['birth_date'] != null) {
    try {
      DateTime dob = (data['birth_date'] as Timestamp).toDate();
      DateTime today = DateTime.now();
      int years = today.year - dob.year;
      int months = today.month - dob.month;
      if (months < 0) {
        years--;
        months += 12;
      }
      ageText = years == 0 ? "$months Aylık" : "$years Yıl $months Ay";
    } catch (e) {
      ageText = "Tarih Hatası";
    }
  } else if (data.containsKey('age')) {
    ageText = data['age'].toString();
  }

  // 2. HASTALIK ETİKETLERİ (GÜVENLİ)
  String diseaseText = "Belirtilmemiş";
  if (data.containsKey('diseases') && data['diseases'] != null) {
    List<dynamic> dList = data['diseases'];
    if (dList.isNotEmpty) {
      diseaseText = dList.join(', ');
    }
  } else if (data.containsKey('disease')) {
    diseaseText = data['disease'].toString();
  }

  // 3. DURUM VE KOD (GÜVENLİ)
  // containskKey kontrolü ile hata (Exception) almanı engelliyoruz
  String statusText = data.containsKey('status')
      ? data['status']
      : "Bilinmiyor";
  String accessCodeText = data.containsKey('access_code')
      ? "#${data['access_code']}"
      : "Tanımlanmadı";

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
                data['patient_name'] ?? 'Bilinmeyen Hasta',
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            _detailRow(Icons.cake, "Yaş", ageText),
            const SizedBox(height: 15),
            _detailRow(Icons.local_hospital, "Hastalık", diseaseText),
            const SizedBox(height: 15),
            _detailRow(Icons.monitor_heart, "Durum", statusText),
            const SizedBox(height: 15),
            _detailRow(Icons.vpn_key, "Giriş Kodu", accessCodeText),
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
