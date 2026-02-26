import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Kayıt sonrası yönlenecek sayfa
import 'caregiver_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // FORM DENETLEYİCİLERİ: Kutucuklara yazılan verileri buradan okuyoruz
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  // ASIL MOTOR FONKSİYON: Firebase Kayıt İşlemi
  Future<void> _kayitOl() async {
    // ERİŞİLEBİLİRLİK: Butona basıldığı an klavyeyi kapatarak ekranı açar
    FocusScope.of(context).unfocus();

    try {
      // 1. ADIM: Firebase Auth ile e-posta ve şifreyi buluta kaydet
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _sifreController.text.trim(),
          );

      // 2. ADIM: Kullanıcının profil bilgilerini Firestore veritabanına yaz
      // 'users' koleksiyonu altında kullanıcının UID'si ile bir dosya oluşturur
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'ad_soyad': _adController.text.trim(),
            'email': _emailController.text.trim(),
            'rol': 'bakici', // Varsayılan olarak bakıcı rolü atanıyor
            'kayit_tarihi': DateTime.now(),
          });

      // 3. ADIM: Kullanıcıya görsel geri bildirim ver (SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarıyla tamamlandı!'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );

        // 4. ADIM: Kayıt bitince direkt ana sayfaya yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CaregiverHomePage()),
        );
      }
    } catch (e) {
      // HATA YÖNETİMİ: Bir sorun olursa kullanıcıyı kırmızı bir bildirimle uyar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1), // Sakin yeşil zemin
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Text(
              'Yeni Hesap Oluştur',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 40),
            // Giriş Alanları
            _buildField(_adController, 'Ad Soyad', Icons.person_outline),
            const SizedBox(height: 15),
            _buildField(_emailController, 'E-posta', Icons.email_outlined),
            const SizedBox(height: 15),
            _buildField(
              _sifreController,
              'Şifre',
              Icons.lock_outline,
              isPass: true,
            ),

            const SizedBox(height: 40),

            // Kayıt Butonu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _kayitOl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Kayıt Ol',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // YARDIMCI METOT: TextField tasarımı (Kod tekrarını önlemek için)
  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPass = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF388E3C)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
