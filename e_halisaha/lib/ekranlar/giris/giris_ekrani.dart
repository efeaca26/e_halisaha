import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../cekirdek/servisler/api_servisi.dart';
import '../anasayfa/anasayfa_ekrani.dart';
import '../isletme/isletme_ana_sayfa.dart';
import '../web/web_ana_sayfa.dart';

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
  bool _beniHatirla = false;
  final ApiServisi _apiServisi = ApiServisi();

  Future<void> _girisYap() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _yukleniyor = true);
      
      try {
        // Hata ayıklama için terminale yazdırıyoruz
        print("Giriş isteği gönderiliyor: ${_girisEmailController.text.trim()}");

        var sonuc = await _apiServisi.girisYap(
          _girisEmailController.text.trim(), 
          _girisSifreController.text
        );

        if (!mounted) return;
        setState(() => _yukleniyor = false);

        if (sonuc != null) {
          print("Giriş başarılı! Kullanıcı verisi: ${sonuc['user']}");
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Giriş başarılı!"), 
              backgroundColor: Color(0xFF22C55E),
              behavior: SnackBarBehavior.floating,
            ),
          );

          final user = sonuc['user'];

          if (kIsWeb) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => WebAnaSayfa(kullanici: user))
            );
          } else {
            String rol = (user['role'] ?? "oyuncu").toString().toLowerCase();
            if (rol == "sahasahibi" || rol == "isletme" || rol == "admin") {
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
        } else {
          print("Giriş başarısız: API null döndü (Hatalı email/şifre)");
          _hataGoster("Şifre veya E-posta adresiniz hatalı!");
        }
      } catch (e) {
        // GERÇEK HATAYI BURADA GÖRECEĞİZ
        print("--- KRİTİK GİRİŞ HATASI ---");
        print(e);
        print("---------------------------");
        
        setState(() => _yukleniyor = false);
        _hataGoster("Bağlantı hatası: $e");
      }
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj), 
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.login_rounded,
                      size: 48,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Giriş Yap",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("E-posta", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _girisEmailController,
                            decoration: InputDecoration(
                              hintText: "email@example.com",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (val) => val!.isEmpty ? "Boş bırakılamaz" : null,
                          ),
                          const SizedBox(height: 20),
                          const Text("Şifre", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _girisSifreController,
                            obscureText: _sifreGizli,
                            decoration: InputDecoration(
                              hintText: "••••••••",
                              suffixIcon: IconButton(
                                icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (val) => val!.length < 6 ? "Şifre kısa" : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _yukleniyor ? null : _girisYap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _yukleniyor 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text("Giriş Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}