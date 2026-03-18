import 'package:flutter/material.dart';
// Detay penceresini açabilmesi için kendi widget'ımızı import ediyoruz
import 'patient_details_dialog.dart';

// SADE HASTA KARTI VE CANLI BİLDİRİM TASARIMI
class PatientCard extends StatelessWidget {
  final dynamic patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Firestore verisini güvenli bir Map olarak alıyoruz
    final Map<String, dynamic> data = patient.data() as Map<String, dynamic>;

    // HATA ÇÖZÜMÜ: Alanların varlığını kontrol ederek değer atıyoruz
    // Eğer 'last_message' yoksa null dönecek ve aşağıdaki bildirim alanı görünmeyecek.
    String? lastMessage = data.containsKey('last_message')
        ? data['last_message']
        : null;
    String status = data.containsKey('status') ? data['status'] : "Stabil";
    String accessCode = data.containsKey('access_code')
        ? data['access_code']
        : "---";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showPatientDetails(context, patient),
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
                  data['patient_name'] ?? 'İsimsiz Hasta',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  "Durum: $status",
                  style: TextStyle(color: Colors.green[700]),
                ),
                trailing: Text(
                  "#$accessCode",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              // CANLI BİLDİRİM ALANI: Bir talep varsa görünür, yoksa yer kaplamaz
              if (lastMessage != null && lastMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
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
