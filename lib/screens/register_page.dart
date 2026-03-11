import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Sadeleştirilmiş bakıcı paneli sayfamızı import ediyoruz
import 'caregiver/caregiver_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // FORM DENETLEYİCİLERİ: Kullanıcının klavyeden girdiği metinleri (Ad, E-posta, Şifre) buradan yönetiyoruz.
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  // ASIL MOTOR FONKSİYON: Firebase Kayıt İşlemi
  // 'async' kelimesi bu işlemin internet hızıyla bağlantılı olarak zaman alabileceğini belirtir.
  Future<void> _kayitOl() async {
    // ERİŞİLEBİLİRLİK: Butona basıldığı an klavyeyi kapatır, böylece arkadaki SnackBar veya geçişler rahat görülür.
    FocusScope.of(context).unfocus();

    // Validasyon: Boş alan bırakılmamasını kontrol ediyoruz (Hata almamak için önemli)
    if (_adController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _sifreController.text.isEmpty) {
      _hataGoster("Lütfen tüm alanları doldurunuz.");
      return;
    }

    try {
      // 1. ADIM: Firebase Auth ile e-posta ve şifreyi buluta güvenli bir şekilde kaydet.
      // Bu adım başarılı olursa Firebase bize benzersiz bir 'uid' (User ID) verir.
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _sifreController.text.trim(),
          );

      // 2. ADIM: Kullanıcının profil bilgilerini Firestore veritabanına yaz.
      // 'users' koleksiyonu altında kullanıcının 'uid'si ile bir döküman oluşturuyoruz.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'ad_soyad': _adController.text.trim(),
            'email': _emailController.text.trim(),
            'rol':
                'bakici', // Projemizde kullanıcı varsayılan olarak 'bakıcı' rolünde başlar.
            'kayit_tarihi':
                FieldValue.serverTimestamp(), // Zaman damgası veritabanı sunucusundan alınır.
          });

      // 3. ADIM: Kayıt bitince kullanıcıya mesaj ver ve GİRİŞ SAYFASINA yönlendir. (Profesyonel Akış)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt Başarılı! Lütfen giriş yapınız.'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );

        // ÖNEMLİ: Firebase kayıt olunca otomatik oturum açar. Güvenlik için onu kapatıp
        // kullanıcının kendi şifresiyle tekrar girmesini sağlıyoruz.
        await FirebaseAuth.instance.signOut();

        // Navigator.pop: Bulunduğumuz Kayıt sayfasını kapatır ve altta zaten bekleyen Giriş sayfasına düşeriz.
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // ÖZEL HATA YÖNETİMİ: Firebase'den gelen hataları (örn: e-posta kullanımda) yakalarız.
      String mesaj = "Bir hata oluştu.";
      if (e.code == 'email-already-in-use')
        mesaj = "Bu e-posta adresi zaten kullanımda.";
      if (e.code == 'weak-password')
        mesaj = "Şifreniz çok zayıf (En az 6 karakter).";

      _hataGoster(mesaj);
    } catch (e) {
      _hataGoster("Beklenmedik bir hata: ${e.toString()}");
    }
  }

  // Yardımcı Metot: Kırmızı hata mesajı gösterir
  void _hataGoster(String mesaj) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mesaj), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8F1,
      ), // Uygulama genelindeki ferah yeşil tonu
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        // Ekran küçükse veya klavye açılınca içeriğin kaymasını sağlar
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1_outlined,
              size: 80,
              color: Color(0xFF388E3C),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yeni Kayıt',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bakıcı olarak hemen profilini oluştur.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // GİRİŞ ALANLARI (TextFields)
            _buildField(_adController, 'Ad Soyad', Icons.person_outline),
            const SizedBox(height: 15),
            _buildField(
              _emailController,
              'E-posta Adresi',
              Icons.email_outlined,
            ),
            const SizedBox(height: 15),
            _buildField(
              _sifreController,
              'Güçlü Bir Şifre Belirleyin',
              Icons.lock_outline,
              isPass: true,
            ),

            const SizedBox(height: 40),

            // KAYIT OL BUTONU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _kayitOl, // Yukarıdaki motor fonksiyonu tetikler
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'KAYIT OL VE BAŞLA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mevcut hesaba geri dönme linki
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Zaten bir hesabım var, Giriş Yap",
                style: TextStyle(color: Color(0xFF388E3C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // YARDIMCI TASARIM METODU: Kod tekrarını önlemek ve ekranın sade kalmasını sağlamak için.
  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPass = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass, // Şifreyi yıldız şeklinde gizler
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF388E3C)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        // Kutucuğa tıklandığında oluşacak yeşil çerçeve
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5),
        ),
      ),
    );
  }
}
