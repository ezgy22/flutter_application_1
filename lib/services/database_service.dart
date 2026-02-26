import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Rastgele 6 haneli kod üretme
  String _generateAccessCode() {
    var rng = Random();
    return (100000 + rng.nextInt(900000)).toString();
  }

  // 2. Yeni Hasta Ekleme
  Future<void> addPatient(String patientName) async {
    try {
      String code = _generateAccessCode();
      String caregiverUid = _auth.currentUser!.uid;

      await _db.collection('patients').add({
        'patient_name': patientName,
        'access_code': code,
        'caregiver_id': caregiverUid,
        'created_at':
            FieldValue.serverTimestamp(), // Firebase'in kendi saatini kullanmak daha garantidir
        'status': 'Stabil',
      });
    } catch (e) {
      print("Hasta eklenirken hata oluştu: $e");
      rethrow; // Hatayı yukarı fırlat ki UI tarafında kullanıcıya gösterebilelim
    }
  }

  // 3. Bakıcının hastalarını anlık olarak getirme (Stream)
  Stream<QuerySnapshot> getMyPatients() {
    String caregiverUid = _auth.currentUser!.uid;
    return _db
        .collection('patients')
        .where('caregiver_id', isEqualTo: caregiverUid)
        .snapshots();
  }
}
