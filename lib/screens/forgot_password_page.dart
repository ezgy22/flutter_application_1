import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  Future<void> _sifreSifirla() async {
    if (_emailController.text.trim().isEmpty) {
      _mesajGoster("Lütfen e-posta adresinizi yazın.", Colors.orange);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      _mesajGoster(
        "Şifre sıfırlama bağlantısı gönderildi! E-postanızı kontrol edin.",
        Colors.green,
      );

      // Mesajdan kısa bir süre sonra giriş sayfasına geri döner
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      _mesajGoster("Hata: E-posta adresi bulunamadı.", Colors.red);
    }
  }

  void _mesajGoster(String mesaj, Color renk) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: renk));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F5E9), // Temanı koruyoruz
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 100, color: Color(0xFF388E3C)),
            const SizedBox(height: 20),
            const Text(
              "Şifrenizi mi Unuttunuz?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "E-posta adresinizi girin, size şifrenizi yenilemeniz için bir bağlantı gönderelim.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // E-posta Kutusu
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'E-posta Adresiniz',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.green),
              ),
            ),
            const SizedBox(height: 25),

            // Sıfırlama Butonu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _sifreSifirla,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "ŞİFREYİ SIFIRLA",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
