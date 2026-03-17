import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Veritabanı sorgularımızı yapan servis (Klasör yolunu kontrol et)
import '../../services/database_service.dart';

// Küçük widget parçalarımızı çağırıyoruz
import 'widgets/settings_bottom_sheet.dart';
import 'widgets/add_patient_dialog.dart';
import 'widgets/patient_card.dart';

// Profil Düzenleme sayfamızı çağırıyoruz
import 'settings_pages/profile_edit_page.dart';

class CaregiverHomePage extends StatelessWidget {
  const CaregiverHomePage({super.key});

  // GÜNCELLENEN KISIM: Veritabanından isim ve rol çeken, butonu küçültülmüş Pop-up
  void _showProfilePopup(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          contentPadding: const EdgeInsets.all(25),
          content: FutureBuilder<DocumentSnapshot>(
            // Firestore'dan o anki kullanıcının verilerini çekiyoruz
            future: FirebaseFirestore.instance
                .collection('caregivers')
                .doc(user?.uid)
                .get(),
            builder: (context, snapshot) {
              // Varsayılan metinler (Veri yüklenene kadar veya boşsa görünür)
              String name = "İsimsiz Bakıcı";
              String role = "Rol Belirtilmemiş";

              // Veriler yüklenirken küçük bir yüklenme ikonu göster
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF388E3C)),
                  ),
                );
              }

              // Veritabanında kayıt varsa isim ve rolü güncelle
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                name = data['name'] ?? name;
                role = data['role'] ?? role;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFC8E6C9),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Veritabanından gelen AD SOYAD
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),

                  // Veritabanından gelen ROL (Örn: Anne, Fizyoterapist)
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Firebase'den gelen E-POSTA
                  Text(
                    user?.email ?? "Bilinmeyen Kullanıcı",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 25),

                  // GÜNCELLENEN BUTON: Daha zarif ve ortalanmış tasarım
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Önce pop-up'ı kapat
                      // Profil Düzenleme sayfasına git
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    label: const Text(
                      "Profili Düzenle",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ), // Daha yuvarlak (Hap) tasarım
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ), // Genişliği esnetmek yerine padding verdik
                      elevation: 0,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Veritabanı servisini tanımlıyoruz
    final DatabaseService _databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        // Sol üst profil ikonu (leading)
        leading: IconButton(
          icon: const Icon(Icons.account_circle, size: 30, color: Colors.white),
          onPressed: () => _showProfilePopup(context),
        ),
        title: const Text(
          "BAKICI PANELİ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C),
        elevation: 0,
        actions: [
          // Ayarlar İkonu
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => showSettingsMenu(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var patient = snapshot.data!.docs[index];
              return PatientCard(patient: patient);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF388E3C),
        onPressed: () => showAddPatientDialog(context, _databaseService),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
