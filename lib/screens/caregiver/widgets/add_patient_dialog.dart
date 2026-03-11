import 'package:flutter/material.dart';
// Veritabanı sorgularımızı yapan servis (Klasör yolunu kontrol et - 3 üst klasöre çıkıyoruz)
import '../../../services/database_service.dart';

// HASTA EKLEME DİALOGU (Kendi yazdığın yapıyı koruduk)
void showAddPatientDialog(BuildContext context, DatabaseService service) {
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
