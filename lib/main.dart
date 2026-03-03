import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// EKRANLAR: Oluşturduğumuz sayfaları projeye dahil ediyoruz.
import 'package:flutter_application_1/screens/login_page.dart';
import 'package:flutter_application_1/screens/caregiver_home_page.dart';

void main() async {
  // FLUTTER BAŞLATICI: Flutter motorunun widgetları çizmeden önce hazır olmasını sağlar.
  WidgetsFlutterBinding.ensureInitialized();

  // FIREBASE BAŞLATICI: Uygulamanın bulut servislerine (Auth, Firestore) bağlanmasını sağlar.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ConnectCareApp());
}

class ConnectCareApp extends StatelessWidget {
  const ConnectCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Sağ üstteki 'Debug' bandını kaldırarak profesyonel bir görünüm sağlar.
      title: 'Connect & Care',

      // TEMA AYARLARI: Uygulamanın genelinde senin seçtiğin yeşil tonlarını (Material 3) tanımlıyoruz.
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        // Ana renk şeması: Yeşil (0xFF388E3C)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF388E3C),
          primary: const Color(0xFF388E3C),
          secondary: const Color(0xFF8BC34A),
        ),
      ),

      /* OTURUM YÖNETİMİ (Persistent Login):
         StreamBuilder, Firebase'deki oturum durumunu canlı (real-time) olarak dinler.
         Bakıcı bir kez giriş yaptıysa, cihaz hafızasında oturum tutulur. 
         Böylece uygulama her açıldığında şifre sormadan direkt panele yönlendirilir.
      */
      home: StreamBuilder<User?>(
        // 'authStateChanges' metodu, kullanıcının giriş/çıkış durumunu anlık takip eder.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. ADIM: Firebase'den cevap beklenirken boş ekran yerine yükleme animasyonu gösterilir.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF1F8F1),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF388E3C)),
              ),
            );
          }

          // 2. ADIM: Eğer bir kullanıcı verisi (snapshot.hasData) varsa...
          if (snapshot.hasData) {
            // Kullanıcı zaten giriş yapmış demektir, direkt sadeleşmiş 'Bakıcı Paneli'ne gönder.
            return const CaregiverHomePage();
          }

          // 3. ADIM: Eğer giriş yapmış bir kullanıcı yoksa...
          // Kullanıcıyı ilk karşılama ekranına (Giriş Sayfası) yönlendir.
          return const LoginPage();
        },
      ),
    );
  }
}
