import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Çıkış sonrası kullanıcıyı giriş ekranına güvenli şekilde yönlendirmek için gerekli sayfa.
import '../login_page.dart';
// Ana ekrandaki kategori kartlarının açacağı alt sayfalar.
import 'categories/needs_page.dart';
import 'categories/food_page.dart';
import 'categories/health_page.dart';
import 'categories/questions_page.dart';
import 'categories/emotions_page.dart';
import 'categories/chat_page.dart';

class PatientHomePage extends StatelessWidget {
  final String patientName;

  const PatientHomePage({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Açık yeşil arka plan, hastaya sakin ve tutarlı bir ana ekran hissi verir.
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: Text(
          "Merhaba, $patientName",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        // Geri oku kapatılarak kullanıcının yanlışlıkla bu ekrandan geri çıkması önlenir.
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 30),
            // Çıkışı doğrudan yapmak yerine önce onay diyaloğu gösterilir.
            onPressed: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Üst başlık alanı, ekranın amacını ilk bakışta anlaşılır hale getirir.
            const Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "Ne Yapmak İstersin?", // DÜZELTİLDİ
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              // Kategoriler iki sütunda gösterilerek erişim hızlandırılır ve görsel denge korunur.
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  // Her kategori kartı ilgili sayfaya yönlendirilen bir giriş noktasıdır.
                  _buildCategoryButton(
                    context,
                    "İHTİYAÇLAR", // DÜZELTİLDİ
                    Icons.wc,
                    const Color(0xFF388E3C),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NeedsPage(),
                      ),
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    "BESLENME",
                    // Beslenme kategorisini daha anlasilir gostermek icin yemek ikonu kullanildi.
                    Icons.restaurant_menu,
                    const Color(0xFF4CAF50),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FoodPage()),
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    "SA\u011eLIK",
                    // Saglik/semptom kategorisini daha net anlatmak icin medikal ikon secildi.
                    Icons.health_and_safety,
                    const Color(0xFF43A047),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthPage(),
                      ),
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    "SORULAR",
                    // help_center ikonu soru/yardım içeriğini daha net çağrıştırdığı için seçildi.
                    Icons.help_center,
                    const Color(0xFF43A047),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuestionsPage(),
                      ),
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    "DUYGULAR",
                    Icons.sentiment_satisfied_alt,
                    const Color(0xFF66BB6A),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmotionsPage(),
                      ),
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    "HABERLEŞME", // DÜZELTİLDİ
                    Icons.record_voice_over,
                    const Color(0xFF81C784),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      // Tek bir yardımcı metot kullanmak, kart tasarımını merkezi ve sürdürülebilir tutar.
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    // Yanlışlıkla dokunma ile çıkışı engellemek için kullanıcıdan açık onay alınır.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 90,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                const Text(
                  "ÇIKIŞ YAPMAK\nİSTEDİĞİNE EMİN MİSİN?", // DÜZELTİLDİ
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      // Kırmızı seçenek sadece diyaloğu kapatır, oturum bilgisine dokunmaz.
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // Firebase oturumu kapatılarak kullanıcının hesabı güvenli şekilde sonlandırılır.
                        await FirebaseAuth.instance.signOut();

                        if (context.mounted) {
                          // mounted kontrolü, async sonrası geçersiz context kullanım hatasını önler.
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
