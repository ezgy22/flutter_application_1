import 'package:flutter/material.dart';

class ConsoleWidget extends StatelessWidget {
  // Bu sayfayı nerede kullanırsak kullanalım, "Onay" butonuna basınca ne olacağını
  // o sayfa kendisi belirlesin diye bu fonksiyonu dışarıdan alıyoruz.
  final VoidCallback onConfirm;

  // Geri ve Ana Sayfa butonları için opsiyonel fonksiyonlar
  // (Eğer boş bırakılırlarsa otomatik olarak sayfa kapatma/ana menüye dönme işini yaparlar)
  final VoidCallback? onBack;
  final VoidCallback? onHome;

  const ConsoleWidget({
    super.key,
    required this.onConfirm,
    this.onBack,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // Eren'in rahat basabilmesi için yüksek tuttuk
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. GERİ BUTONU (Turuncu - Uyarıcı ama güvenli)
          _buildNavButton(
            Icons.undo,
            "VAZGEÇ",
            Colors.orange.shade800,
            onBack ??
                () => Navigator.pop(
                  context,
                ), // Eğer özel bir işlem verilmediyse önceki sayfaya dön
          ),

          // 2. DEV ONAY BUTONU (Yeşil - Gönderim)
          GestureDetector(
            onTap: onConfirm, // Sayfa bize ne gönderdiyse onu çalıştıracak
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.check, size: 60, color: Colors.white),
            ),
          ),

          // 3. ANA SAYFA BUTONU (Koyu Yeşil)
          _buildNavButton(
            Icons.home_filled,
            "ANA MENÜ",
            const Color(0xFF1B5E20),
            onHome ??
                () => Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                ), // En başa (4 kategoriye) dön
          ),
        ],
      ),
    );
  }

  // Kumanda içindeki küçük butonların (Geri, Ana Menü) tasarımı
  Widget _buildNavButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback action,
  ) {
    return InkWell(
      onTap: action,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 45, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
