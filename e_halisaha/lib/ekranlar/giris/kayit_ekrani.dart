import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _sifreTekrarController = TextEditingController();

  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;
  bool _yukleniyor = false;

  void _kayitOl() async {
    String ad = _adController.text.trim();
    String email = _emailController.text.trim();
    String tel = _telefonController.text.trim(); // Artık boş da olabilir
    String sifre = _sifreController.text.trim();
    String sifreTekrar = _sifreTekrarController.text.trim();

    // tel.isEmpty kontrolü buradan çıkarıldı
    if (ad.isEmpty || email.isEmpty || sifre.isEmpty || sifreTekrar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen zorunlu alanları (Ad, Email, Şifre) doldurun."), backgroundColor: Colors.red));
      return;
    }

    if (sifre != sifreTekrar) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifreler eşleşmiyor!"), backgroundColor: Colors.red));
      return;
    }

    if (sifre.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre en az 6 karakter olmalıdır."), backgroundColor: Colors.red));
      return;
    }

    setState(() => _yukleniyor = true);

    bool basarili = await _apiServisi.kayitOl(ad, email, tel, sifre);

    if (!mounted) return;
    setState(() => _yukleniyor = false);

    if (basarili) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarılı! Lütfen giriş yapın."), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Giriş ekranına geri dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarısız oldu. Sunucu hatası veya email kullanımda olabilir."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Hesap Oluştur", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              const SizedBox(height: 8),
              const Text("Hemen kayıt ol ve sahaları keşfetmeye başla.", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              
              // Ad Soyad
              _girisAlani(
                baslik: "Ad Soyad",
                hint: "Ahmet Yılmaz",
                ikon: Icons.person_outline,
                controller: _adController,
              ),
              const SizedBox(height: 20),
              
              // Email
              _girisAlani(
                baslik: "E-posta",
                hint: "ornek@mail.com",
                ikon: Icons.email_outlined,
                controller: _emailController,
                klavyeTipi: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Telefon
              _girisAlani(
                baslik: "Telefon Numarası (İsteğe Bağlı)",
                hint: "0555 555 55 55",
                ikon: Icons.phone_outlined,
                controller: _telefonController,
                klavyeTipi: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              
              // Şifre
              _sifreAlani(
                baslik: "Şifre",
                hint: "********",
                controller: _sifreController,
                gizli: _sifreGizli,
                onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
              ),
              const SizedBox(height: 20),

              // Şifre Tekrar
              _sifreAlani(
                baslik: "Şifre Tekrar",
                hint: "********",
                controller: _sifreTekrarController,
                gizli: _sifreTekrarGizli,
                onPressed: () => setState(() => _sifreTekrarGizli = !_sifreTekrarGizli),
              ),
              const SizedBox(height: 40),
              
              // Kayıt Butonu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _yukleniyor ? null : _kayitOl,
                  child: _yukleniyor
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("KAYIT OL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _girisAlani({required String baslik, required String hint, required IconData ikon, required TextEditingController controller, TextInputType klavyeTipi = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: klavyeTipi,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(ikon, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _sifreAlani({required String baslik, required String hint, required TextEditingController controller, required bool gizli, required VoidCallback onPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: gizli,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(gizli ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: onPressed,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
          ),
        ),
      ],
    );
  }
}