import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Dosya yollarının doğruluğundan emin ol, eğer hata verirse klasör yapına göre düzeltiriz.
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'patient_login_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Bakıcı Giriş Fonksiyonu
  Future<void> _girisYap() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Giriş başarısız!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
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

              // Giriş Alanları
              _buildTextField(_emailController, 'E-posta Adresiniz', false),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, 'Şifreniz', true),
              const SizedBox(height: 25),

              // BAKICI GİRİŞİ
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: _girisYap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8BC34A), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'GİRİŞ YAP',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("veya", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // HASTA GİRİŞİ (BU SEFER KESİN ÇALIŞACAK)
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  onPressed: () {
                    debugPrint("Butona basıldı, sayfaya gidiliyor...");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PatientLoginPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.accessible_forward,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'HASTA GİRİŞİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Alt Linkler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _linkBtn('Şifremi Unuttum', const ForgotPasswordPage()),
                  _linkBtn('Yeni Kayıt Oluştur', const RegisterPage()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isObscure,
  ) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _linkBtn(String text, Widget page) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF689F38))),
    );
  }
}
