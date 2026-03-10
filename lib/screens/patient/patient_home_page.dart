import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Giriş sayfasına dönebilmek için login_page.dart'ı çağırıyoruz
import '../login_page.dart';
// Aşağıdakiler bizim oluşturduğumuz diğer odalar (sayfalar).
import 'categories/needs_page.dart';
import 'categories/questions_page.dart';
import 'categories/emotions_page.dart';
import 'categories/chat_page.dart';

class PatientHomePage extends StatelessWidget {
  final String patientName;

  const PatientHomePage({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        automaticallyImplyLeading: false,
        actions: [
          // GÜVENLİ ÇIKIŞ BUTONU (Ayarlar İkonu)
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            onPressed: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "Ne Yapmak İstersin?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 5,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildCategoryButton(
                    context,
                    "İHTİYAÇLAR",
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
                    "SORULAR",
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
                    "HABERLEŞME",
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

  // --- HASTA İÇİN ÖZEL GÜVENLİ ÇIKIŞ ONAY EKRANI ---
  void _showLogoutConfirmation(BuildContext context) {
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
                  "ÇIKIŞ YAPMAK\nİSTEDİĞİNE EMİN MİSİN?",
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
                    // 1. KIRMIZI ÇARPI (Hayır, sayfada kal)
                    GestureDetector(
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

                    // 2. YEŞİL TİK (Evet, çıkış yap ve Login'e dön)
                    GestureDetector(
                      onTap: () async {
                        // Firebase'den çıkış yap
                        await FirebaseAuth.instance.signOut();

                        // Eğer sayfa hala ekrandaysa Login sayfasına kökten dönüş yap
                        if (context.mounted) {
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
