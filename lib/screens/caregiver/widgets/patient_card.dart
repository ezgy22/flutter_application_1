import 'package:flutter/material.dart';
// Detay penceresini açabilmesi için kendi widget'ımızı import ediyoruz
import 'patient_details_dialog.dart';

// SADE HASTA KARTI VE CANLI BİLDİRİM TASARIMI
class PatientCard extends StatelessWidget {
  final dynamic patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Abinden gelen son piktogram mesajı (Su, Yemek vb.)
    String? lastMessage = patient['last_message'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      // YENİ EKLENEN KISIM 1: Karta InkWell sarmalayıcısı ekledik.
      // Bu sayede karta tıklandığında dalga efekti oluşacak ve detay ekranı açılacak.
      child: InkWell(
        borderRadius: BorderRadius.circular(
          20,
        ), // Dalga efektinin köşelerden taşmaması için
        onTap: () => showPatientDetails(
          context,
          patient,
        ), // Tıklayınca detay fonksiyonunu çağırır

        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF8BC34A), // Parlak Yeşil
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  patient['patient_name'], // "ahmet eren"
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  "Durum: ${patient['status']}",
                  style: TextStyle(color: Colors.green[700]),
                ),
                trailing: Text(
                  "#${patient['access_code']}", // Giriş kodu
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              // CANLI BİLDİRİM ALANI: Abin bir butona bastığı an bu kırmızı kutu görünür
              if (lastMessage != null && lastMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        Colors.red[50], // Dikkat çekici hafif kırmızı arka plan
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red[200]!, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notification_important,
                        color: Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "YENİ TALEP: $lastMessage",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
