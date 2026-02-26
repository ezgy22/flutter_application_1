import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Oluşturduğumuz sayfaları ana dosyaya tanıtıyoruz (Import)
import 'package:flutter_application_1/screens/login_page.dart';

import 'package:flutter_application_1/screens/caregiver_home_page.dart';

void main() async {
  // Flutter başlatılırken gerekli olan sistem ayarı
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase servislerini başlatıyoruz
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ConnectCareApp());
}

class ConnectCareApp extends StatelessWidget {
  const ConnectCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki Debug bandını kaldırır
      title: 'Connect & Care',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        // Projenin genelindeki yeşil tema ayarı
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF388E3C)),
      ),

      /* ERİŞİLEBİLİRLİK MANTIĞI: StreamBuilder
         Uygulama her açıldığında oturum durumunu kontrol eder. 
         Kullanıcı çıkış yapmamışsa direkt içeri alır, klavye kullanımını azaltır.
      */
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Firebase'den veri beklenirken yükleme çemberi göster
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Eğer giriş yapmış bir kullanıcı varsa ana sayfaya git
          if (snapshot.hasData) {
            return const CaregiverHomePage();
          }
          // Kimse yoksa giriş sayfasına yönlendir
          return const LoginPage();
        },
      ),
    );
  }
}
