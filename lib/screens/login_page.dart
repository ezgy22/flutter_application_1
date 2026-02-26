import 'package:flutter/material.dart';
// Kayıt sayfasına yönlendirme yapabilmek için import ediyoruz
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka plan için sakinleştirici çok açık bir yeşil tonu
      backgroundColor: const Color(0xFFE9F5E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Uygulama Logosu: Yardımlaşmayı temsil eden bir ikon
              const Icon(
                Icons.volunteer_activism,
                size: 90,
                color: Color(0xFF388E3C),
              ),
              const SizedBox(height: 16),
              // Uygulama İsmi
              const Text(
                'CONNECT & CARE',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 60),

              // ERİŞİLEBİLİRLİK NOTU: Serebral Palsili bireylerin kolayca
              // basabilmesi için yüksekliği (75) artırılmış büyük buton.
              _buildMainButton(
                context,
                'HASTA GİRİŞİ',
                const Color(0xFF8BC34A),
                Icons.accessible_forward,
              ),
              const SizedBox(height: 20),

              // Bakıcılar için ikincil buton tasarımı
              _buildSecondaryButton(context, 'Bakıcı / Ebeveyn Girişi'),

              const SizedBox(height: 40),

              // Alt Linkler: Şifre sıfırlama ve Yeni Kayıt
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _linkText('Şifremi Unuttum', () {}),
                  _linkText('Yeni Kayıt Oluştur', () {
                    // Kullanıcıyı kayıt olma sayfasına gönderir
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // YARDIMCI METOT: Link şeklindeki metinler için
  Widget _linkText(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(text, style: const TextStyle(color: Color(0xFF689F38))),
    );
  }

  // YARDIMCI METOT: Ana büyük buton tasarımı
  Widget _buildMainButton(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      height: 75,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // YARDIMCI METOT: Çerçeveli (Outlined) buton tasarımı
  Widget _buildSecondaryButton(BuildContext context, String text) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF8BC34A), width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
