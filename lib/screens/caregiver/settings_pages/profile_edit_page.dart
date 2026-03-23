import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Kontrolcüleri
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController; // Sadece okuma amaçlı

  String? _selectedRole;
  bool _isLoading = true;

  // Sorumlu Kişi Rolleri (Sistemimize özel)
  final List<String> _roles = [
    'Anne',
    'Baba',
    'Kardeş',
    'Bakıcı',
    'Fizyoterapist',
    'Özel Eğitim Öğretmeni',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  // Firebase'den mevcut kullanıcının verilerini çekme
  Future<void> _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _emailController.text = currentUser.email ?? '';

      try {
        // 'caregivers' koleksiyonundan kullanıcının UID'sine göre belgeyi çekiyoruz
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('caregivers')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _selectedRole = data['role'];
          });
        }
      } catch (e) {
        debugPrint("Veri çekme hatası: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Veritabanına değişiklikleri kaydetme
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // 'caregivers' koleksiyonunda veriyi güncelliyoruz (veya yoksa oluşturuyoruz)
          await FirebaseFirestore.instance
              .collection('caregivers')
              .doc(currentUser.uid)
              .set({
                'name': _nameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'role': _selectedRole,
                'email': currentUser.email, // E-posta referans olarak dursun
                'updated_at': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true)); // Sadece değişenleri günceller

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil başarıyla güncellendi!"),
              backgroundColor: Color(0xFF388E3C),
            ),
          );
          Navigator.pop(context); // İşlem bitince ayarlar menüsüne dön
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Bir hata oluştu: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1), // Uygulama arka plan rengimiz
      appBar: AppBar(
        title: const Text(
          "PROFİLİ DÜZENLE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF388E3C)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. PROFİL FOTOĞRAFI ALANI ---
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 55,
                            backgroundColor: Color(0xFFC8E6C9),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF388E3C),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Fotoğraf yükleme yakında eklenecek.",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- 2. KİŞİSEL BİLGİLER FORMU ---
                    const Text(
                      "Kişisel Bilgiler",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Ad Soyad Kutusu
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Ad Soyad",
                        prefixIcon: const Icon(
                          Icons.badge,
                          color: Color(0xFF388E3C),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Lütfen adınızı girin" : null,
                    ),
                    const SizedBox(height: 15),

                    // Telefon Numarası Kutusu
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Telefon Numarası",
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFF388E3C),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Yakınlık / Rol Açılır Menüsü
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        labelText: "Sistemdeki Rolünüz",
                        prefixIcon: const Icon(
                          Icons.health_and_safety,
                          color: Color(0xFF388E3C),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _roles.map((String role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedRole = val),
                    ),
                    const SizedBox(height: 15),

                    // Kayıtlı E-posta (Salt Okunur)
                    TextFormField(
                      controller: _emailController,
                      readOnly: true, // Değiştirilemez!
                      style: const TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: "Kayıtlı E-posta Adresi",
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade200, // Soluk arka plan
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        helperText:
                            "E-posta adresi güvenlik nedeniyle buradan değiştirilemez.",
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- 3. KAYDET BUTONU ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "BİLGİLERİ KAYDET",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
