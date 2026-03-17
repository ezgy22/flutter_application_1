import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePatientsPage extends StatefulWidget {
  // Düzenlenecek hastanın verilerini bu sayfaya alıyoruz
  final DocumentSnapshot patientData;

  const ManagePatientsPage({super.key, required this.patientData});

  @override
  State<ManagePatientsPage> createState() => _ManagePatientsPageState();
}

class _ManagePatientsPageState extends State<ManagePatientsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _otherDiseaseController;

  DateTime? _selectedDate;
  String? _selectedGender;

  // Hastalık Etiketleri (Chip) için listeler
  final List<String> _availableDiseases = [
    'Serebral Palsi',
    'Epilepsi',
    'Otizm',
    'Skolyoz',
    'Görme Bozukluğu',
    'İşitme Kaybı',
  ];
  List<String> _selectedDiseases = [];
  bool _isOtherSelected = false;

  @override
  void initState() {
    super.initState();
    // Mevcut hasta verilerini form alanlarına dolduruyoruz
    var data = widget.patientData.data() as Map<String, dynamic>;

    _nameController = TextEditingController(text: data['patient_name'] ?? '');
    _otherDiseaseController = TextEditingController();

    _selectedGender = data['gender'];

    if (data['birth_date'] != null) {
      _selectedDate = (data['birth_date'] as Timestamp).toDate();
    }

    if (data['diseases'] != null) {
      _selectedDiseases = List<String>.from(data['diseases']);
      // Eğer listede standart dışı bir hastalık varsa 'Diğer'i aktif et
      for (var d in _selectedDiseases) {
        if (!_availableDiseases.contains(d)) {
          _isOtherSelected = true;
          _otherDiseaseController.text = d;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _otherDiseaseController.dispose();
    super.dispose();
  }

  // --- TAKVİM VE YAŞ HESAPLAMA MANTIĞI ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF388E3C), // Takvim başlık rengi
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _calculateDynamicAge() {
    if (_selectedDate == null) return "Doğum Tarihi Seçiniz";

    DateTime today = DateTime.now();
    int years = today.year - _selectedDate!.year;
    int months = today.month - _selectedDate!.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years == 0) return "$months Aylık";
    return "$years Yıl $months Ay";
  }

  // --- VERİTABANI GÜNCELLEME İŞLEMİ ---
  Future<void> _updatePatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        List<String> finalDiseases = List.from(_selectedDiseases);
        // 'Diğer' seçiliyse ve metin girilmişse listeye ekle, yoksa eski 'Diğer' değerlerini temizle
        finalDiseases.removeWhere((d) => !_availableDiseases.contains(d));
        if (_isOtherSelected && _otherDiseaseController.text.isNotEmpty) {
          finalDiseases.add(_otherDiseaseController.text.trim());
        }

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientData.id)
            .update({
              'patient_name': _nameController.text.trim(),
              'gender': _selectedGender,
              'birth_date': _selectedDate != null
                  ? Timestamp.fromDate(_selectedDate!)
                  : null,
              'diseases': finalDiseases,
              'updated_at': FieldValue.serverTimestamp(),
            });

        // Flutter lint uyarılarını çözen güvenli kontrol satırı
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hasta başarıyla güncellendi!"),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
        Navigator.pop(context); // Güncelleme sonrası geri dön
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata oluştu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- HASTA SİLME İŞLEMİ (DANGER ZONE) ---
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hastayı Sil", style: TextStyle(color: Colors.red)),
        content: const Text(
          "Bu hastayı ve tüm verilerini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(widget.patientData.id)
                  .delete();

              // Flutter lint uyarılarını çözen güvenli kontrol satırı
              if (!mounted) return;

              Navigator.pop(context); // Dialogu kapat
              Navigator.pop(context); // Sayfadan çık
            },
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        title: const Text(
          "HASTAYI YÖNET",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PROFİL FOTOĞRAFI ALANI
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFC8E6C9),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.green[800],
                      ), // İleride Image.network eklenebilir
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
                          // İleride ImagePicker entegre edilecek
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

              // 2. KİMLİK BİLGİLERİ
              const Text(
                "Kimlik Bilgileri",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Ad Soyad",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val!.isEmpty ? "Lütfen isim girin" : null,
              ),
              const SizedBox(height: 15),

              // CİNSİYET SEÇİMİ
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: "Cinsiyet",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Kadın', 'Erkek']
                    .map(
                      (String val) =>
                          DropdownMenuItem(value: val, child: Text(val)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 15),

              // DOĞUM TARİHİ VE DİNAMİK YAŞ
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Yaş (Doğum Tarihi)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _calculateDynamicAge(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF388E3C),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 3. TANI VE HASTALIK BİLGİLERİ
              const Text(
                "Tanı / Hastalıklar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ..._availableDiseases.map((disease) {
                    final isSelected = _selectedDiseases.contains(disease);
                    return FilterChip(
                      label: Text(disease),
                      selected: isSelected,
                      selectedColor: const Color(0xFFC8E6C9),
                      checkmarkColor: const Color(0xFF2E7D32),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedDiseases.add(disease);
                          } else {
                            _selectedDiseases.remove(disease);
                          }
                        });
                      },
                    );
                  }).toList(),
                  // DİĞER SEÇENEĞİ
                  FilterChip(
                    label: const Text("Diğer"),
                    selected: _isOtherSelected,
                    selectedColor: const Color(0xFFC8E6C9),
                    checkmarkColor: const Color(0xFF2E7D32),
                    onSelected: (bool selected) {
                      setState(() {
                        _isOtherSelected = selected;
                      });
                    },
                  ),
                ],
              ),

              // EĞER DİĞER SEÇİLİYSE METİN KUTUSU ÇIKSIN
              if (_isOtherSelected) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _otherDiseaseController,
                  decoration: InputDecoration(
                    hintText: "Lütfen diğer hastalıkları manuel yazın",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // 4. AKSİYON BUTONLARI (GÜNCELLE & SİL)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _updatePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "DEĞİŞİKLİKLERİ KAYDET",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // TEHLİKELİ BÖLGE (SİL BUTONU)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text(
                    "Hastayı Sistemden Sil",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
