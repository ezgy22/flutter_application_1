import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient/patient_home_page.dart';

class PatientLoginPage extends StatefulWidget {
  const PatientLoginPage({super.key});

  @override
  State<PatientLoginPage> createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _hastaGirisYap() async {
    String girilenKod = _codeController.text.trim();

    if (girilenKod.length < 6) {
      _mesajGoster("Lütfen 6 haneli kodu eksiksiz girin.", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // SIHIRLI SATIR: Firebase'e gidip "Binlerce hasta arasından sadece bu koda sahip olanı getir" diyoruz.
      var sorgu = await FirebaseFirestore.instance
          .collection('patients')
          .where('access_code', isEqualTo: girilenKod)
          .get();

      if (sorgu.docs.isNotEmpty) {
        var hastaVerisi = sorgu.docs.first.data();
        String hastaAdi = hastaVerisi['patient_name'] ?? "Hasta";

        if (mounted) {
          _mesajGoster("Hoş geldin, $hastaAdi!", Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PatientHomePage(patientName: hastaAdi),
            ),
          );
          // NOT: Buraya ileride yapacağımız PatientHomePage yönlendirmesi gelecek.
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PatientHomePage()));
        }
      } else {
        if (mounted) {
          _mesajGoster(
            "Hatalı kod! Lütfen bakıcınızdan yeni kod isteyin.",
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _mesajGoster("Bağlantı hatası: ${e.toString()}", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mesajGoster(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: renk,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F5E9),
      // AppBar'daki geri tuşu otomatik olarak LoginPage'e döner.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF388E3C)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.vpn_key_outlined,
                size: 100,
                color: Color(0xFF388E3C),
              ),
              const SizedBox(height: 20),
              const Text(
                "HASTA GİRİŞİ",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Size verilen 6 haneli kodu giriniz",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _codeController,
                // KLAVYE AYARI: Sadece rakam klavyesi açılır.
                keyboardType: TextInputType.number,
                // SINIRLAMA: 6 haneden fazlasını yazdırmaz.
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "000000",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade300,
                    letterSpacing: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _hastaGirisYap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SİSTEME BAĞLAN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
