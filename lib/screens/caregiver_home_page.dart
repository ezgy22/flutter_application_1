import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Veritabanı sorgularımızı yapan servis (Klasör yolunu kontrol et)
import '../services/database_service.dart';

class CaregiverHomePage extends StatelessWidget {
  const CaregiverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Veritabanı servisini tanımlıyoruz
    final DatabaseService _databaseService = DatabaseService();

    return Scaffold(
      // Arka plan için ferah ve sakinleştirici yeşil tonu
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        title: const Text(
          "BAKICI PANELİ",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C), // Koyu Yeşil
        elevation: 0, // Sade görünüm için gölgeyi kaldırdık
        actions: [
          // Üst sağdaki Ayarlar İkonu: İleride hesap ve hasta yönetimi buraya gelecek
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore'u canlı (real-time) dinliyoruz. Abin bir şeye bastığı an burası yenilenir.
        stream: _databaseService.getMyPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF388E3C)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Henüz kayıtlı bir hasta bulunmuyor.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // Hastaları listeleme kısmı
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var patient = snapshot.data!.docs[index];
              return _buildNotificationCard(context, patient);
            },
          );
        },
      ),
      // Yeni Hasta Ekleme: Hızlı erişim için sağ altta durmaya devam ediyor
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF388E3C),
        onPressed: () => _showAddPatientDialog(context, _databaseService),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  // SADE HASTA KARTI VE CANLI BİLDİRİM TASARIMI
  Widget _buildNotificationCard(BuildContext context, var patient) {
    // Abinden gelen son piktogram mesajı (Su, Yemek vb.)
    String? lastMessage = patient['last_message'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    );
  }

  // AYARLAR MENÜSÜ (Şimdilik sadece Çıkış var)
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Oturumu Kapat",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Menüyü kapat
                // main.dart'taki StreamBuilder sayesinde otomatik olarak LoginPage'e dönecektir.
              },
            ),
          ],
        ),
      ),
    );
  }

  // HASTA EKLEME DİALOGU (Kendi yazdığın yapıyı koruduk)
  void _showAddPatientDialog(BuildContext context, DatabaseService service) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Yeni Hasta Ekle",
          style: TextStyle(color: Color(0xFF2E7D32)),
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Hastanın Adı Soyadı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await service.addPatient(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
