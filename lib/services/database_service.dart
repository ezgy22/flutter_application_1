import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. RASTGELE KOD ÜRETİCİ: Abinin giriş yaparken kullanacağı 6 haneli kod.
  String _generateAccessCode() {
    var rng = Random();
    return (100000 + rng.nextInt(900000)).toString();
  }

  // 2. YENİ HASTA EKLEME: Bakıcı panelindeki "+" butonuyla Ahmet Eren'i eklediğimiz kısım.
  Future<void> addPatient(String patientName) async {
    try {
      String code = _generateAccessCode();
      String caregiverUid = _auth.currentUser!.uid;

      await _db.collection('patients').add({
        'patient_name': patientName,
        'access_code': code,
        'caregiver_id': caregiverUid,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'Stabil', // Varsayılan durum
        'last_message':
            '', // ÖNEMLİ: Piktogram bildirimlerinin düşeceği alan burası!
      });
    } catch (e) {
      print("Hasta eklenirken hata oluştu: $e");
      rethrow;
    }
  }

  // 3. BAKICI PANELİ İÇİN CANLI VERİ (STREAM): Bildirimleri anlık görmeni sağlar.
  Stream<QuerySnapshot> getMyPatients() {
    // GÜVENLİK KONTROLÜ: Kırmızı ekran hatasını bu '?' ve 'if' bloğu çözüyor.
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Kullanıcı giriş yapmamışsa boş bir akış döndürerek uygulamanın çökmesini engelleriz.
      return const Stream.empty();
    }

    // Sadece giriş yapan bakıcıya ait hastaları getirir.
    return _db
        .collection('patients')
        .where('caregiver_id', isEqualTo: currentUser.uid)
        .snapshots();
  }
}
