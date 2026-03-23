import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Kontrolcüleri
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Şifre Gizleme/Gösterme Durumları
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  // Firebase Şifre Değiştirme ve Yeniden Doğrulama İşlemi
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;

        // 1. ADIM: Güvenlik için kullanıcıyı mevcut şifresiyle yeniden doğruluyoruz (Re-authenticate)
        if (user != null && user.email != null) {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPasswordController.text.trim(),
          );

          await user.reauthenticateWithCredential(credential);

          // 2. ADIM: Doğrulama başarılıysa yeni şifreyi kaydediyoruz
          await user.updatePassword(_newPasswordController.text.trim());

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Şifreniz başarıyla değiştirildi!"),
              backgroundColor: Color(0xFF388E3C), // Başarı yeşili
            ),
          );

          Navigator.pop(context); // İşlem bitince ayarlara geri dön
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        // Hata mesajlarını Türkçeleştirip kullanıcıya gösteriyoruz
        String errorMessage = "Bir hata oluştu.";
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMessage = "Mevcut şifrenizi yanlış girdiniz.";
        } else if (e.code == 'weak-password') {
          errorMessage =
              "Yeni şifreniz çok zayıf. Daha güçlü bir şifre belirleyin.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Beklenmeyen bir hata: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Temamıza uygun özel TextField tasarlayan yardımcı widget'ımız
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF388E3C)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggleObscure,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1), // Uygulama arka plan rengimiz
      appBar: AppBar(
        title: const Text(
          "ŞİFRE DEĞİŞTİR",
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
                  children: [
                    const SizedBox(height: 10),
                    // Bilgilendirme metni
                    const Icon(
                      Icons.security,
                      size: 60,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Hesabınızın güvenliği için şifrenizi düzenli aralıklarla değiştirmeniz önerilir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 30),

                    // 1. MEVCUT ŞİFRE KUTUSU
                    _buildPasswordField(
                      label: "Mevcut Şifreniz",
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      toggleObscure: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Lütfen mevcut şifrenizi girin.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const SizedBox(height: 20),

                    // 2. YENİ ŞİFRE KUTUSU
                    _buildPasswordField(
                      label: "Yeni Şifre",
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      toggleObscure: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Lütfen yeni bir şifre girin.";
                        }
                        if (val.length < 6) {
                          return "Şifre en az 6 karakter olmalıdır.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // 3. YENİ ŞİFRE TEKRAR KUTUSU
                    _buildPasswordField(
                      label: "Yeni Şifre (Tekrar)",
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      toggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Lütfen yeni şifrenizi tekrar girin.";
                        }
                        if (val != _newPasswordController.text) {
                          return "Şifreler birbiriyle eşleşmiyor.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // 4. KAYDET BUTONU
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "ŞİFREYİ GÜNCELLE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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
