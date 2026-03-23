import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math'; // Rastgele kod üretimi için gerekli

class ManagePatientsPage extends StatefulWidget {
  final DocumentSnapshot? patientData;

  const ManagePatientsPage({super.key, this.patientData});

  @override
  State<ManagePatientsPage> createState() => _ManagePatientsPageState();
}

class _ManagePatientsPageState extends State<ManagePatientsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _otherDiseaseController;
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  List<String> _selectedDiseases = [];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _diseasesList = [
    'Serebral Palsi',
    'Otizm',
    'Motor Gelişim Geriliği',
    'Konuşma Bozukluğu',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _otherDiseaseController = TextEditingController();

    if (widget.patientData != null) {
      var data = widget.patientData!.data() as Map<String, dynamic>;
      _nameController = TextEditingController(text: data['patient_name']);
      _selectedGender = data['gender'];
      _selectedBirthDate = data['birth_date'] != null
          ? (data['birth_date'] as Timestamp).toDate()
          : null;
      _selectedDiseases = List<String>.from(data['diseases'] ?? []);

      for (var d in _selectedDiseases) {
        if (!_diseasesList.contains(d)) {
          _otherDiseaseController.text = d;
        }
      }
    } else {
      _nameController = TextEditingController();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    return DateTime.now().year - birthDate.year;
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2015),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }

  Future<void> _deletePatient() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Hastayı Sil",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Bu hastayı sistemden tamamen silmek istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.patientData != null) {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientData!.id)
          .delete();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _processPatient() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBirthDate == null || _selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eksik alanları doldurun.")),
        );
        return;
      }

      final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Oturum hatası! Lütfen tekrar giriş yapın."),
          ),
        );
        return;
      }

      List<String> finalDiseases = List.from(_selectedDiseases);
      if (finalDiseases.contains('Diğer')) {
        finalDiseases.remove('Diğer');
        if (_otherDiseaseController.text.isNotEmpty) {
          finalDiseases.add(_otherDiseaseController.text.trim());
        }
      }

      // Yeni kayıt için 6 haneli rastgele giriş kodu üretimi
      String randomCode = (100000 + Random().nextInt(900000)).toString();

      final patientMap = {
        'patient_name': _nameController.text.trim(),
        'gender': _selectedGender,
        'birth_date': Timestamp.fromDate(_selectedBirthDate!),
        'diseases': finalDiseases,
        'updated_at': FieldValue.serverTimestamp(),
        'status': 'Stabil',
        'caregiver_id': currentUserUid,
        'last_message': '', // Başlangıçta boş mesaj
      };

      try {
        if (widget.patientData != null) {
          // Güncelleme yaparken mevcut giriş kodunu bozmamak için map'e eklemiyoruz
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(widget.patientData!.id)
              .update(patientMap);
        } else {
          // Yeni kayıtta giriş kodunu ekliyoruz
          patientMap['access_code'] = randomCode;
          await FirebaseFirestore.instance
              .collection('patients')
              .add(patientMap);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint("Kayıt hatası: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.patientData != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        title: Text(
          isEditing ? "HASTA DÜZENLE" : "YENİ HASTA KAYDI",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFC8E6C9),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? const Icon(
                              Icons.person,
                              size: 70,
                              color: Color(0xFF2E7D32),
                            )
                          : null,
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF388E3C),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Hasta Ad Soyad",
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF388E3C),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v!.isEmpty ? "İsim gerekli" : null,
              ),
              const SizedBox(height: 15),

              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF388E3C),
                ),
                title: Text(
                  _selectedBirthDate == null
                      ? "Doğum Tarihi"
                      : "Yaş: ${_calculateAge(_selectedBirthDate!)}",
                ),
                subtitle: Text(
                  _selectedBirthDate == null
                      ? "Seçiniz"
                      : DateFormat('dd/MM/yyyy').format(_selectedBirthDate!),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: "Cinsiyet",
                  prefixIcon: const Icon(Icons.wc, color: Color(0xFF388E3C)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Erkek', 'Kadın']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),

              const SizedBox(height: 20),
              const Text(
                "Tanılar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _diseasesList.map((disease) {
                  final isSelected = _selectedDiseases.contains(disease);
                  return FilterChip(
                    label: Text(disease),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        selected
                            ? _selectedDiseases.add(disease)
                            : _selectedDiseases.remove(disease);
                      });
                    },
                  );
                }).toList(),
              ),
              if (_selectedDiseases.contains('Diğer'))
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextFormField(
                    controller: _otherDiseaseController,
                    decoration: InputDecoration(
                      labelText: "Hastalığı/Tanıyı Yazın",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _processPatient,
                  child: Text(
                    isEditing ? "BİLGİLERİ GÜNCELLE" : "HASTAYI KAYDET",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _deletePatient,
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "HASTAYI SİL",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
