import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../web/web_ana_sayfa.dart'; // Web ana sayfasını import ettik

class WebGirisEkrani extends StatefulWidget {
  const WebGirisEkrani({super.key});

  @override
  State<WebGirisEkrani> createState() => _WebGirisEkraniState();
}

class _WebGirisEkraniState extends State<WebGirisEkrani> {
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final ApiServisi _apiServisi = ApiServisi(); // API servisimizi tanımladık
  bool _yukleniyor = false;

  // Giriş İşlemi Fonksiyonu
  Future<void> _webGirisYap() async {
    // Boş alan kontrolü
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      debugPrint("Web UI: Giriş isteği gönderiliyor...");
      var sonuc = await _apiServisi.girisYap(
        _emailController.text.trim(),
        _sifreController.text,
      );

      if (!mounted) return;
      setState(() => _yukleniyor = false);

      if (sonuc != null) {
        // BAŞARILI: Web Ana Sayfasına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebAnaSayfa(kullanici: sonuc['user']),
          ),
        );
      } else {
        // HATALI: Uyarı ver
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("E-posta veya şifre hatalı!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _yukleniyor = false);
      debugPrint("Web Giriş Hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.login_rounded, size: 50, color: Color(0xFF22C55E)),
              const SizedBox(height: 20),
              const Text("Giriş Yap",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Henüz hesabınız yok mu? Kayıt olun",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              _webInput("Kullanıcı Adı veya E-posta", _emailController, Icons.person_outline),
              const SizedBox(height: 20),
              _webInput("Şifre", _sifreController, Icons.lock_outline, gizli: true),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // Butonu fonksiyonumuza bağladık
                  onPressed: _yukleniyor ? null : _webGirisYap, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _yukleniyor
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Giriş Yap",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _webInput(String label, TextEditingController controller, IconData icon,
      {bool gizli = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: gizli,
          onSubmitted: (_) => _webGirisYap(), // Enter'a basınca giriş yapma özelliği
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }
}