import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Yeni oluşturduğumuz ayar sayfalarını import ediyoruz
import '../settings_pages/profile_edit_page.dart';
import '../settings_pages/manage_patients_page.dart';
import '../settings_pages/change_password_page.dart';

// AYARLAR MENÜSÜ (Genişletilmiş Kontrol Merkezi - Senin kodun)
void showSettingsMenu(BuildContext context) {
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
          // MENÜ BAŞLIĞI VE ÇİZGİSİ
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Ayarlar",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32), // Koyu yeşil
              ),
            ),
          ),
          const Divider(thickness: 1),

          // 1. PROFİLİ DÜZENLE
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF388E3C)),
            title: const Text(
              "Profili Düzenle",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pop(context); // Önce alttan açılan menüyü kapat
              // Ardından profil düzenleme sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditPage(),
                ),
              );
            },
          ),

          // 2. HASTALARIMI YÖNET
          ListTile(
            leading: const Icon(Icons.people_alt, color: Color(0xFF388E3C)),
            title: const Text(
              "Hastalarımı Yönet",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pop(context); // Menüyü kapat
              // Hasta yönetim sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagePatientsPage(),
                ),
              );
            },
          ),

          // 3. ŞİFRE DEĞİŞTİR
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Color(0xFF388E3C)),
            title: const Text(
              "Şifre Değiştir",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pop(context); // Menüyü kapat
              // Şifre değiştirme sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),

          const Divider(thickness: 1),

          // 4. GÜVENLİ ÇIKIŞ YAP
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Oturumu Kapat",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              // Sadece Firebase oturumunu kapatıyoruz.
              // Yönlendirmeyi main.dart'taki StreamBuilder otomatik yapacak!
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.pop(context); // Sadece alttan açılan menüyü kapat
              }
            },
          ),
        ],
      ),
    ),
  );
}
