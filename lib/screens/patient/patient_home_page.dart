import 'package:flutter/material.dart';
// Sayfayı oluşturduktan sonra buradaki yorum satırını kaldırabilirsin:
// import 'categories/needs_page.dart';

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
                  // HATAYI BURADA DÜZELTTİK: const kaldırıldı ve FontWeight.w900 yapıldı
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
                    // NeedsPage dosyanı oluşturduğunda burayı aktif et:
                    // () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NeedsPage())),
                  ),
                  _buildCategoryButton(
                    context,
                    "SORULAR",
                    Icons.help_center,
                    const Color(0xFF43A047),
                  ),
                  _buildCategoryButton(
                    context,
                    "DUYGULAR",
                    Icons.sentiment_satisfied_alt,
                    const Color(0xFF66BB6A),
                  ),
                  _buildCategoryButton(
                    context,
                    "HABERLEŞME",
                    Icons.record_voice_over,
                    const Color(0xFF81C784),
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
    Color color, [
    VoidCallback? onTap,
  ]) {
    return InkWell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title sayfası yakında eklenecek.")),
            );
          },
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
}
