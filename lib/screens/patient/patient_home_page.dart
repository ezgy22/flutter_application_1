import 'package:flutter/material.dart'; // Flutter'ın temel tasarım paketini içeri aktarıyoruz.
// Aşağıdakiler bizim oluşturduğumuz diğer odalar (sayfalar). Onları buraya tanıtıyoruz:
import 'categories/needs_page.dart';
import 'categories/questions_page.dart';
import 'categories/emotions_page.dart';
import 'categories/chat_page.dart';

// StatelessWidget: Bu sayfa üzerindeki veriler (butonların yerleri vs.) uygulama açıkken değişmeyecek demektir.
class PatientHomePage extends StatelessWidget {
  final String
  patientName; // Giriş ekranından gelen hasta ismini burada tutuyoruz.

  // Constructor (Yapıcı): Bu sınıf çağrıldığında hasta isminin gönderilmesi zorunludur ({required ...}).
  const PatientHomePage({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    // Scaffold: Sayfanın iskeletidir. AppBar, Body ve BottomNavigationBar gibi alanları yönetir.
    return Scaffold(
      backgroundColor: const Color(
        0xFFE8F5E9,
      ), // Arka planı yumuşak bir yeşil yapıyoruz.
      // Üst Bilgi Çubuğu
      appBar: AppBar(
        title: Text(
          "Merhaba, $patientName", // Girişte yazdığın ismi buraya yazdırıyoruz.
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32), // AppBar'ın koyu yeşil rengi.
        centerTitle: true, // Başlığı ortala.
        automaticallyImplyLeading:
            false, // Otomatik çıkan "Geri" butonunu kapatır (Ana sayfa olduğu için).
      ),

      // Sayfa İçeriği
      body: Padding(
        padding: const EdgeInsets.all(
          20.0,
        ), // Kenarlardan 20 birim boşluk bırak.
        child: Column(
          children: [
            // Üstteki "Ne Yapmak İstersin?" yazısı
            Expanded(
              flex: 1, // Sayfanın %10-15'lik üst kısmını bu yazıya ayır.
              child: Center(
                child: Text(
                  "Ne Yapmak İstersin?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight
                        .w900, // En kalın yazı tipi (Az önce hata veren yer).
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
            ),

            // Kategori Butonlarının Dizildiği Grid (Izgara) Yapısı
            Expanded(
              flex: 5, // Sayfanın kalan büyük kısmını butonlara ayır.
              child: GridView.count(
                crossAxisCount: 2, // Yan yana 2 buton koy.
                mainAxisSpacing: 20, // Alt-üst buton arası boşluk.
                crossAxisSpacing: 20, // Sağ-sol buton arası boşluk.
                children: [
                  // 1. İHTİYAÇLAR BUTONU
                  _buildCategoryButton(
                    context,
                    "İHTİYAÇLAR",
                    Icons.wc, // Tuvalet/İhtiyaç ikonu
                    const Color(0xFF388E3C),
                    // Navigator.push: "Beni yeni bir sayfaya götür" komutudur.
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NeedsPage(),
                      ),
                    ),
                  ),

                  // 2. SORULAR BUTONU
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

                  // 3. DUYGULAR BUTONU
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

                  // 4. HABERLEŞME BUTONU
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

  // YARDIMCI METOD (Kalıp): 4 butonu da tek tek yazmak yerine bir "kalıp" oluşturduk.
  // Bu metod; başlık, ikon, renk ve tıklama aksiyonunu alıp bize bir buton üretir.
  Widget _buildCategoryButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, // Butona basıldığında yapılacak işi temsil eder.
  ) {
    return InkWell(
      onTap: onTap, // Üstte verdiğimiz Navigator.push burada çalışır.
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(35), // Köşeleri yuvarla.
          boxShadow: [
            // Butonun altına hafif bir gölge atarak "basılabilir" hissi veriyoruz.
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // İçindekileri (ikon ve yazı) ortala.
          children: [
            Icon(icon, size: 80, color: Colors.white), // Beyaz, dev ikon.
            const SizedBox(height: 10), // İkon ile yazı arasına boşluk.
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
}
