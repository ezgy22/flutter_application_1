import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Servis dosyanı import ediyoruz (Klasör yapına göre yolu kontrol et)
import '../services/database_service.dart';

class CaregiverHomePage extends StatelessWidget {
  const CaregiverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Veritabanı servisimizi tanımlıyoruz
    final DatabaseService _databaseService = DatabaseService();

    return Scaffold(
      // Arka plan için senin seçtiğin ferah yeşil tonu
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        title: const Text(
          "Bakıcı Paneli",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C), // Koyu Yeşil
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Servis üzerinden canlı veri akışını başlatıyoruz
        stream: _databaseService.getMyPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF388E3C)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_disabled,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Henüz bir hasta eklemediniz.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Hastaları listeleme kısmı
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var patient = snapshot.data!.docs[index];
              return _buildPatientCard(context, patient);
            },
          );
        },
      ),
      // Yeni Hasta Ekleme Butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF388E3C),
        onPressed: () => _showAddPatientDialog(context, _databaseService),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  // HASTA KARTI TASARIMI (UI)
  Widget _buildPatientCard(BuildContext context, var patient) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF8BC34A), // Parlak Yeşil
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          patient['patient_name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          "Durum: ${patient['status']}",
          style: TextStyle(color: Colors.green[700]),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            patient['access_code'], // 6 haneli erişim kodu
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
    );
  }

  // YENİ HASTA EKLEME PENCERESİ (DIALOG)
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
          decoration: const InputDecoration(
            hintText: "Hastanın Adı Soyadı",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF388E3C)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await service.addPatient(
                  nameController.text,
                ); // Servis üzerinden kayıt
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
