import 'package:flutter/foundation.dart'; // kIsWeb için gerekli
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../giris/giris_ekrani.dart';
import 'profil_alt_sayfalar_yeni.dart'; 

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  
  String _adSoyad = "";
  String _email = "";
  int _toplamMac = 0;
  bool _yukleniyor = true;
  
  // DÜZELTME: File yerine XFile kullanıyoruz (Web uyumu için)
  XFile? _profilResmi; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _kullaniciVerileriniYukle();
  }

  void _kullaniciVerileriniYukle() async {
    final aktifKullanici = KimlikServisi.aktifKullanici;
    if (aktifKullanici == null || aktifKullanici['id'] == null) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const GirisEkrani()), (route) => false);
      }
      return;
    }

    int userId = aktifKullanici['id'];
    try {
      var userMap = await _apiServisi.kullaniciGetir(userId);
      var maclar = await _apiServisi.randevularimiGetir(userId);

      if (mounted) {
        setState(() {
          if (userMap != null) {
            _adSoyad = userMap['fullName'] ?? "Kullanıcı";
            _email = userMap['email'] ?? "";
          }
          _toplamMac = maclar.length;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _resimSec() async {
    final XFile? secilenDosya = await _picker.pickImage(source: ImageSource.gallery);
    if (secilenDosya != null) {
      setState(() => _profilResmi = secilenDosya);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool koyuMod = Theme.of(context).brightness == Brightness.dark;

    if (_yukleniyor) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            color: koyuMod ? Colors.grey[800] : Colors.grey[200], 
                            border: Border.all(color: const Color(0xFF22C55E), width: 3)
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.transparent, 
                            // DÜZELTME: Web ve Mobil uyumlu resim gösterme
                            backgroundImage: _profilResmi != null 
                              ? (kIsWeb ? NetworkImage(_profilResmi!.path) : AssetImage(_profilResmi!.path) as ImageProvider)
                              : null,
                            child: _profilResmi == null ? Icon(Icons.person, size: 60, color: Colors.grey[400]) : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _resimSec,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_adSoyad, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: koyuMod ? Colors.white : const Color(0xFF111827))),
                    Text(_email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _istatistikAlani(koyuMod),
              const SizedBox(height: 32),
              _profilMenuItem(context, Icons.person_outline, "Hesap Bilgileri", const HesapBilgileriEkrani()),
              _profilMenuItem(context, Icons.history, "Geçmiş Rezervasyonlar", const GecmisRezervasyonlarEkrani()),
              _profilMenuItem(context, Icons.settings_outlined, "Ayarlar", const AyarlarEkrani()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _istatistikAlani(bool koyuMod) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: koyuMod ? Colors.black26 : Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _istatistikKutu("Maçlar", "$_toplamMac"),
          _istatistikKutu("Goller", "0"),
          _istatistikKutu("Puan", "10"),
        ],
      ),
    );
  }

  Widget _istatistikKutu(String baslik, String deger) {
    return Column(children: [Text(deger, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(baslik, style: const TextStyle(color: Colors.grey))]);
  }

  Widget _profilMenuItem(BuildContext context, IconData icon, String text, Widget sayfa) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF22C55E)),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => sayfa)),
    );
  }
}