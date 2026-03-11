import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Veritabanı sorgularımızı yapan servis (Klasör yolunu kontrol et)
import '../../services/database_service.dart';

// YENİ MİMARİ: Küçük widget parçalarımızı çağırıyoruz
import 'widgets/settings_bottom_sheet.dart';
import 'widgets/add_patient_dialog.dart';
import 'widgets/patient_card.dart';

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
            onPressed: () => showSettingsMenu(
              context,
            ), // Parçaladığımız ayarlar menüsü çalışıyor
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
              // YENİ MİMARİ: Artık kod kalabalığı yok, sadece özel Kartımızı çağırıyoruz!
              return PatientCard(patient: patient);
            },
          );
        },
      ),
      // Yeni Hasta Ekleme: Hızlı erişim için sağ altta durmaya devam ediyor
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF388E3C),
        onPressed: () => showAddPatientDialog(
          context,
          _databaseService,
        ), // Parçaladığımız ekleme penceresi
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
