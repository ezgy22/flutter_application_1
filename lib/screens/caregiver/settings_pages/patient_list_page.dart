import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Veritabanı servisini ve gerekli sayfaları import ediyoruz
import '../../../services/database_service.dart';
import '../widgets/add_patient_dialog.dart';
import 'manage_patients_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        title: const Text(
          "HASTALARIMI YÖNET",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // SAĞ ALTTAKİ ARTI (+) BUTONU - DÜZELTİLEN KISIM BURASI
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Senin yazdığın özel fonksiyonu çağırıyoruz!
          showAddPatientDialog(context, DatabaseService());
        },
        backgroundColor: const Color(0xFF388E3C),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // HASTALARIN LİSTELENDİĞİ ALAN
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .orderBy('updated_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF388E3C)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Henüz kayıtlı hastanız bulunmuyor.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final patients = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              var patient = patients[index];
              var data = patient.data() as Map<String, dynamic>;
              String patientName = data['patient_name'] ?? 'İsimsiz Hasta';

              // SOLA KAYDIRARAK SİLME MANTIĞI (DISMISSIBLE)
              return Dismissible(
                key: Key(patient.id),
                direction: DismissDirection
                    .endToStart, // Sadece sağdan sola kaydırmaya izin ver
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.delete_sweep,
                    color: Colors.white,
                    size: 32,
                  ), // Kırmızılaşınca çıkan ikon
                ),
                confirmDismiss: (direction) async {
                  // KAYDIRINCA ÇIKACAK OLAN "EMİN MİSİNİZ?" UYARISI
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "Hastayı Sil",
                        style: TextStyle(color: Colors.red),
                      ),
                      content: Text(
                        "$patientName isimli hastayı sistemden silmek istediğinize emin misiniz?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false), // İptal
                          child: const Text(
                            "İptal",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.of(
                            context,
                          ).pop(true), // Silmeye onay ver
                          child: const Text(
                            "SİL",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  // ONAY VERİLDİYSE VERİTABANINDAN SİL
                  await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(patient.id)
                      .delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$patientName silindi."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFC8E6C9),
                      child: Icon(Icons.person, color: Color(0xFF2E7D32)),
                    ),
                    title: Text(
                      patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      "Durum: ${data['status'] ?? 'Bilinmiyor'}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: const Icon(
                      Icons.swipe_left,
                      color: Colors.grey,
                    ), // Kullanıcıya "sola kaydır" ipucu verir
                    onTap: () {
                      // Karta tıklayınca senin o detaylı düzenleme sayfasına gider
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ManagePatientsPage(patientData: patient),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
