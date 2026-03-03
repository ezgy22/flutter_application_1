import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase giriş için eklendi
import 'register_page.dart';
import 'caregiver_home_page.dart';
import 'forgot_password_page.dart'; // Şifremi unuttum sayfasını buraya tanıtıyoruz

class LoginPage extends StatefulWidget {
  // TextField'lar için StatefulWidget yaptık
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Kontrolcüler: Yazılan mail ve şifreyi okumak için
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // GİRİŞ FONKSİYONU
  Future<void> _girisYap() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Giriş başarılı olunca main.dart'taki StreamBuilder bizi içeri alacak.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("E-posta veya şifre hatalı!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          // Ekran kayabilsin diye eklendi
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Icon(
                  Icons.volunteer_activism,
                  size: 90,
                  color: Color(0xFF388E3C),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CONNECT & CARE',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 40),

                // --- GİRİŞ ALANLARI (TEMAYI BOZMADAN EKLENDİ) ---
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
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Şifreniz',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // BAKICI GİRİŞİ BUTONU (Senin istediğin fonksiyonel buton)
                _buildSecondaryButton(context, 'GİRİŞ YAP', _girisYap),

                const SizedBox(height: 20),
                const Text("veya", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                // HASTA GİRİŞİ BUTONU (Tasarımın korundu)
                _buildMainButton(
                  context,
                  'HASTA GİRİŞİ',
                  const Color(0xFF8BC34A),
                  Icons.accessible_forward,
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LoginPage içindeki o satırı bul ve bununla değiştir:
                    _linkText('Şifremi Unuttum', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    }),
                    _linkText('Yeni Kayıt Oluştur', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _linkText(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(text, style: const TextStyle(color: Color(0xFF689F38))),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      height: 65, // Boyutu biraz optimize edildi
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF8BC34A), width: 2),
          backgroundColor: Colors.white, // Daha belirgin olması için
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
