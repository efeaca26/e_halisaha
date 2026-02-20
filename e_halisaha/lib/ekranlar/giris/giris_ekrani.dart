import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Web kontrolü için gerekli
import '../../cekirdek/servisler/api_servisi.dart';
import '../anasayfa/anasayfa_ekrani.dart';
import '../isletme/isletme_ana_sayfa.dart';
import '../web/web_ana_sayfa.dart'; // Yeni web sayfan

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _girisEmailController = TextEditingController();
  final TextEditingController _girisSifreController = TextEditingController();
  
  bool _sifreGizli = true;
  bool _yukleniyor = false;
  final ApiServisi _apiServisi = ApiServisi();

  Future<void> _girisYap() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _yukleniyor = true);
      
      debugPrint("UI: Giriş denemesi başlıyor...");

      var sonuc = await _apiServisi.girisYap(
        _girisEmailController.text.trim(), 
        _girisSifreController.text
      );

      if (!mounted) return;
      setState(() => _yukleniyor = false);

      if (sonuc != null) {
        // Başarılı giriş mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş Başarılı!"), backgroundColor: Colors.green),
        );

        final user = sonuc['user'];

        // =====================================================================
        // 🌐 WEB VE MOBİL YOL AYRIMI BURADA
        // =====================================================================
        if (kIsWeb) {
          // Eğer tarayıcıdan girildiyse özel web tasarımına gönderiyoruz
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => WebAnaSayfa(kullanici: user))
          );
        } else {
          // Eğer mobilden (Android/iOS) girildiyse mevcut rollere göre yönlendiriyoruz
          String rol = (user['role'] ?? "oyuncu").toString().toLowerCase();

          if (rol == "isletme" || rol == "admin") {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => IsletmeAnaSayfa(kullanici: user))
            );
          } else {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const AnasayfaEkrani())
            );
          }
        }
        // =====================================================================

      } else {
        // Hatalı giriş uyarısı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("E-posta veya Şifre Hatalı! (Bağlantınızı ve SQL verilerini kontrol edin)"), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool koyuMod = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Image.asset(koyuMod ? 'assets/icon_beyaz.png' : 'assets/icon.png', height: 100),
                const SizedBox(height: 30),
                
                // Kullanıcı Giriş Alanı
                TextFormField(
                  controller: _girisEmailController,
                  decoration: const InputDecoration(
                    labelText: "E-posta veya Telefon", 
                    prefixIcon: Icon(Icons.person_outline)
                  ),
                  validator: (val) => val!.isEmpty ? "Bu alan boş bırakılamaz" : null,
                ),
                const SizedBox(height: 20),
                
                // Şifre Alanı
                TextFormField(
                  controller: _girisSifreController,
                  obscureText: _sifreGizli,
                  decoration: InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                    ),
                  ),
                  validator: (val) => val!.length < 6 ? "Şifre çok kısa" : null,
                ),
                const SizedBox(height: 30),
                
                // Giriş Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _yukleniyor ? null : _girisYap,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
                    child: _yukleniyor 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("GİRİŞ YAP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}